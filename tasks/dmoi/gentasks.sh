TRAVERSE=../../tools/traverse/traverse
CONNECTIONS=../../tools/traverse/connections.awk
DB=../../a.db
TOP_NODE=dmoi/toc
OUT=tasks.txt

#$TRAVERSE $TOP_NODE $DB | $CONNECTIONS | tsort | xargs -n 1 basename > $OUT
$TRAVERSE $TOP_NODE $DB | $CONNECTIONS | tsort > $OUT
