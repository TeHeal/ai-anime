-- name: CreateScene :one
INSERT INTO scenes (
    episode_id, scene_id, location, "time", interior_exterior, characters_json, sort_index
)
VALUES (
    sqlc.arg('episode_id'), sqlc.arg('scene_id'), sqlc.arg('location'), sqlc.arg('time'),
    sqlc.arg('interior_exterior'), COALESCE(sqlc.narg('characters_json'), '[]'), sqlc.arg('sort_index')
)
RETURNING *;

-- name: GetSceneByID :one
SELECT * FROM scenes
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListScenesByEpisode :many
SELECT * FROM scenes
WHERE episode_id = sqlc.arg('episode_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: UpdateScene :one
UPDATE scenes
SET
    scene_id = COALESCE(sqlc.narg('scene_id'), scene_id),
    location = COALESCE(sqlc.narg('location'), location),
    "time" = COALESCE(sqlc.narg('time'), "time"),
    interior_exterior = COALESCE(sqlc.narg('interior_exterior'), interior_exterior),
    characters_json = COALESCE(sqlc.narg('characters_json'), characters_json),
    sort_index = COALESCE(sqlc.narg('sort_index'), sort_index)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateSceneSortIndex :exec
UPDATE scenes
SET sort_index = sqlc.arg('sort_index')
WHERE id = sqlc.arg('id') AND episode_id = sqlc.arg('episode_id') AND deleted_at IS NULL;

-- name: SoftDeleteScene :exec
UPDATE scenes
SET deleted_at = now()
WHERE id = sqlc.arg('id');

-- name: SoftDeleteScenesByEpisode :exec
UPDATE scenes
SET deleted_at = now()
WHERE episode_id = sqlc.arg('episode_id');

-- name: CountScenesByEpisode :one
SELECT COUNT(*)::int FROM scenes
WHERE episode_id = sqlc.arg('episode_id') AND deleted_at IS NULL;
