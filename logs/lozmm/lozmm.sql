WITH loztags AS (SELECT * FROM lz_tags
WHERE tag is 'lozmm'),
lozents AS (SELECT * FROM lz_entries
WHERE id IN (SELECT id FROM loztags)
),
lozblocks AS (SELECT parent, json_group_array(content) as content FROM lz_blocks
WHERE parent in (SELECT id FROM lozents)
GROUP BY parent
ORDER BY position
),
loztimes AS (SELECT id, substr(tag, 9) as timelog FROM lz_tags
WHERE id IN (SELECT id FROM loztags)
AND tag like 'timelog:%'
)
SELECT json_object('logs', json_group_array(json_object(
    'id', lz_entities.id,
    'title', lozents.title,
    'content', json(lozblocks.content),
    'timelog', loztimes.timelog
))) from lozblocks
INNER JOIN lozents ON lozblocks.parent = lozents.id
INNER JOIN lz_entities ON lozents.id = lz_entities.rowid
LEFT JOIN loztimes ON loztimes.id = lozents.id
ORDER BY lz_entities.id
;
