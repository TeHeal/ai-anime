-- 定时任务 CRUD（README 2.1 定时任务、按计划触发流水线）

-- name: CreateSchedule :one
INSERT INTO schedules (project_id, user_id, name, cron_expr, action, config_json, enabled, last_run_at, next_run_at)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('user_id'),
    COALESCE(sqlc.narg('name'), ''),
    sqlc.arg('cron_expr'),
    COALESCE(sqlc.narg('action'), 'pipeline'),
    COALESCE(sqlc.narg('config_json'), '{}'),
    COALESCE(sqlc.narg('enabled'), true),
    sqlc.narg('last_run_at'),
    sqlc.narg('next_run_at')
)
RETURNING *;

-- name: ListSchedulesByProject :many
SELECT * FROM schedules
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: GetScheduleByID :one
SELECT * FROM schedules
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: UpdateSchedule :one
UPDATE schedules
SET
    name = COALESCE(sqlc.narg('name'), name),
    cron_expr = COALESCE(sqlc.narg('cron_expr'), cron_expr),
    action = COALESCE(sqlc.narg('action'), action),
    config_json = COALESCE(sqlc.narg('config_json'), config_json),
    enabled = COALESCE(sqlc.narg('enabled'), enabled),
    last_run_at = sqlc.narg('last_run_at'),
    next_run_at = sqlc.narg('next_run_at')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: DeleteSchedule :exec
UPDATE schedules SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: UpdateScheduleRunTimes :exec
UPDATE schedules SET last_run_at = sqlc.arg('last_run_at'), next_run_at = sqlc.arg('next_run_at')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListDueSchedules :many
SELECT * FROM schedules
WHERE next_run_at <= now() AND enabled = true AND deleted_at IS NULL
ORDER BY next_run_at ASC;
