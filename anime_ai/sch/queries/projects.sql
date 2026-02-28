-- name: CreateProject :one
INSERT INTO projects (
    user_id, name, story, story_mode, config_json, props_json, storyboard_json,
    mirror_mode, team_id, visibility, version,
    story_locked, story_locked_at, assets_locked, assets_locked_at, script_locked, script_locked_at
)
VALUES (
    sqlc.arg('user_id'), sqlc.arg('name'), sqlc.arg('story'), sqlc.arg('story_mode'),
    COALESCE(sqlc.narg('config_json'), '{}'), COALESCE(sqlc.narg('props_json'), '{}'), COALESCE(sqlc.narg('storyboard_json'), '{}'),
    COALESCE(sqlc.narg('mirror_mode'), true), sqlc.narg('team_id'), COALESCE(sqlc.narg('visibility'), 'private'), COALESCE(sqlc.narg('version'), 1),
    COALESCE(sqlc.narg('story_locked'), false), sqlc.narg('story_locked_at'),
    COALESCE(sqlc.narg('assets_locked'), false), sqlc.narg('assets_locked_at'),
    COALESCE(sqlc.narg('script_locked'), false), sqlc.narg('script_locked_at')
)
RETURNING *;

-- name: GetProjectByID :one
SELECT * FROM projects
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: GetProjectByIDAndUser :one
SELECT * FROM projects
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: ListProjectsByUser :many
SELECT * FROM projects
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
ORDER BY updated_at DESC;

-- name: ListProjectsByUserOrMember :many
SELECT p.* FROM projects p
LEFT JOIN project_members pm ON p.id = pm.project_id AND pm.user_id = sqlc.arg('user_id') AND pm.deleted_at IS NULL
WHERE (p.user_id = sqlc.arg('user_id') OR pm.id IS NOT NULL) AND p.deleted_at IS NULL
ORDER BY p.updated_at DESC;

-- name: UpdateProject :one
UPDATE projects
SET
    name = COALESCE(sqlc.narg('name'), name),
    story = COALESCE(sqlc.narg('story'), story),
    story_mode = COALESCE(sqlc.narg('story_mode'), story_mode),
    config_json = COALESCE(sqlc.narg('config_json'), config_json),
    props_json = COALESCE(sqlc.narg('props_json'), props_json),
    storyboard_json = COALESCE(sqlc.narg('storyboard_json'), storyboard_json),
    mirror_mode = COALESCE(sqlc.narg('mirror_mode'), mirror_mode),
    team_id = COALESCE(sqlc.narg('team_id'), team_id),
    visibility = COALESCE(sqlc.narg('visibility'), visibility),
    version = COALESCE(sqlc.narg('version'), version),
    story_locked = COALESCE(sqlc.narg('story_locked'), story_locked),
    story_locked_at = sqlc.narg('story_locked_at'),
    assets_locked = COALESCE(sqlc.narg('assets_locked'), assets_locked),
    assets_locked_at = sqlc.narg('assets_locked_at'),
    script_locked = COALESCE(sqlc.narg('script_locked'), script_locked),
    script_locked_at = sqlc.narg('script_locked_at')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteProject :exec
UPDATE projects
SET deleted_at = now()
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id');
