
def rgb_hamming(c1, c2):
  r1, g1, b1 = (c1&0xFF), ((c1>>8)&0xFF), ((c1>>16)&0xFF)
  r2, g2, b2 = (c2&0xFF), ((c2>>8)&0xFF), ((c2>>16)&0xFF)
  return abs(r1-r2) + abs(g1-g2) + abs(b1-b2)

def min2_dist(an, x):
  #dists = set(rgb_hamming(a,x) for a in an)
  #return list(sorted(dists))[:2]
  min1, min2 = (100000, None), (100000, None)
  for a in an:
    ham = rgb_hamming(a,x)
    if ham < min1[0]:
      min2 = min1
      min1 = (ham, a)
    if ham < min2[0]:
      min2 = (ham, a)

  return min1, min2

def addpend(dic, key, val):
  if key not in dic:
    dic[key] = set()
  dic[key].add(val)

import csv

def load_wiki():
  rgbtbl = {}

  with open("wiki_names", "rt") as f:
    reader = csv.reader(f, delimiter="\t")
    next(reader)
    for name, rgb, r,g,b, hue, s1,l1,s2,l2, alt in reader:
      rgb = int(rgb[1:], 16)
      addpend(rgbtbl, rgb, name)

  with open("wiki_numvar", "rt") as f:
    reader = csv.reader(f, delimiter="\t")
    next(reader)
    for name, hue, s1, b1, rgb0, rgb1, rgb2, rgb3, rgb4 in reader:
      rgb0 = int(rgb0[1:], 16)
      addpend(rgbtbl, rgb0, name)

      if rgb1:
        if rgb1 == '←':
          rgb1 = rgb0
        else:
          rgb1 = int(rgb1[1:], 16)
        addpend(rgbtbl, rgb1, name + " 1")
      if rgb2:
        rgb2 = int(rgb2[1:], 16)
        addpend(rgbtbl, rgb2, name + " 2")
      if rgb3:
        rgb3 = int(rgb3[1:], 16)
        addpend(rgbtbl, rgb3, name + " 3")
      if rgb4:
        rgb4 = int(rgb4[1:], 16)
        addpend(rgbtbl, rgb4, name + " 4")

  print(len(rgbtbl))

  return rgbtbl

  #with open("wiki_prefix", "rt") as f:
  #  reader = csv.reader(f)
  #  next(reader)
  #  for name, base, pale, light, medum, dark, deep, other in reader:

def load_vim():
  rgbtbl = {}
  with open("vim_list", "rt") as f:
    for line in f:
      _, name, val, rgb, _ = line.split()
      _,name = name.split('_')
      _,val = val.split('=')
      rgb = int(rgb.split('#')[1], 16)
      addpend(rgbtbl, rgb, (name, val))

  return rgbtbl

wiki_tbl = load_wiki()

vim_tbl = load_vim()

an = wiki_tbl.keys()
aa, bb = [], []
aaa = set()
for x in vim_tbl:
  a, b = min2_dist(an, x)
  if a[0] > 50: aaa.add((x,a))
  aa.append(a)
  bb.append(b)

#from collections import Counter
#print("min1")
#distr = dict(Counter(aa))
#for k in sorted(distr.keys()): print(k, "\t", distr[k])
#print("min2")
#distr = dict(Counter(bb))
#for k in sorted(distr.keys()): print(k, "\t", distr[k])
for v,w in aaa: print(f"{v:06x}|{w[1]:06x}: {vim_tbl[v]}")
