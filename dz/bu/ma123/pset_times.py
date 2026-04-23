import sys
from pprint import pprint

def ts_to_sec(ts):
    if ts[0] == "-": return 0
    ts = ts.split(':')
    ts = [ int(x) for x in ts ]
    if len(ts) == 2:
        return ts[0] * 60 + ts[1]
    if len(ts) == 3:
        return ts[0] * 3600 + ts[1]*60 + ts[2]
    return 0

def sec_to_ts(sec):
    hours = sec // 3600
    sec -= hours*3600
    minutes = (sec) // 60
    sec -= minutes*60
    seconds = sec
    return ":".join([str(x) for x in [hours, minutes, seconds]])

# OLD
pset_time = 0
review_time = 0

# NEW: times by section
cursec = None
ptimes = {}
rtimes = {}
sections = set()

for line in sys.stdin:
    if line[0] == "s":
        args = line.split(" ")
        cursec = args[1].replace("\n", "")
        if cursec not in ptimes:
            ptimes[cursec] = 0
        if cursec not in rtimes:
            rtimes[cursec] = 0
        if cursec not in sections:
            sections.add(cursec)

    if line[0] == "t" or line[0] == "r":
        args = line.split(" ")
        if args[0] == "t":
            pset_time += ts_to_sec(args[4])
            ptimes[cursec] += ts_to_sec(args[4])
        if args[0] == "r":
            review_time += ts_to_sec(args[4])
            rtimes[cursec] += ts_to_sec(args[4])

# print(f"pset time: {sec_to_ts(pset_time)}")
# print(f"pset review time: {sec_to_ts(review_time)}")
# print(f"total pset times: {sec_to_ts(review_time + pset_time)}")

for sec in sorted(sections):
    pset_time = ptimes[sec]
    review_time = rtimes[sec]
    print(sec)
    print(f"pset time: {sec_to_ts(pset_time)}")
    print(f"pset review time: {sec_to_ts(review_time)}")
    print(f"total pset times: {sec_to_ts(review_time + pset_time)}")
    print()
