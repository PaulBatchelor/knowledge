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
/^INVARCH / {
    start = $2
    end = $3
    h = $4
    w = $5
    j1 = "+j"p; p++
    j2 = "+j"p; p++
    j3 = "+j"p; p++

    print "H", j1, start, 0
    print "V", j1, j2, h
    print "H", j3, j2, w
    print "V", end, j3, h
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

/^VSEQ / {
    A=$2
    B=$3
    C=$4
    print "V", A, B, 1 
    print "V", B, C, 1 
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

/^PAR3 / {
    A=$2
    B=$3
    C=$4
    D=$5
    j1="j"p;p++
    j2="j"p;p++
    j3="j"p;p++
    j4="j"p;p++
    print "H", A, j1, 0
    print "H", j1, B, 0
    print "h", B, C, 1 
    print "V", j2, j1, 0
    print "H", j2, j3, 2
    print "V", j3, C, 0
    print "h", C, D, 1
    print "H", j3, j4, 1
    print "V", j4, D, 0
}

/^VPAR / {
    A=$2
    B=$3
    C=$4
    j1="j"p;p++
    j2="j"p;p++
    j3="j"p;p++
    print "V", A, j1, 0
    print "V", j1, B, 0
    print "v", B, C, 1 
    print "H", j2, j1, 0
    print "V", j2, j3, 2
    print "H", j3, C, 0
}

# SREF create an S-shaped horizontal curve from
# top of A to side of B, horizontal
/^SREFT / {
    A=$2
    B=$3
    j1="j"p;p++
    j2="j"p;p++
    j3="j"p;p++
    j4="j"p;p++
    j5="j"p;p++
    print "v", A, B, 1
    print "V", j1, A, 0
    print "H", j2, j1, 0
    print "V", j2, j3, 1
    print "H", j3, j4, 1
    print "V", j4, j5, 0
    print "H", B, j5, 0
}
