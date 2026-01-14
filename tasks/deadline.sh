. ./env
TOTAL_DAYS=$(echo "md" | ./run init.txt)
DATE_TODAY=$($DATE +%s)
DATE_START=$($DATE -d $START +%s)
DAY=$(((DATE_TODAY - DATE_START)/86400))
DEADLINE=$($DATE -d "$START + $TOTAL_DAYS days" +%Y-%m-%d)
echo "Day $DAY of $TOTAL_DAYS"
echo "Deadline: $DEADLINE"
