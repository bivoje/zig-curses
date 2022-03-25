
def parse_rgb(rgb):
  return int(rgb[1:], 16)

# data from https://www.astrouw.edu.pl/~jskowron/colors-x11/rgb.html
def load_rgb_ref(path):
  def parse(line):
    name, rgb, _,_ = line.split("\t")
    return parse_rgb(rgb), name

  with open(path, "rt") as f:
    return [parse(line) for line in f if line[0]!='#']

def load_ditig(path):
  def parse_pair(cid, rgb):
    return int(cid,10), parse_rgb(rgb)
  def parse(line):
    row = line.split('\t')
    cid   = int(row[0])
    name  = row[1].replace("(SYSTEM)", '').strip()
    rgb   = parse_rgb(row[2])
    return (cid, (name, rgb))

  with open(path, "rt") as f:
    return dict(parse(line) for line in f if not line.startswith('#'))

def drgb(c):
  return (c>>16)&0xFF, (c>>8)&0xFF, c&0xFF

def hamming(c1, c2):
  r1, g1, b1 = drgb(c1)
  r2, g2, b2 = drgb(c2)
  return abs(r1-r2) + abs(g1-g2) + abs(b1-b2)

def find_matches(rgb, rgbs, threshold):
  return \
    list(
      sorted(
        filter(lambda x: x[1] < threshold,
          ((i, hamming(rgb, cand_rgb))
          for i, cand_rgb in enumerate(rgbs))
        ), key = lambda x: x[1],
      )
    )

def colors(*rgbs):
  def color(rgb):
    r, g, b = drgb(rgb)
    return f"\x1b[48;2;{r};{g};{b}m{rgb:06x}"
  return "\x1b[0m|".join(color(rgb) for rgb in rgbs) + "\x1b[0m"

def find_match(cids, rgbs, rgb_name, matching, cnt=8):

  ref_rgbs = list(rgb for rgb, name in rgb_name)
  taken = set(r[2] for r in matching)
  candss = []
  for cid, rgb in zip(cids, rgbs):
    print(f"\ncands for {cid} (#{rgb:06x}):")
    cands = find_matches(rgb, ref_rgbs, 100000)

    for i,(j,d) in enumerate(cands[:cnt]):
      _rgb, name = rgb_name[j]
      name = camelCase(name)
      print(f"{d:3} ~ {colors(_rgb, rgb)} {i:3} {'*' if name in taken else ''} {name}")
    candss.append(cands[:cnt])

  while True:
    print(f"choices? ", end='')
    ans = input().split()
    if ans[0] == "more":
      return None
    if len(ans) != len(cids):
      print("# of colors does not match, try again")
      continue
    try: picks = list(rgb_name[cands[int(a)][0]] for cands,a in zip(candss,ans))
    except IndexError:
      print("insert integer in range")
      continue
    except ValueError:
      print("insert integer")
      continue
    picks = [(rgb,camelCase(name)) for rgb,name in picks]
    names = set(name for rgb,name in picks)
    if len(names) < len(picks):
      print(f"duplicated name in {picks}")
      continue

    return picks

def camelCase(name):
  return ''.join(
    word[0].upper() + word[1:]
    for word in name.split(" ")
  )

def load_matching(path):
  def parse(line):
    row = line.split()
    name = row[0]
    cid  = int(row[2][:-1])
    rgb  = parse_rgb(row[5])
    return cid, (name, rgb)

  #try:
  with open(path, "rt") as f:
    return dict(parse(line) for line in f)
  #except Exception:
  #  return {}

rgb_name = load_rgb_ref("jskowron")
print("x11", len(rgb_name))

cid_name_rgb = load_ditig("ditig")
print("ditig", len(cid_name_rgb))

ditig_name_cid = {}
for cid,(name,rgb) in cid_name_rgb.items():
  if name not in ditig_name_cid:
    ditig_name_cid[name] = []
  ditig_name_cid[name].append(cid)

responsibles = list(k for k,v in ditig_name_cid.items() if len(v)>1)
print("resp", len(responsibles))

import sys

matching = []

for i, (name, cids) in enumerate(ditig_name_cid.items()):
  if len(cids) == 1:
    name, rgb = cid_name_rgb[cids[0]]
    matching.append((cids[0], rgb, camelCase(name)))
    continue

  rgbs = [cid_name_rgb[cid][1] for cid in cids]
  print(
      f"{i}: name {name} is assigned to colors",
      ", ".join(f"{cid} (#{rgb:06x})" for cid,rgb in zip(cids,rgbs)))

  picks = find_match(cids, rgbs, rgb_name, matching)
  if picks is None:
    picks = find_match(cids, rgbs, rgb_name, matching, cnt=20)


  for i in range(len(cids)):
    assert(picks[i][1] not in matching)
    matching.append(
      (cids[i], rgbs[i], picks[i][1])
    )

name_rgb = { camelCase(name):rgb for rgb,name in rgb_name }
with open("matching", "wt") as f:
  for cid,rgb,name in sorted(matching, key=lambda r: r[0]):
    _rgb = name_rgb.get(name)
    line1 = f"\t{name:20s} = {cid:3}, // rgb: #{rgb:06x}"
    line2 = f" <= #{_rgb:06x}" if _rgb else ""
    print(line1 + line2, file=f)
