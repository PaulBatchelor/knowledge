#! /usr/bin/env python3
import json
import sys
from pprint import pprint

def begin():
    # print("\\pdfoutput=1")
    print("\\input eplain")
    print("\\input graphicx")
    print("\\input epsf")
    print("\\parindent=0pt")
    pagewidth=140
    pageheight=210
    # print(f"\\pdfpagewidth={pagewidth}mm")
    # print(f"\\pdfpageheight={pageheight}mm")
    # print("\\pdfhorigin=0pt")
    # print("\\pdfvorigin=0pt")
    print("\\special{papersize=" + str(pagewidth) + "mm," + str(pageheight) + "mm}")
    print(f"\\hsize={pagewidth- 20}mm")
    print(f"\\vsize={pageheight - 20}mm")
    offset = -1 + (10.0 / 25.4)
    offset = str(offset) + "in"
    print("\\hoffset=" + offset)
    print("\\voffset=" + offset)

def end():
    print("\\bye")

def includegraphics(width, path):
    cmd = "\\includegraphics"
    cmd += f"[width={width}]"
    cmd += "{" + path + "}"
    return cmd

def epsfbox(width, path):
    cmd = "\\epsfxsize=" + str(width) + "in"
    cmd += "\\epsfbox"
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
        path = self.path
        path = path + ".eps"
        width = self.width / 72.0
        pgwidth = 140 - 20
        pgwidth /= 25.4 # mm to in
        if width > pgwidth:
            width = pgwidth
        return epsfbox(width, path)

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
    fig = Figure(path, w, h)

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

for (pgid, pg) in sorted(pages.items()):
    pg.nids.sort()
    print(f"{{\\bf {pgid}}}\medskip")
    for fig in pg.figs:
        print(fig.draw())
    print("\\medskip")
    for nid in pg.nids:
        print(f"{{\\bf {nid}.}} {pg.nodes[nid]} \quad")
    print("\\vfill\\eject")

end()
