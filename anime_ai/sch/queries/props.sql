-- 道具资产 CRUD（项目级）

-- name: CreateProp :one
INSERT INTO props (
    project_id, name, appearance, is_key_prop, style, style_override,
    image_url, status, source
)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('name'), COALESCE(sqlc.narg('appearance'), ''),
    COALESCE(sqlc.narg('is_key_prop'), false), COALESCE(sqlc.narg('style'), ''),
    COALESCE(sqlc.narg('style_override'), false), COALESCE(sqlc.narg('image_url'), ''),
    COALESCE(sqlc.narg('status'), 'draft'), COALESCE(sqlc.narg('source'), 'manual')
)
RETURNING *;

-- name: GetPropByID :one
SELECT * FROM props
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListPropsByProject :many
SELECT * FROM props
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY name ASC;

-- name: UpdateProp :one
UPDATE props
SET
    name = COALESCE(sqlc.narg('name'), name),
    appearance = COALESCE(sqlc.narg('appearance'), appearance),
    is_key_prop = COALESCE(sqlc.narg('is_key_prop'), is_key_prop),
    style = COALESCE(sqlc.narg('style'), style),
    style_override = COALESCE(sqlc.narg('style_override'), style_override),
    reference_images_json = COALESCE(sqlc.narg('reference_images_json'), reference_images_json),
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    used_by_json = COALESCE(sqlc.narg('used_by_json'), used_by_json),
    scenes_json = COALESCE(sqlc.narg('scenes_json'), scenes_json),
    status = COALESCE(sqlc.narg('status'), status),
    source = COALESCE(sqlc.narg('source'), source)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteProp :exec
UPDATE props SET deleted_at = now() WHERE id = sqlc.arg('id');
