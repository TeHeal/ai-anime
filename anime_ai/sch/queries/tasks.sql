-- name: CreateTask :one
-- 统一任务 CRUD（README §2.1 任务编排，前端任务中心）
INSERT INTO tasks (project_id, user_id, type, status, progress, title, description, config_json, result_json, error_msg)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('user_id'), sqlc.arg('type'),
    COALESCE(sqlc.narg('status'), 'pending'),
    COALESCE(sqlc.narg('progress'), 0),
    COALESCE(sqlc.narg('title'), ''),
    COALESCE(sqlc.narg('description'), ''),
    COALESCE(sqlc.narg('config_json'), '{}'::jsonb),
    COALESCE(sqlc.narg('result_json'), '{}'::jsonb),
    COALESCE(sqlc.narg('error_msg'), '')
)
RETURNING *;

-- name: GetTaskByID :one
SELECT * FROM tasks WHERE id = sqlc.arg('id');

-- name: ListTasksByProject :many
SELECT * FROM tasks
WHERE project_id = sqlc.arg('project_id')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: ListTasksByUser :many
SELECT * FROM tasks
WHERE user_id = sqlc.arg('user_id')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: ListTasksByProjectAndType :many
SELECT * FROM tasks
WHERE project_id = sqlc.arg('project_id') AND type = sqlc.arg('type')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: ListTasksByProjectAndStatus :many
SELECT * FROM tasks
WHERE project_id = sqlc.arg('project_id') AND status = sqlc.arg('status')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: ListTasksByProjectTypeAndStatus :many
SELECT * FROM tasks
WHERE project_id = sqlc.arg('project_id') AND type = sqlc.arg('type') AND status = sqlc.arg('status')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: UpdateTaskStatus :one
UPDATE tasks SET status = sqlc.arg('status'),
    error_msg = COALESCE(sqlc.narg('error_msg'), error_msg),
    started_at = COALESCE(sqlc.narg('started_at'), started_at),
    completed_at = COALESCE(sqlc.narg('completed_at'), completed_at)
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: UpdateTaskProgress :one
UPDATE tasks SET progress = sqlc.arg('progress')
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: UpdateTaskResult :one
UPDATE tasks SET result_json = sqlc.arg('result_json')
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: CancelTask :one
UPDATE tasks SET status = 'cancelled', completed_at = now()
WHERE id = sqlc.arg('id') AND status IN ('pending', 'running')
RETURNING *;

-- name: BatchCancelTasks :exec
UPDATE tasks SET status = 'cancelled', completed_at = now()
WHERE id = ANY(sqlc.arg('ids')::uuid[]) AND status IN ('pending', 'running');

-- name: CountTasksByProject :one
SELECT COUNT(*) FROM tasks WHERE project_id = sqlc.arg('project_id');

-- name: ListTasksByIDs :many
SELECT * FROM tasks WHERE id = ANY(sqlc.arg('ids')::uuid[]) ORDER BY created_at DESC;
