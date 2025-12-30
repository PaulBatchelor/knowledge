#! /usr/bin/awk -f

BEGIN {
    p = 0
}

/^ARCH / {
    start = $2
    end = $3
    h = $4
    w = $5
    j1 = "+j"p; p++
    j2 = "+j"p; p++
    j3 = "+j"p; p++

    print "H", start, j1, 0
    print "V", j2, j1, h
    print "H", j2, j3, w
    print "V", j3, end, h
}

/^H / { print $0 }
/^h / { print $0 }
/^V / { print $0 }
/^v / { print $0 }

/^SEQ / {
    A=$2
    B=$3
    C=$4
    print "H", A, B, 1 
    print "H", B, C, 1 
}

/^PAR / {
    A=$2
    B=$3
    C=$4
    j1="j"p;p++
    j2="j"p;p++
    j3="j"p;p++
    print "H", A, j1, 0
    print "H", j1, B, 0
    print "h", B, C, 1 
    print "V", j2, j1, 0
    print "H", j2, j3, 2
    print "V", j3, C, 0
}
