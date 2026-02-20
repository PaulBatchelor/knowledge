WITH problems as (SELECT
    substr(name, length('bu/ma123/problems/') + 1) as probid FROM dz_nodes
WHERE name like 'bu/ma123/problems/%'
),
solutions as (SELECT
    substr(name, length('bu/ma123/solutions/') + 1) as probid FROM dz_nodes
WHERE name like 'bu/ma123/solutions/%'
)
SELECT probid FROM problems
WHERE probid in (SELECT probid from solutions)

