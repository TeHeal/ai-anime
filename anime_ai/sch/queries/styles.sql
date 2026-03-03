-- 风格 CRUD（项目级，阶段 3）

-- name: CreateStyle :one
INSERT INTO styles (
    project_id, name, description, negative_prompt,
    reference_images_json, thumbnail_url, is_preset, is_project_default
)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('name'),
    COALESCE(sqlc.narg('description'), ''),
    COALESCE(sqlc.narg('negative_prompt'), ''),
    COALESCE(sqlc.narg('reference_images_json'), '[]'::jsonb),
    COALESCE(sqlc.narg('thumbnail_url'), ''),
    COALESCE(sqlc.narg('is_preset'), false),
    COALESCE(sqlc.narg('is_project_default'), false)
)
RETURNING *;

-- name: ListStylesByProject :many
SELECT * FROM styles
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY is_project_default DESC, created_at ASC;

-- name: GetStyleByID :one
SELECT * FROM styles
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: UpdateStyle :one
UPDATE styles
SET
    name = COALESCE(sqlc.narg('name'), name),
    description = COALESCE(sqlc.narg('description'), description),
    negative_prompt = COALESCE(sqlc.narg('negative_prompt'), negative_prompt),
    reference_images_json = COALESCE(sqlc.narg('reference_images_json'), reference_images_json),
    thumbnail_url = COALESCE(sqlc.narg('thumbnail_url'), thumbnail_url),
    is_project_default = COALESCE(sqlc.narg('is_project_default'), is_project_default)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteStyle :exec
UPDATE styles SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: ClearProjectDefault :exec
UPDATE styles SET is_project_default = false
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL;

-- name: SetProjectDefault :exec
UPDATE styles SET is_project_default = true
WHERE id = sqlc.arg('id') AND project_id = sqlc.arg('project_id') AND deleted_at IS NULL;

-- name: ApplyStyleToCharacters :many
UPDATE characters SET style_id = sqlc.arg('style_id'), style = sqlc.arg('style_name'), style_override = false
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
RETURNING id;

-- name: ApplyStyleToLocations :many
UPDATE locations SET style_id = sqlc.arg('style_id'), style = sqlc.arg('style_name'), style_override = false
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
RETURNING id;

-- name: ApplyStyleToProps :many
UPDATE props SET style_id = sqlc.arg('style_id'), style = sqlc.arg('style_name'), style_override = false
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
RETURNING id;
