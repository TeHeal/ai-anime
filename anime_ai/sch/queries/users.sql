-- name: CreateUser :one
INSERT INTO users (username, password_hash, display_name, role)
VALUES (sqlc.arg('username'), sqlc.arg('password_hash'), sqlc.arg('display_name'), sqlc.arg('role'))
RETURNING *;

-- name: GetUserByID :one
SELECT * FROM users
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: GetUserByUsername :one
SELECT * FROM users
WHERE username = sqlc.arg('username') AND deleted_at IS NULL;

-- name: ListUsers :many
SELECT * FROM users
WHERE deleted_at IS NULL
ORDER BY id ASC;

-- name: UpdateUser :one
UPDATE users
SET
    username = COALESCE(sqlc.narg('username'), username),
    password_hash = COALESCE(sqlc.narg('password_hash'), password_hash),
    display_name = COALESCE(sqlc.narg('display_name'), display_name),
    role = COALESCE(sqlc.narg('role'), role)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteUser :exec
UPDATE users
SET deleted_at = now()
WHERE id = sqlc.arg('id');

-- name: ExistsUserByUsername :one
SELECT EXISTS(
    SELECT 1 FROM users
    WHERE username = sqlc.arg('username') AND deleted_at IS NULL
) AS "exists";
