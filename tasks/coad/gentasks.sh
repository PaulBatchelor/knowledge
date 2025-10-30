TRAVERSE=../../tools/traverse/traverse
CONNECTIONS=../../tools/traverse/connections.awk
#DB=../../a.db
DB=a.db
TOP_NODE=coad/tasks/META/read_the_book
OUT=tasks.txt

> a.db
dagzet ../../dz/coad.dz | sqlite3 a.db
#$TRAVERSE $TOP_NODE $DB | $CONNECTIONS | tsort > $OUT
$TRAVERSE $TOP_NODE a.db | $CONNECTIONS | tsort | grep -v META
