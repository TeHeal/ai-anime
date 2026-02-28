-- 按集打包任务 CRUD（README 2.7）

-- name: CreatePackageTask :one
INSERT INTO package_tasks (project_id, episode_id, task_id, status, output_url, config_json, error_msg)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('episode_id'), sqlc.narg('task_id'),
    COALESCE(sqlc.narg('status'), 'pending'), sqlc.narg('output_url'),
    COALESCE(sqlc.narg('config_json'), '{}'), sqlc.narg('error_msg')
)
RETURNING *;

-- name: GetPackageTaskByID :one
SELECT * FROM package_tasks
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: GetPackageTaskByTaskID :one
SELECT * FROM package_tasks
WHERE task_id = sqlc.arg('task_id') AND deleted_at IS NULL;

-- name: ListPackageTasksByEpisode :many
SELECT * FROM package_tasks
WHERE episode_id = sqlc.arg('episode_id') AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: UpdatePackageTaskStatus :one
UPDATE package_tasks
SET status = COALESCE(sqlc.narg('status'), status),
    output_url = COALESCE(sqlc.narg('output_url'), output_url),
    error_msg = sqlc.narg('error_msg')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdatePackageTaskID :exec
UPDATE package_tasks SET task_id = sqlc.arg('task_id')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;
