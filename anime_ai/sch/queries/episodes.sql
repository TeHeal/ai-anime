-- name: CreateEpisode :one
INSERT INTO episodes (
    project_id, title, sort_index, summary, status, current_step, current_phase, last_active_at
)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('title'), sqlc.arg('sort_index'), sqlc.arg('summary'),
    COALESCE(sqlc.narg('status'), 'not_started'), COALESCE(sqlc.narg('current_step'), 0),
    COALESCE(sqlc.narg('current_phase'), 'story'), sqlc.narg('last_active_at')
)
RETURNING *;

-- name: GetEpisodeByID :one
SELECT * FROM episodes
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListEpisodesByProject :many
SELECT * FROM episodes
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: UpdateEpisode :one
UPDATE episodes
SET
    title = COALESCE(sqlc.narg('title'), title),
    sort_index = COALESCE(sqlc.narg('sort_index'), sort_index),
    summary = COALESCE(sqlc.narg('summary'), summary),
    status = COALESCE(sqlc.narg('status'), status),
    current_step = COALESCE(sqlc.narg('current_step'), current_step),
    current_phase = COALESCE(sqlc.narg('current_phase'), current_phase),
    last_active_at = sqlc.narg('last_active_at')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateEpisodeSortIndex :exec
UPDATE episodes
SET sort_index = sqlc.arg('sort_index')
WHERE id = sqlc.arg('id') AND project_id = sqlc.arg('project_id') AND deleted_at IS NULL;

-- name: SoftDeleteEpisode :exec
UPDATE episodes
SET deleted_at = now()
WHERE id = sqlc.arg('id');

-- name: SoftDeleteEpisodesByProject :exec
UPDATE episodes
SET deleted_at = now()
WHERE project_id = sqlc.arg('project_id');

-- name: CountEpisodesByProject :one
SELECT COUNT(*)::int FROM episodes
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL;
