# sqlite3 a.db <<EOM
# .mode line
# SELECT day, title, logid, substr(tag,4) as nodename FROM logtags
# INNER join logs on logs.rowid = logtags.logid
# WHERE nodename NOT in
# (SELECT substr(tag,4) as nodename FROM logtags
# JOIN dz_nodes on dz_nodes.name = nodename
# WHERE
# tag LIKE 'dz:%')
# AND tag LIKE 'dz:%'
# ;
# EOM
sqlite3 a.db <<EOM
.mode line

SELECT day, title, lz_connections.id, node FROM lz_connections
INNER join lz_entries on lz_entries.id = lz_connections.id
WHERE node NOT in
(SELECT node FROM lz_connections
JOIN dz_nodes on dz_nodes.name = node)
;
EOM
