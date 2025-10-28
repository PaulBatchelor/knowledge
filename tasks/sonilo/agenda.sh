SCHEDULE="state.txt"
START="2025-10-31"

DATE_TODAY=$(date +%s)
DATE_START=$(date -d $START +%s)
DAY=$(((DATE_TODAY - DATE_START)/86400))
agenda () {
    echo "ls $SCHEDULE"
    echo "d $DAY"
    echo "ag"
}
echo "Day $DAY"
agenda | ./run
