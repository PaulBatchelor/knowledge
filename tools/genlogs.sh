LOG=logs/logzet.txt
sqlite3 a.db <<EOM
DROP TABLE IF EXISTS lz_sessions;
DROP TABLE IF EXISTS lz_entities;
DROP TABLE IF EXISTS lz_entries;
DROP TABLE IF EXISTS lz_blocks;
DROP TABLE IF EXISTS lz_connections;
DROP TABLE IF EXISTS lz_tags;
EOM
while read -r LOG
do
    echo $LOG
    logzet $LOG | sqlite3 a.db
done < logfiles.txt
