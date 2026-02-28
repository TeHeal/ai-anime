-- name: CreateSceneBlock :one
INSERT INTO scene_blocks (scene_id, type, character, emotion, content, sort_index)
VALUES (
    sqlc.arg('scene_id'), sqlc.arg('type'), sqlc.arg('character'), sqlc.arg('emotion'),
    sqlc.arg('content'), sqlc.arg('sort_index')
)
RETURNING *;

-- name: GetSceneBlockByID :one
SELECT * FROM scene_blocks
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListSceneBlocksByScene :many
SELECT * FROM scene_blocks
WHERE scene_id = sqlc.arg('scene_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: UpdateSceneBlock :one
UPDATE scene_blocks
SET
    type = COALESCE(sqlc.narg('type'), type),
    character = COALESCE(sqlc.narg('character'), character),
    emotion = COALESCE(sqlc.narg('emotion'), emotion),
    content = COALESCE(sqlc.narg('content'), content),
    sort_index = COALESCE(sqlc.narg('sort_index'), sort_index)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateSceneBlockSortIndex :exec
UPDATE scene_blocks
SET sort_index = sqlc.arg('sort_index')
WHERE id = sqlc.arg('id') AND scene_id = sqlc.arg('scene_id') AND deleted_at IS NULL;

-- name: SoftDeleteSceneBlock :exec
UPDATE scene_blocks
SET deleted_at = now()
WHERE id = sqlc.arg('id');

-- name: SoftDeleteSceneBlocksByScene :exec
UPDATE scene_blocks
SET deleted_at = now()
WHERE scene_id = sqlc.arg('scene_id');

-- name: CountSceneBlocksByScene :one
SELECT COUNT(*)::int FROM scene_blocks
WHERE scene_id = sqlc.arg('scene_id') AND deleted_at IS NULL;
