#! /usr/bin/env python3
import json
import sys
from pprint import pprint

obj = None

all_input = sys.stdin.read()
objs = json.loads(all_input)

nodes = {}

names = []

refs = {}

for o in objs:
    node = {}
    name = o["name"]
    if name is None:
        print("uh oh")
        assert(False)
    children = parents = lines = None

    if o["children"]:
        children = json.loads(o["children"])

    if o["parents"]:
        parents = json.loads(o["parents"])


    if o["lines"]:
        lines = o["lines"]

    node = {
        "children": children,
        "parents": parents
    }

    if lines is not None:
        node["text"] = " ".join(json.loads(o["lines"]))

    nodes[name] = node
    names.append(name)
    refs[name] = 'r' + str(len(names))

def smallskip():
    print("\\smallskip")

def medskip():
    print("\\medskip")

def bigskip():
    print("\\bigskip")

def escape(s):
    return s.replace("_","\\_")

def basename(s):
    return escape(s.split("/")[-1])

def path_to_label(name):
    return name.replace("/","-").replace("_", "")

def xrdef(name):
    return "\\xrdef{" + refs[name] + "}"

def xref(name):
    return "\\xref{" + refs[name] + "}"

def process_node(s):
    return f"{basename(s)}[{xref(s)}]"

def leftskip(x):
    print("\\leftskip=" + x)

def display(name, node):
    print(xrdef(name))
    print(basename(name))
    smallskip()
    print("{")
    leftskip("2em")
    print("path:", escape(name))
    smallskip()
    if "text" in node:
        print("text: ", node["text"])
        smallskip()

    if node["parents"]:
        parents = [ process_node(c) for c in node["parents"] ]
        print("parents: ", ", ".join(parents))
        smallskip()


    if node["children"]:
        children = [ process_node(c) for c in node["children"] ]
        print("children:", ", ".join(children))
        smallskip()

    leftskip("0em")
    print("}")
    bigskip()

print("\\input eplain")
for name in names:
    print(escape(name), "\\hfill", xref(name))
    smallskip()

print("\\vfill \\break")

for name in names:
    display(name, nodes[name])

print("\\bye")
