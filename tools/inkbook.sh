if [ "$#" -lt 1 ]
then
    echo "Usage: $0 NODE_NAME (INKPATH)"
    exit 1
fi

INKPATH="ink"

NODE=$1

if [ "$#" -gt 1 ]
then
INKPATH=$(echo $2)
fi

process() {
    while read -r IMG
    do
        echo "\imgbox{$IMG}"
    done
}

header() {
    echo "\input header"
}

header

sqlite3 a.db <<EOM | process
SELECT image FROM dz_connections
INNER JOIN dz_nodes as rnodes ON dz_connections.right = rnodes.id
INNER JOIN dz_nodes as lnodes ON dz_connections.left = lnodes.id
INNER JOIN dz_images ON dz_connections.left = dz_images.node
WHERE
rnodes.name LIKE '$NODE'
AND
lnodes.name LIKE 'ink/%'
ORDER BY lnodes.name
;
EOM

echo "\bye"
