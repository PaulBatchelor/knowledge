#! /usr/bin/awk -f
BEGIN {
    szx=25
    szy=15
    xpad=1
    ypad=1
    ndw=szx - xpad*2
    ndh=szy - ypad*2
    midx=int(szx/2)
    midy=int(szy/2)
    dotsz=3
    ndx=int((szx - ndw)/2)
}

/^NODE /{
    txt = $2
    slen = $3
    x = $4
    y = $5
    txty = 3
    txtx = (ndw - (slen*8)) / 2
    print x*szx + ndx, y*szy + midy - int(ndh/2), ndw, ndh, "rc"
    print x*szx + ndx + txtx, y*szy + midy - int(ndh/2) + txty, txt, "tx"
}

/^HLINE /{
    x = $3
    y = $4
    d = $5
    print (x + 1)*szx, y*szy + midy, d*szx, "hl"
}

/^VLINE /{
    x = $3
    y = $4
    d = $5
    print x*szx + midx, (y + 1)*szy, d*szy, "vl"
}

/^OVERLAY /{
    type = $3
    x = $4
    y = $5
    port = $6

    if (type == "J") {
        if (port == "E") {
            print x*szx + midx, y*szy + midy, midx + 1, "hl"
        } else if (port == "N") {
            print x*szx + midx, y*szy, midy + 1, "vl"
        } else if (port == "W") {
            print x*szx, y*szy + midy, midx + 1, "hl"
        } else if (port == "S") {
            print x*szx + midx, y*szy + midy, midy + 1, "vl"
        }
    } else if (type == "N") {
        if (port == "E") {
            #print (x + 1)*szx - 3, y*szy + 4, 3, 3, "rf"
            print x*szx + xpad + ndw - 2, y*szy + int((szy - dotsz)/2), dotsz, dotsz, "rf"
        } else if (port == "N") {
            print x*szx + midx, y*szy, 2, "vl"
        } else if (port == "W") {
            print x*szx, y*szy + midy, 2, "hl"
        } else if (port == "S") {
            print x*szx + int((szx - 3)/2), (y + 1)*szy - dotsz, dotsz, dotsz, "rf"
        }

    }
}

/^BOUNDS /{
    w = $2
    h = $3
    print w*szx, h*szy, "sz"
}
