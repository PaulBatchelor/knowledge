TRAVERSE=../../tools/traverse/traverse
CONNECTIONS=../../tools/traverse/connections.awk
#DB=../../a.db
DB=a.db
TOP_NODE=thoughts/projects/sonilo/tasks/meaningful_sounds
OUT=tasks.txt

#$TRAVERSE $TOP_NODE $DB | $CONNECTIONS | tsort | xargs -n 1 basename > $OUT
$TRAVERSE $TOP_NODE $DB | $CONNECTIONS | tsort > $OUT
