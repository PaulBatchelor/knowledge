import json
import sys
from pprint import pprint

pset_filename = sys.argv[1]
solutions_filename = sys.argv[2]
f_pset = open(pset_filename, "w")
f_solutions= open(solutions_filename, "w")

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

def print_content(fp, probid, content):
    print(f"{cmd('vbox')}{cmd('bgroup')}", file=fp)
    print(header(probid.replace("_", ".")), file=fp)
    print(content, file=fp)
    print(cmd('bigskip'), file=fp)
    print(f"{cmd('egroup')}", file=fp)

print(f"{cmd('input')} header", file=f_pset)
print(f"{cmd('input')} header", file=f_solutions)
for p in problems:
    probid = p["probid"]
    content = "\n".join(p["content"])
    solution = "\n".join(p["solution"])
    print_content(f_pset, probid, content)
    print_content(f_solutions, probid, solution)

print(cmd("bye"), file=f_pset)
print(cmd("bye"), file=f_solutions)
