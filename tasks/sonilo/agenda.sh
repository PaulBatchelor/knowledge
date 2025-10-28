SCHEDULE="out.txt"
START="2025-10-28"

agenda () {
    DATE_TODAY=$(date +%s)
    DATE_START=$(date -d $START +%s)
    DAY=$(((DATE_TODAY - DATE_START)/86400))
    echo "ls $SCHEDULE"
    echo "d $DAY"
    echo "ag"
}

agenda | ./run
