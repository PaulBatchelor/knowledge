function cmd(c) {
    return "\\" c
}

BEGIN {
print cmd("parindent=0pt")
print cmd("pdfpagewidth=148mm")
print cmd("pdfpageheight=210mm")
print cmd("hsize=128mm")
print cmd("vsize=190mm")
print cmd("pdfhorigin=0pt")
print cmd("pdfvorigin=0pt")
print cmd("hoffset=10mm")
print cmd("voffset=10mm")
print cmd("nopagenumbers")
print cmd("def")cmd("problem#1{" cmd("par") "#1" cmd("medskip") "}")
}

{
    problem=$0
    gsub(/_/, ".", problem)
    print cmd("problem{" problem "}")
}

END {
print cmd("bye")
}
