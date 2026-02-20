function cmd(c) {
    return "\\" c
}

BEGIN {
    print cmd("input header")
}

{
    problem=$0
    gsub(/_/, ".", problem)
    print cmd("problem{" problem "}")
}

END {
print cmd("bye")
}
