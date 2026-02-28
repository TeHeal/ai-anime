-- 场景资产 CRUD（项目级）

-- name: CreateLocation :one
INSERT INTO locations (
    project_id, name, "time", interior_exterior, atmosphere, color_tone,
    layout, style, style_override, style_note, image_status, status, source
)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('name'), COALESCE(sqlc.narg('time'), ''),
    COALESCE(sqlc.narg('interior_exterior'), ''), COALESCE(sqlc.narg('atmosphere'), ''),
    COALESCE(sqlc.narg('color_tone'), ''), COALESCE(sqlc.narg('layout'), ''),
    COALESCE(sqlc.narg('style'), ''), COALESCE(sqlc.narg('style_override'), false),
    COALESCE(sqlc.narg('style_note'), ''), COALESCE(sqlc.narg('image_status'), 'none'),
    COALESCE(sqlc.narg('status'), 'draft'), COALESCE(sqlc.narg('source'), 'manual')
)
RETURNING *;

-- name: GetLocationByID :one
SELECT * FROM locations
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListLocationsByProject :many
SELECT * FROM locations
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY name ASC;

-- name: UpdateLocation :one
UPDATE locations
SET
    name = COALESCE(sqlc.narg('name'), name),
    "time" = COALESCE(sqlc.narg('time'), "time"),
    interior_exterior = COALESCE(sqlc.narg('interior_exterior'), interior_exterior),
    atmosphere = COALESCE(sqlc.narg('atmosphere'), atmosphere),
    color_tone = COALESCE(sqlc.narg('color_tone'), color_tone),
    layout = COALESCE(sqlc.narg('layout'), layout),
    style = COALESCE(sqlc.narg('style'), style),
    style_override = COALESCE(sqlc.narg('style_override'), style_override),
    style_note = COALESCE(sqlc.narg('style_note'), style_note),
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    reference_images_json = COALESCE(sqlc.narg('reference_images_json'), reference_images_json),
    status = COALESCE(sqlc.narg('status'), status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateLocationImage :one
UPDATE locations
SET image_url = COALESCE(sqlc.narg('image_url'), image_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    image_status = COALESCE(sqlc.narg('image_status'), image_status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteLocation :exec
UPDATE locations SET deleted_at = now() WHERE id = sqlc.arg('id');
