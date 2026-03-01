import json
import sys

curated_filename = "curated.txt"

curated = set()
with open(curated_filename) as fp:
    for line in fp:
        probid = line[:-1].replace(".", "_")
        curated.add(probid)

obj = json.loads(sys.stdin.read())

problems = []

for p in obj["problems"]:
    if p["probid"] in curated:
        problems.append(p)

out = {}
out["problems"] = problems

print(json.dumps(out))
