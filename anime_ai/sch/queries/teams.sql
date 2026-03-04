-- name: CreateTeam :one
INSERT INTO teams (org_id, name, description)
VALUES (sqlc.arg('org_id'), sqlc.arg('name'), COALESCE(sqlc.narg('description'), ''))
RETURNING *;

-- name: GetTeamByID :one
SELECT * FROM teams
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListTeamsByOrg :many
SELECT * FROM teams
WHERE org_id = sqlc.arg('org_id') AND deleted_at IS NULL
ORDER BY created_at ASC;

-- name: UpdateTeam :one
UPDATE teams
SET name = COALESCE(sqlc.narg('name'), name),
    description = COALESCE(sqlc.narg('description'), description),
    updated_at = now()
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteTeam :exec
UPDATE teams SET deleted_at = now()
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: AddTeamMember :one
INSERT INTO team_members (team_id, user_id, role, job_roles, joined_at)
VALUES (
    sqlc.arg('team_id'),
    sqlc.arg('user_id'),
    COALESCE(sqlc.narg('role'), 'viewer'),
    COALESCE(sqlc.narg('job_roles'), '[]'::jsonb),
    now()
)
RETURNING *;

-- name: GetTeamMember :one
SELECT * FROM team_members
WHERE team_id = sqlc.arg('team_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: ListTeamMembers :many
SELECT tm.*, u.username, u.display_name FROM team_members tm
JOIN users u ON u.id = tm.user_id
WHERE tm.team_id = sqlc.arg('team_id') AND tm.deleted_at IS NULL
ORDER BY tm.created_at ASC;

-- name: UpdateTeamMember :one
UPDATE team_members
SET role = COALESCE(sqlc.narg('role'), role),
    job_roles = COALESCE(sqlc.narg('job_roles'), job_roles),
    updated_at = now()
WHERE team_id = sqlc.arg('team_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL
RETURNING *;

-- name: RemoveTeamMember :exec
UPDATE team_members SET deleted_at = now()
WHERE team_id = sqlc.arg('team_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;
