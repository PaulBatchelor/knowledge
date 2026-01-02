#! /usr/bin/env python3
import json
import sys

def begin():
    print("\\input eplain")
    print("\\parindent=0pt")
    print("\\pdfpagewidth=148mm")
    print("\\pdfpageheight=210mm")
    print("\\hsize=128mm")
    print("\\vsize=190mm")
    print("\\pdfhorigin=0pt")
    print("\\pdfvorigin=0pt")
    print("\\hoffset=10mm")
    print("\\voffset=10mm")


def basename(name):
    return name.split("/")[-1].replace("_", "\\_")

def render(data):
    for row in data:
        print("{\\tt" +\
                row.id.upper() +\
                "}: ",\
                basename(row.name))
        print("[" + row.page + "]")
        print("\\smallskip")
        print(row.body)
        print("\\bigskip")

def parse(objs):
    data = []
    for o in objs:
        body = " ".join(json.loads(o["lines"]))
        txo = TextObject(o["value"], \
                o["name"], \
                body, \
                o["page"])
        data.append(txo)
    return data


class TextObject:
    def __init__(self, id, name, body, page):
        self.body = body
        self.id = id 
        self.name = name
        self.page = page

all_input = sys.stdin.read()
objs = json.loads(all_input)

begin()
data = parse(objs)
render(data)
print("\\bye")
