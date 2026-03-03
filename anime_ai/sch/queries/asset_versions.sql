-- name: CreateAssetVersion :one
INSERT INTO asset_versions (project_id, version, action, stats_json, delta_json, note)
VALUES (
    sqlc.arg('project_id'), COALESCE(sqlc.narg('version'), 1),
    COALESCE(sqlc.narg('action'), 'freeze'),
    COALESCE(sqlc.narg('stats_json'), ''),
    COALESCE(sqlc.narg('delta_json'), ''),
    sqlc.narg('note')
)
RETURNING *;

-- name: ListAssetVersionsByProject :many
SELECT * FROM asset_versions
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: GetLatestFreezeByProject :one
SELECT * FROM asset_versions
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL AND action = 'freeze'
ORDER BY created_at DESC
LIMIT 1;
