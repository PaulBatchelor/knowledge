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

figdims AS (
SELECT
at1.node as node,
at1.value as width,
at2.value as height
FROM dz_attributes as at1, dz_attributes as at2
WHERE at1.key IS 'figw' AND at2.key IS 'figh'
GROUP BY at1.node
),

figs AS (
SELECT
dz_attributes.value as path,
pages.value as page,
CAST(figdims.width AS INTEGER) AS width,
CAST(figdims.height AS INTEGER) AS height
FROM dz_attributes
INNER JOIN dz_nodes ON dz_nodes.id = dz_attributes.node
LEFT JOIN pages ON pages.node = dz_attributes.node
LEFT JOIN figdims ON figdims.node = dz_attributes.node
WHERE
dz_attributes.key IS 'fig'
AND name LIKE '$NAMESPACE'
),

results AS (
SELECT json_object(

'nodes',
(SELECT
json_group_array(json_object(
'value', nodes.value,
'name', nodes.name,
'lines', json(nodes.lines),
'page', nodes.page
))
FROM nodes),

'figs',
(SELECT
json_group_array(json_object(
'path', figs.path,
'page', figs.page,
'width', figs.width,
'height', figs.height
))
FROM figs)

))

SELECT * from results;
;
EOM
