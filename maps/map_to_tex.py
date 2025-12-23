#! /usr/bin/env python3
import json
import sys
from pprint import pprint
from collections import deque

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

def xrdef(name, r=None):
    id = None
    if r: id = r[name]
    else: id = refs[name]
    return "\\xrdef{" + id + "}"

def xref(name, r=None):
    id = None
    if r: id = r[name]
    else: id = refs[name]
    return "\\xref{" + id + "}"

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

# generate subgraph trie
class Trie:
    def __init__(self):
        self.children = {}
        self.path = "/"
        self.terminal = False
        self.count = 0


    def append(self, name):
        subnames = name.split("/")
        node = self
        curpath = []
        for sn in subnames:
            curpath.append(sn)
            if sn not in node.children:
                child = Trie()
                child.path = "/".join(curpath)
                node.children[sn] = child
            node.count += 1
            node = node.children[sn]
        node.terminal = True


def hpair(a, b):
    return a + " \\leaders\\hbox to 10pt {\\hss.\\hss} " + " \\hfill " + b 
    
def node_index_ref(name):
    #return escape(name) + " \\hfill " + xref(name)
    return hpair(escape(name), xref(name))

def node_index_ref_abbr(name, ref=None):
    return hpair(basename(name), xref(name, ref))

namespaces = Trie()

for name in names: namespaces.append(name)

class NamespaceIndex:
    def __init__(self, name):
        self.name = name
        self.children = []
        self.nodes = []

    def display(self, refs=None):
        if len(self.nodes) == 0 and len(self.children) == 0: return
        print(xrdef(self.name, refs))
        print(escape(self.name))
        print("\\par\\begingroup")
        leftskip("2em")

        smallskip()
        for child in self.children:
            # TODO: create page index
            #print(basename(child))
            print(node_index_ref_abbr(child, refs))
            smallskip()

        medskip()
        for node in self.nodes:
            # print(escape(node))
            print(node_index_ref_abbr(f"{self.name}/{node}"))
            smallskip()

        print("\\par\\endgroup")
        bigskip()


def mknsidx(namespaces):
    q = deque()

    q.append(namespaces)

    nsidx = []
    nsref = {}

    while q:
        node = q.popleft()
        ni = NamespaceIndex(node.path)
        children = []
        nodes = []
        for (k, v) in node.children.items():
            if v.terminal:
                nodes.append(k)
            if (v.count > 0): children.append(v.path)
            q.append(v)
        ni.nodes = nodes
        ni.children = children
        nsref[node.path] = 'g' + str(len(nsref))
        nsidx.append(ni)

    return nsidx, nsref

nsidx, nsref = mknsidx(namespaces)

print("\\input eplain")

# print namespace index

for ni in nsidx: ni.display(nsref)

# print index
for name in names:
    print(node_index_ref(name))
    smallskip()

print("\\vfill \\break")

# print nodes
for name in names:
    display(name, nodes[name])

print("\\bye")
