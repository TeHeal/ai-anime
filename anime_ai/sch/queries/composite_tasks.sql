-- 成片任务 CRUD（README 成片阶段，状态机 editing→exporting→done）

-- name: CreateCompositeTask :one
INSERT INTO composite_tasks (project_id, episode_id, task_id, status, output_url, config_json, error_msg)
VALUES (
    sqlc.arg('project_id'), sqlc.narg('episode_id'), sqlc.narg('task_id'),
    COALESCE(sqlc.narg('status'), 'pending'), sqlc.narg('output_url'),
    COALESCE(sqlc.narg('config_json'), '{}'), sqlc.narg('error_msg')
)
RETURNING *;

-- name: GetCompositeTaskByID :one
SELECT * FROM composite_tasks
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: GetCompositeTaskByTaskID :one
SELECT * FROM composite_tasks
WHERE task_id = sqlc.arg('task_id') AND deleted_at IS NULL;

-- name: ListCompositeTasksByProject :many
SELECT * FROM composite_tasks
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: ListCompositeTasksByEpisode :many
SELECT * FROM composite_tasks
WHERE episode_id = sqlc.arg('episode_id') AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: UpdateCompositeTaskStatus :one
UPDATE composite_tasks
SET status = COALESCE(sqlc.narg('status'), status),
    output_url = COALESCE(sqlc.narg('output_url'), output_url),
    error_msg = sqlc.narg('error_msg')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateCompositeTaskID :exec
UPDATE composite_tasks SET task_id = sqlc.arg('task_id')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: SoftDeleteCompositeTask :exec
UPDATE composite_tasks SET deleted_at = now() WHERE id = sqlc.arg('id');
