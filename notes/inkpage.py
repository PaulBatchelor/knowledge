#! /usr/bin/env python3
import json
import sys
from pprint import pprint

def begin():
    print("\\pdfoutput=1")
    print("\\input eplain")
    print("\\input graphicx")
    print("\\parindent=0pt")
    pagewidth=140
    pageheight=210
    print(f"\\pdfpagewidth={pagewidth}mm")
    print(f"\\pdfpageheight={pageheight}mm")
    print(f"\\hsize={pagewidth- 20}mm")
    print(f"\\vsize={pageheight - 20}mm")
    print("\\pdfhorigin=0pt")
    print("\\pdfvorigin=0pt")
    print("\\hoffset=10mm")
    print("\\voffset=10mm")

def end():
    print("\\bye")

def includegraphics(width, path):
    cmd = "\\includegraphics"
    cmd += f"[width={width}]"
    cmd += "{" + path + "}"
    return cmd

class InkPage:
    def __init__(self):
        self.figs = []
        self.nodes = {}
        self.nids = []
        pass

class Figure:
    def __init__(self, path, w, h):
        self.path = path
        self.width = w
        self.height = h
    def draw(self):
        PPI=124.413
        width_in = str(self.width * (1.0/PPI)) + "in"
        return includegraphics(width_in, self.path)

all_input = sys.stdin.read()
objs = json.loads(all_input)
pages = {}

for figobj in objs["figs"]:
    pg = figobj["page"]
    if pg not in pages:
        pages[pg] = InkPage()
  
    w = figobj["width"]
    h = figobj["height"]
    path = figobj["path"]
    fig = Figure("notes/" + path, w, h)

    pages[pg].figs.append(fig)

for ndobj in objs["nodes"]:
    pg = ndobj["page"]
    if pg not in pages:
        pages[pg] = InkPage()

    nid = ndobj["value"]
    content = " ".join(ndobj["lines"])

    pages[pg].nodes[nid] = content
    pages[pg].nids.append(nid)

begin()
pg = pages["066"]
pg.nids.sort()

for fig in pg.figs:
    print(fig.draw())

print("\\medskip")

for nid in pg.nids:
    print(f"{{\\bf {nid}.}} {pg.nodes[nid]} \quad")

end()
