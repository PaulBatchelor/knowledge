. ./env
DATE_TODAY=$($DATE +%s)
DATE_START=$($DATE -d $START +%s)
DAY=$(((DATE_TODAY - DATE_START)/86400))
DEADLINE=$($DATE -d "$START + $TOTAL_DAYS days" +%Y-%m-%d)
agenda () {
    echo "gr 0 1 2"
    echo "ls $SCHEDULE"
    echo "d $DAY"
    echo "ag"
}
echo "Day $DAY of $TOTAL_DAYS"
echo "Deadline: $DEADLINE"
agenda | ./run
