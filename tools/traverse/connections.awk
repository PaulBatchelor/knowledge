#! /usr/bin/awk -f
/^n/ {
    node[$2] = $3
}
/^c/ {
    print (node[$2], node[$3])
}
