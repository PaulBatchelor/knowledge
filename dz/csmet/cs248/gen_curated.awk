BEGIN {
    print "nn curated"
    print "ln Curated exercises that I worked on"
}
{
    gsub(/\./, "_", $1)
    print "co", $1, "$"
}
