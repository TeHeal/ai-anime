-- name: AcquireTaskLock :one
INSERT INTO task_locks (project_id, resource_type, resource_id, action, status, locked_by, locked_at, expires_at)
VALUES ($1, $2, $3, $4, 'running', $5, now(), $6)
RETURNING *;

-- name: ReleaseTaskLock :exec
UPDATE task_locks SET status = 'completed', completed_at = now()
WHERE id = $1 AND status = 'running';

-- name: CancelTaskLock :exec
UPDATE task_locks SET status = 'cancelled', cancelled_at = now()
WHERE id = $1 AND status = 'running';

-- name: GetActiveTaskLock :one
SELECT * FROM task_locks WHERE resource_type = $1 AND resource_id = $2 AND action = $3 AND status = 'running';

-- name: ListTaskLocksByProject :many
SELECT * FROM task_locks WHERE project_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: ExpireTaskLocks :exec
UPDATE task_locks SET status = 'cancelled', cancelled_at = now()
WHERE status = 'running' AND expires_at < now();
