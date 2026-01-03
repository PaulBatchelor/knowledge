if [ "$#" -lt 1 ]
then
    echo "Usage: $0 namespace"
    exit 1
fi

NAMESPACE=$1

sqlite3 a.db <<EOM
.mode json
WITH pages AS (
    SELECT * FROM dz_attributes
    WHERE key is 'pg'
)
SELECT
dz_attributes.value as value,
name,
lines,
pages.value as page
FROM dz_attributes
INNER JOIN dz_nodes ON dz_nodes.id = dz_attributes.node
LEFT JOIN dz_lines on dz_lines.node = dz_attributes.node
LEFT JOIN pages on pages.node = dz_attributes.node
WHERE
dz_attributes.key IS 'id'
AND name LIKE '$NAMESPACE'
ORDER BY value
;
EOM
