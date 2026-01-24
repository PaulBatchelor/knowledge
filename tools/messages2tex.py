#! /usr/bin/env python3
import json
import sys
from pprint import pprint

def begin():
    print("\\input eplain")
    print("\\pdfpagewidth=148mm")
    print("\\pdfpageheight=210mm")
    print("\\hsize=128mm")
    print("\\vsize=190mm")
    print("")
    print("\\pdfhorigin=0pt")
    print("\\pdfvorigin=0pt")
    print("\\hoffset=10mm")
    print("\\voffset=10mm")

def bye():
    print("\\bye")

def title(txt):
    #return "# " + txt
    return "\\centerline" + \
        "{" + \
        "\\bf" + \
        "\\font" + \
        "\\titlefont=cmr17 at 20pt" + \
        "\\titlefont " + txt + \
        "}" + \
        "\\vskip 0.3in"

def header1(txt):
    #return "# " + txt
    return "{" + \
        "\\medskip" +\
        "\\noindent" + \
        "\\bf" + \
        "\\font" + \
        "\\titlefont=cmss17 at 20pt" + \
        "\\titlefont " + txt + \
        "}" + \
        "\\medskip"

def header2(txt):
    # return "## " + txt
    return "{" + \
        "\\medskip" +\
        "\\noindent" + \
        "\\bf" + \
        "\\font" + \
        "\\titlefont=cmitt12 at 17pt" + \
        "\\titlefont " + txt + \
        "}" + \
        "\\medskip"

def header3(txt):
    # return "### " + txt
    return "{" + \
        "\\smallskip" +\
        "\\noindent" + \
        "\\bf" + \
        "\\font" + \
        "\\titlefont=cmr12 at 13pt" + \
        "\\titlefont $\\bullet$ " + txt + \
        "}" + \
        "\\smallskip"

def strip(node):
    return " ".join(node.split("/")[-1].split("_"))

def par(txt):
    return txt + "\n\\par\n"

def mkreflookup(nodes):
    id = 0
    lookup = {}
    for node in nodes:
        lookup[node] = "node" + str(id)
        id += 1
    return lookup

def xrdef(ref):
    return "\\xrdef{" + ref + "}"

def xref(ref):
    return "\\xref{" + ref + "}"

def hpair(a, b):
    return a + " \\leaders\\hbox to 10pt {\\hss.\\hss} " + " \\hfill " + b 

def pgbreak():
    return "\\vfill \\break"

def toc(nodes, refs):
    for node in sorted(nodes):
        print("\\noindent",hpair(strip(node), xref(refs[node])))
        print("\\smallskip")
    print(pgbreak())

def logs(node_list, node_objs):
    for node in node_list:
        print(xrdef(refs[node]))
        print(header1(strip(node)))
        objs = node_objs[node]
        dates = []
        date_objs = {}

        # group by date
        for o in objs:
            date = o["date"]
            time = o["time"]
            title = o["title"]
            content = o["content"]
            if date not in date_objs:
                dates.append(date)
                date_objs[date] = []
            date_objs[date].append({
                "time": time,
                "title": title,
                "content": content
            })

        # print dates
        for d in dates:
            print(header2(d))
            for dob in date_objs[d]:
                print(header3(dob["time"] + ": " + dob["title"]))
                for p in dob["content"]:
                    if p != None:
                        print(par(p))

def group_by_date(node_objs):
    dates = {}
    for (key, val) in node_objs.items():
        for chunk in val:
            date = chunk["date"]
            if date not in dates:
                dates[date] = set()
            dates[date].add(key)

    return dates

def timeline(dates):
    print(header1("Timeline"))
    for date in sorted(dates):
        nodes = [ strip(n) for n in sorted(dates[date]) ]
        entry = "{\\noindent \\bf " + date + ":} "
        entry += ", ".join(nodes)
        entry += "\\smallskip"
        #print(date, ", ".join(nodes))
        print(entry)
    print(pgbreak())

all_input = sys.stdin.read()

obj = json.loads(all_input)

node_list = []

node_objs = {}

for entry in obj:
    node = entry["node"]
    if node not in node_objs:
        node_list.append(node)
        node_objs[node] = []

    entity_id = entry["entity_id"]
    date, time = entity_id.split("/")
    content = entry["content"]
    node_objs[node].append({
        "title": entry["title"],
        "date": date,
        "time": time,
        "content" : content
    })

refs = mkreflookup(node_list)

dates = group_by_date(node_objs)

begin()
 
toc(node_list, refs)
timeline(dates)
 
logs(node_list, node_objs)
 
bye()
