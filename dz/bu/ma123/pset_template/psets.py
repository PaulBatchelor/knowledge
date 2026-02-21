import json
import sys
from pprint import pprint

obj = json.loads(sys.stdin.read())

problems = obj["problems"]

def cmd(c):
    return "\\" + c

def header(prob):
    s = f"{{{cmd('bf')} {prob}.}}"
    s += f"{cmd('smallskip')}"
    s += f"{cmd('hrule')}"
    s += f"{cmd('smallskip')}"
    return s

print(f"{cmd('input')} header")
for p in problems:
    probid = p["probid"]
    content = "\n".join(p["content"])
    print(f"{cmd('vbox')}{cmd('bgroup')}")
    print(header(probid.replace("_", ".")))
    print(content)
    print(cmd('bigskip'))
    print(f"{cmd('egroup')}")

print(cmd("bye"))
