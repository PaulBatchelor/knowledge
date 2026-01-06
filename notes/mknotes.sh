if [ "$#" -lt 1 ]
then
    echo "Usage: $0 namespace"
    exit 1
fi

NAMESPACE=$1

sqlite3 a.db <<EOM
WITH pages AS (
    SELECT * FROM dz_attributes
    WHERE key is 'pg'
),
nodes AS (
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
),
nodes_obj AS (
SELECT json_object('nodes',
json_group_array(json_object(
'value', nodes.value,
'name', nodes.name,
'lines', json(nodes.lines),
'page', nodes.page
)),
'figs', 'hello'
)
FROM nodes)
SELECT * from nodes_obj;
;
EOM
