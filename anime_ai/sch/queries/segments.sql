-- 脚本分段 CRUD（项目级）

-- name: CreateSegment :one
INSERT INTO segments (project_id, sort_index, content)
VALUES (sqlc.arg('project_id'), sqlc.arg('sort_index'), sqlc.arg('content'))
RETURNING *;

-- name: BulkCreateSegments :copyfrom
INSERT INTO segments (project_id, sort_index, content) VALUES ($1, $2, $3);

-- name: GetSegmentByID :one
SELECT * FROM segments
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListSegmentsByProject :many
SELECT * FROM segments
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: UpdateSegment :one
UPDATE segments
SET
    sort_index = COALESCE(sqlc.narg('sort_index'), sort_index),
    content = COALESCE(sqlc.narg('content'), content)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateSegmentSortIndex :exec
UPDATE segments SET sort_index = sqlc.arg('sort_index')
WHERE id = sqlc.arg('id') AND project_id = sqlc.arg('project_id') AND deleted_at IS NULL;

-- name: SoftDeleteSegment :exec
UPDATE segments SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: SoftDeleteSegmentsByProject :exec
UPDATE segments SET deleted_at = now() WHERE project_id = sqlc.arg('project_id');
