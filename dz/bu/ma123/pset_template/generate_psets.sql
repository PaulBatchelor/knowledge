WITH problems as (SELECT
    substr(name, length('bu/ma123/problems/') + 1) as probid,
    name,
    lines
    FROM dz_nodes
LEFT JOIN dz_lines on dz_nodes.id = dz_lines.node
WHERE name like 'bu/ma123/problems/%'
),
solutions as (SELECT
    substr(name, length('bu/ma123/solutions/') + 1) as probid,
    lines
    FROM dz_nodes
LEFT JOIN dz_lines on dz_nodes.id = dz_lines.node
WHERE name like 'bu/ma123/solutions/%'
)
SELECT json_object('problems', json_group_array(json_object(
    'probid',
    problems.probid,
    'content', json(problems.lines),
    'solution', json(solutions.lines)
))) FROM problems
INNER JOIN solutions ON problems.probid = solutions.probid
WHERE problems.probid in (SELECT probid from solutions)

