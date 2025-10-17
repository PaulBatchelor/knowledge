.mode tabs
WITH
slides as (SELECT id FROM dz_nodes
WHERE name like 'csmet/cs342/slides/%'),

slide_connections as (SELECT left, right FROM dz_connections
WHERE right IN slides
)

SELECT dz_nodes.name, substr(slide_nodes.name,length('csmet/cs342/slides/') + 1) AS slide_name FROM dz_todo
INNER JOIN dz_nodes ON dz_todo.node = dz_nodes.id
INNER JOIN slide_connections ON dz_todo.node = slide_connections.left
INNER JOIN dz_nodes AS slide_nodes ON slide_connections.right = slide_nodes.id
WHERE dz_todo.node in (SELECT left FROM slide_connections)
ORDER BY slide_name
;
