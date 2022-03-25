
def parse_rgb(rgb):
  return int(rgb[1:], 16)

# data from https://www.astrouw.edu.pl/~jskowron/colors-x11/rgb.html
def load_rgb_ref(path):
  def parse(line):
    name, rgb, _,_ = line.split("\t")
    return parse_rgb(rgb), name

  with open(path, "rt") as f:
    return [parse(line) for line in f if line[0]!='#']

# data from http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
def load_256code(path):
  def parse_pair(cid, rgb):
    return int(cid,10), parse_rgb(rgb)
  def parse(line):
    it = iter(line.split())
    while True:
      try: yield parse_pair(next(it), next(it))
      except StopIteration: break

  with open(path, "rt") as f:
    return list(parse(f.read()))

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

def find_match(cid, rgb, rgb_name):
  cands = find_matches(rgb, (rgb for rgb, name in rgb_name), 100000)
  if len(cands) == 0: return None
  if len(cands) == 1: return cands[0]

  (_,d1), (_,d2) = cands[0], cands[1]
  if d2 - d1 > 50: return cands[0]

  print("multiple candidates for {colors(rgb)}")

  threshold = 50
  while True:
    for i,(j,d) in enumerate(cands):
      if d > threshold: break
      _rgb, name = rgb_name[j]
      print(f"{i:3} {colors(rgb, _rgb)} ~{d:3} {name}")

    try:
      print(f"~{threshold} for {cid}, choice? ", end='')
      ans = input()
      if ans == "+":  threshold +=  50; continue
      if ans == "++": threshold += 100; continue
      if ans == "-":  threshold -= 10; continue
      if ans == "--": threshold -= 20; continue
      elif ans == 'q': raise SystemError
      elif ans == '': ans = '0'
      ans = int(ans)
      if i < ans: raise IndexError
      return cands[ans]
    except (ValueError, IndexError):
      print("please enter current number")
      continue

def camelCase(name):
  return ''.join(
    word[0].upper() + word[1:]
    for word in name.split(" ")
  )

def load_matching(path):
  def parse(line):
    name,_,cid,_,_,rgb,_,_rgb = line.split()
    return int(cid), (parse_rgb(_rgb), name)

  try:
    with open(path, "rt") as f:
      return dict(parse(line) for line in f)
  except Exception:
    return {}

rgb_name = load_rgb_ref("jskowron")
print(len(rgb_name))

cid_rgb = load_256code("calmer")
print(len(cid_rgb))

import sys

matching = load_matching("matching");

f = open("matching", "wt")

for cid, rgb in cid_rgb:
  if cid not in matching:
    try: j, d = find_match(cid, rgb, rgb_name)
    except SystemError:
      break
    _rgb, name = rgb_name[j]
    name = camelCase(name)
    cnfl = [c for c,(_,n) in matching.items() if n == name]
    if cnfl:
      crgb = [crgb for c,crgb in cid_rgb if c == cnfl[0]][0]
      print(crgb)
      print(f"{name} is already taken for cid={cnfl[0]}")
      print(f"{cnfl[0]}:{colors(crgb,_rgb,rgb)}:{cid}")
      break
  else:
    _rgb, name = matching[cid]

  print(f"selecting {colors(rgb, _rgb)} for {cid}th color ({name})")
  matching[cid] = (_rgb, name)
  print(f"\t{name:20s} = {cid:3}, // rgb: #{rgb:06x} => #{_rgb:06x}", file=f)

f.close()

## priority rules
# 1. hamming distance (for diff>10)
# 2. prefix adjective > suffix number
# 3. prefer plain colr names (yellow > gold)

