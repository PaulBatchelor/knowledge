if [ "$#" -lt 2 ]
then
    echo "Usage $0 output [namespace1 namespace2 .. namespaceN]"
    exit 1
fi

OUT=$1

MATCHES="name LIKE '$2'"
shift 2


for ARG in $@
do
    MATCHES="$MATCHES OR name LIKE '$ARG'"
done

# Nodes in the desired namespace(s)
MAIN="main_nodes AS (
    SELECT * FROM dz_nodes
    WHERE
    $MATCHES
)"

# outgoing nodes: all nodes B in A->B where A is from main
OUTGOING_NODES="outgoing_nodes AS (
    SELECT * FROM dz_nodes
    WHERE dz_nodes.id IN (
        SELECT right FROM dz_connections
        WHERE left IN (SELECT main_nodes.id from main_nodes)
    )
)"

# incomig nodes: all nodes A in A->B where B is from main
INCOMING_NODES="incoming_nodes AS (
    SELECT * FROM dz_nodes
    WHERE dz_nodes.id IN (
        SELECT left FROM dz_connections
        WHERE right IN (SELECT main_nodes.id from main_nodes)
    )
)"

# all nodes: union of main, incoming, and outgoing nodes
ALL="all_nodes AS (
    SELECT * from main_nodes
    UNION
    SELECT * from outgoing_nodes
    UNION
    SELECT * from incoming_nodes
)"

# connections: resolves all connections from the all nodes
# set. resolves ids to names
CONNECTIONS="connections AS (
    SELECT
    left as left_id,
    right as right_id,
    rconn.name as right_name,
    lconn.name as left_name
    FROM dz_connections
    INNER JOIN all_nodes AS rconn on rconn.id = dz_connections.right
    INNER JOIN all_nodes AS lconn on lconn.id = dz_connections.left
)"

# aggregate incoming nodes into a JSON array
INCOMING="incoming AS (
    SELECT
    all_nodes.id as id,
    JSON_GROUP_ARRAY(connections.left_name) as nodes
    FROM all_nodes
    INNER JOIN connections ON connections.right_id = all_nodes.id
    GROUP BY all_nodes.id
)"

# aggregate outgoing nodes into JSON array
OUTGOING="outgoing AS (
    SELECT
    all_nodes.id as id,
    JSON_GROUP_ARRAY(connections.right_name) as nodes
    FROM all_nodes
    INNER JOIN connections ON connections.left_id = all_nodes.id
    GROUP BY all_nodes.id
)"

# family: join outgoing and incoming nodes
FAMILY="family AS (
    SELECT
    all_nodes.id AS id,
    all_nodes.name AS name,
    incoming.nodes AS children,
    outgoing.nodes AS parents
    FROM all_nodes
    LEFT JOIN incoming ON incoming.id = all_nodes.id
    LEFT JOIN outgoing ON outgoing.id = all_nodes.id
)"


sqlite3 a.db <<EOM
.mode json
WITH
$MAIN,
$INCOMING_NODES,
$OUTGOING_NODES,
$ALL,
$CONNECTIONS,
$INCOMING,
$OUTGOING,
$FAMILY

SELECT
    all_nodes.name as name,
    all_nodes.id,
    image,
    lines,
    family.children as children,
    family.parents as parents
    FROM all_nodes
    LEFT JOIN dz_images ON dz_images.node = all_nodes.id
    LEFT JOIN dz_lines ON dz_lines.node = all_nodes.id
    LEFT JOIN family ON all_nodes.id = family.id
    ORDER BY all_nodes.name
;
EOM
