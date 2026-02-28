-- name: CreateNotification :one
INSERT INTO notifications (user_id, project_id, type, title, content, ref_type, ref_id)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: ListNotificationsByUser :many
SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: ListUnreadNotifications :many
SELECT * FROM notifications WHERE user_id = $1 AND is_read = false ORDER BY created_at DESC;

-- name: CountUnreadNotifications :one
SELECT count(*) FROM notifications WHERE user_id = $1 AND is_read = false;

-- name: MarkNotificationRead :exec
UPDATE notifications SET is_read = true, read_at = now() WHERE id = $1 AND user_id = $2;

-- name: MarkAllNotificationsRead :exec
UPDATE notifications SET is_read = true, read_at = now() WHERE user_id = $1 AND is_read = false;
