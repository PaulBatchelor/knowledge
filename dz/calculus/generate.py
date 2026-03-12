import re

fp = open("theorems.tex")

curthm = None

class Theorem:
    def __init__(self, id, title):
        self.title = title
        self.id = id
        self.lines = []

thms = {}
ids = []

for line in fp:
    endthm = re.search(r"^\\endthm", line)
    if endthm:
        curthm = None
        continue

    if curthm:
        thms[curthm].lines.append(line)
        continue

    begthm = re.search(r"^\\begthm{(.*)}{(.*)}", line)
    if begthm:
        thm_id = begthm.group(1)
        thm_title = begthm.group(2)
        curthm = thm_id

        ids.append(curthm)
        thms[curthm] = Theorem(thm_id, thm_title)
        continue

def title_to_name(title):
    name = []
    words = title.split(" ")
    sz = 0
    for w in words:
        if w[0] == "(":
            break
        if w[0] == "$":
            w = w.replace("$", "").replace("^", "_")
        w = re.sub(r'[^[a-zA-Z0-9]', '', w)
        if sz > 25:
            break
        name.append(w.lower())
        sz += len(w)
    return "_".join(name)

node_prefix = "calculus/pearson/theorems"

print(f"ns {node_prefix}")

for id in ids:
    th = thms[id]
    node_name = id.replace(".", "_")
    node_name += "_" + title_to_name(th.title)
    print(f"nn {node_name}")

    # text content
    print(f"ln {th.title}.")
    for line in th.lines:
        line = line.replace("\n","")
        print(f"ln {line}")

    # flashcard
    print(f"ff {th.title}")
    start = False
    for line in th.lines:
        line = line.replace("\n","")


        # anki: use \( \) instead of $
        eqline = re.search(r"^\$\$", line)
        if eqline:
            if not start:
                start = True
                line = "\\("
            else:
                line = "\\)"
                start = False

        line = re.sub(r"\$(.*?)\$", r"\(\1\)", line)

        # any par should be replaced with explicit line breaks
        line = re.sub(r"\\par", "<br><br>", line)

        print(f"fb {line}")
    print()

fp.close()
