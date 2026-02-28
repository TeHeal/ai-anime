-- name: CreateSchedule :one
INSERT INTO schedules (project_id, name, cron_expr, task_type, task_params_json, enabled, next_run_at, created_by)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: GetSchedule :one
SELECT * FROM schedules WHERE id = $1 AND deleted_at IS NULL;

-- name: ListSchedulesByProject :many
SELECT * FROM schedules WHERE project_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC;

-- name: ListDueSchedules :many
SELECT * FROM schedules WHERE enabled = true AND deleted_at IS NULL AND next_run_at <= now()
ORDER BY next_run_at;

-- name: UpdateSchedule :exec
UPDATE schedules SET name = $2, cron_expr = $3, task_type = $4, task_params_json = $5, enabled = $6
WHERE id = $1 AND deleted_at IS NULL;

-- name: UpdateScheduleLastRun :exec
UPDATE schedules SET last_run_at = now(), next_run_at = $2
WHERE id = $1;

-- name: DeleteSchedule :exec
UPDATE schedules SET deleted_at = now() WHERE id = $1 AND deleted_at IS NULL;
