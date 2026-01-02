#! /usr/bin/env python3
import json
import sys
all_input = sys.stdin.read()
objs = json.loads(all_input)

class TextObject:
    def __init__(self, id, name, body):
        self.body = body
        self.id = id 
        self.name = name

data = []
for o in objs:
    body = " ".join(json.loads(o["lines"]))
    txo = TextObject(o["value"], o["name"], body)
    data.append(txo)

for row in data:
    print(row.id, row.body)
