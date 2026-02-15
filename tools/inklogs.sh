sqlite3 a.db <<EOM
WITH inktags as
(SELECT distinct(id) as id, tag from lz_tags
WHERE tag LIKE 'ink%')

SELECT 
json_object(
'id', lz_entities.id,
'title', lz_entries.title,
'content',
json_group_array(lz_blocks.content),
'ink', substr(inktags.tag, 5)
)
FROM inktags
INNER JOIN lz_entities ON
lz_entities.rowid = inktags.id
LEFT JOIN lz_blocks ON
lz_blocks.parent = inktags.id
LEFT JOIN lz_entries ON
lz_entries.id = inktags.id
GROUP BY inktags.id
ORDER BY lz_entities.id
;
EOM
