-- name: CreateProjectMember :one
INSERT INTO project_members (project_id, user_id, role, joined_at)
VALUES (sqlc.arg('project_id'), sqlc.arg('user_id'), COALESCE(sqlc.narg('role'), 'viewer'), sqlc.narg('joined_at'))
RETURNING *;

-- name: GetProjectMemberByProjectAndUser :one
SELECT * FROM project_members
WHERE project_id = sqlc.arg('project_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: ListProjectMembersByProject :many
SELECT * FROM project_members
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY role ASC;

-- name: UpdateProjectMemberRole :one
UPDATE project_members
SET role = COALESCE(sqlc.narg('role'), role)
WHERE project_id = sqlc.arg('project_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteProjectMember :exec
UPDATE project_members
SET deleted_at = now()
WHERE project_id = sqlc.arg('project_id') AND user_id = sqlc.arg('user_id');
