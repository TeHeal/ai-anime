-- name: CreateOrganization :one
INSERT INTO organizations (name, avatar_url, plan, owner_id)
VALUES (
    sqlc.arg('name'),
    COALESCE(sqlc.narg('avatar_url'), ''),
    COALESCE(sqlc.narg('plan'), 'free'),
    sqlc.arg('owner_id')
)
RETURNING *;

-- name: GetOrgByID :one
SELECT * FROM organizations
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListOrgsByUser :many
SELECT o.* FROM organizations o
JOIN org_members om ON om.org_id = o.id AND om.deleted_at IS NULL
WHERE om.user_id = sqlc.arg('user_id') AND o.deleted_at IS NULL
UNION
SELECT o.* FROM organizations o
WHERE o.owner_id = sqlc.arg('user_id') AND o.deleted_at IS NULL
ORDER BY created_at DESC;

-- name: UpdateOrganization :one
UPDATE organizations
SET name = COALESCE(sqlc.narg('name'), name),
    avatar_url = COALESCE(sqlc.narg('avatar_url'), avatar_url),
    plan = COALESCE(sqlc.narg('plan'), plan)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: DeleteOrganization :exec
UPDATE organizations SET deleted_at = now()
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: AddOrgMember :one
INSERT INTO org_members (org_id, user_id, role, joined_at)
VALUES (
    sqlc.arg('org_id'),
    sqlc.arg('user_id'),
    COALESCE(sqlc.narg('role'), 'member'),
    now()
)
RETURNING *;

-- name: ListOrgMembers :many
SELECT om.*, u.username, u.display_name FROM org_members om
JOIN users u ON u.id = om.user_id
WHERE om.org_id = sqlc.arg('org_id') AND om.deleted_at IS NULL
ORDER BY om.created_at ASC;

-- name: RemoveOrgMember :exec
UPDATE org_members SET deleted_at = now()
WHERE org_id = sqlc.arg('org_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: GetOrgMember :one
SELECT * FROM org_members
WHERE org_id = sqlc.arg('org_id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;
