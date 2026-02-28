-- name: CreateNotification :one
INSERT INTO notifications (user_id, type, title, body, link_url, meta_json)
VALUES (
    sqlc.arg('user_id'), COALESCE(sqlc.narg('type'), 'task_complete'),
    sqlc.arg('title'), COALESCE(sqlc.narg('body'), ''),
    sqlc.narg('link_url'), COALESCE(sqlc.narg('meta_json'), '{}')
)
RETURNING *;

-- name: ListNotificationsByUser :many
SELECT * FROM notifications
WHERE user_id = sqlc.arg('user_id')
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountUnreadByUser :one
SELECT COUNT(*) FROM notifications
WHERE user_id = sqlc.arg('user_id') AND read_at IS NULL;

-- name: MarkAsRead :exec
UPDATE notifications SET read_at = now()
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id');

-- name: MarkAllAsReadByUser :exec
UPDATE notifications SET read_at = now()
WHERE user_id = sqlc.arg('user_id') AND read_at IS NULL;
