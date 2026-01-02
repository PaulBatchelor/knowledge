if [ "$#" -lt 1 ]
then
    echo "Usage: $0 namespace"
    exit 1
fi

NAMESPACE=$1

sqlite3 a.db <<EOM
.mode json
SELECT
value,
name,
lines
FROM dz_attributes
INNER JOIN dz_nodes ON dz_nodes.id = dz_attributes.node
LEFT JOIN dz_lines on dz_lines.node = dz_attributes.node
WHERE
key IS 'id'
AND name LIKE '$NAMESPACE'
ORDER BY value
;
EOM
