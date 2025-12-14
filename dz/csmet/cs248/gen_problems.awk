BEGIN {
    FS=":"
    print "ns csmet/cs248/exercises"
}
/^@/ {
    gsub(/\./, "_", $1)
    print "nn " substr($1,2)
    print "ln " $2
}
