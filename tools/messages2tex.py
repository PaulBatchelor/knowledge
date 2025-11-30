#! /usr/bin/env python3
import json
import sys
from pprint import pprint

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
    # TODO: try to unwrap this json array before writing to disk
    content = json.loads(entry["content"])
    node_objs[node].append({
        "title": entry["title"],
        "date": date,
        "time": time,
        "content" : content
    })
    # print(node, title)
# pprint(node_list)

def begin():
    print("\\pdfpagewidth=148mm")
    print("\\pdfpageheight=210")

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

begin()
for node in node_list:
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
                print(par(p))

bye()
