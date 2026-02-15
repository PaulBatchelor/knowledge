#!/usr/bin/awk -f
BEGIN {
    chapters["2_5"] = "02_limits/05_limits_at_infinity"
    chapters["2_4"] = "02_limits/04_infinite_limits"
}
/^#! p/ {
    #print $0
    prob = $3
    gsub(/\./, "_", prob)
    print "#! dz bu/ma123/problems/" prob
    next
}
/^#! e/ {
    section = $3
    example = $4
    gsub(/\./, "_", section)
    printf("#! dz calculus/pearson/examples/%s_%02d\n", section, example)
    printf("#! dz calculus/pearson/toc/%s\n", chapters[section])
    next
}
{
    print $0
}
