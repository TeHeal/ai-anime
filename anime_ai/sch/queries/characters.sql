-- 角色 CRUD（项目级）

-- name: CreateCharacter :one
INSERT INTO characters (
    project_id, user_id, name, alias_json, appearance, style, style_override,
    personality, voice_hint, emotions, scenes, gender, age_group, voice_id, voice_name,
    image_url, reference_images_json, task_id, image_status, shared, status, source,
    variants_json, importance, consistency, role_type, tags_json, props_json,
    bio, bio_fragments_json, image_gen_override_json, version
)
VALUES (
    sqlc.arg('project_id'), sqlc.arg('user_id'), sqlc.arg('name'),
    COALESCE(sqlc.narg('alias_json'), '[]'), sqlc.arg('appearance'), sqlc.arg('style'),
    COALESCE(sqlc.narg('style_override'), false), sqlc.arg('personality'), sqlc.arg('voice_hint'),
    sqlc.arg('emotions'), sqlc.arg('scenes'), sqlc.arg('gender'), sqlc.arg('age_group'),
    sqlc.arg('voice_id'), sqlc.arg('voice_name'), sqlc.arg('image_url'),
    COALESCE(sqlc.narg('reference_images_json'), '[]'), sqlc.arg('task_id'),
    COALESCE(sqlc.narg('image_status'), 'none'), COALESCE(sqlc.narg('shared'), false),
    COALESCE(sqlc.narg('status'), 'draft'), COALESCE(sqlc.narg('source'), 'manual'),
    COALESCE(sqlc.narg('variants_json'), '[]'), sqlc.arg('importance'), sqlc.arg('consistency'),
    sqlc.arg('role_type'), COALESCE(sqlc.narg('tags_json'), '[]'),
    COALESCE(sqlc.narg('props_json'), '{}'), sqlc.arg('bio'),
    COALESCE(sqlc.narg('bio_fragments_json'), '[]'),
    COALESCE(sqlc.narg('image_gen_override_json'), '{}'),
    COALESCE(sqlc.narg('version'), 1)
)
RETURNING *;

-- name: GetCharacterByID :one
SELECT * FROM characters
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListCharactersByProject :many
SELECT * FROM characters
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at ASC;

-- name: ListCharactersByUser :many
SELECT * FROM characters
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
ORDER BY updated_at DESC;

-- name: ListCharactersByUserWithShared :many
SELECT * FROM characters
WHERE (user_id = sqlc.arg('user_id') OR shared = true) AND deleted_at IS NULL
ORDER BY updated_at DESC;

-- name: GetCharacterByNameAndProject :one
SELECT * FROM characters
WHERE project_id = sqlc.arg('project_id') AND name = sqlc.arg('name') AND deleted_at IS NULL;

-- name: UpdateCharacter :one
UPDATE characters
SET
    name = COALESCE(sqlc.narg('name'), name),
    alias_json = COALESCE(sqlc.narg('alias_json'), alias_json),
    appearance = COALESCE(sqlc.narg('appearance'), appearance),
    style = COALESCE(sqlc.narg('style'), style),
    style_override = COALESCE(sqlc.narg('style_override'), style_override),
    personality = COALESCE(sqlc.narg('personality'), personality),
    voice_hint = COALESCE(sqlc.narg('voice_hint'), voice_hint),
    emotions = COALESCE(sqlc.narg('emotions'), emotions),
    scenes = COALESCE(sqlc.narg('scenes'), scenes),
    gender = COALESCE(sqlc.narg('gender'), gender),
    age_group = COALESCE(sqlc.narg('age_group'), age_group),
    voice_id = COALESCE(sqlc.narg('voice_id'), voice_id),
    voice_name = COALESCE(sqlc.narg('voice_name'), voice_name),
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    reference_images_json = COALESCE(sqlc.narg('reference_images_json'), reference_images_json),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    image_status = COALESCE(sqlc.narg('image_status'), image_status),
    shared = COALESCE(sqlc.narg('shared'), shared),
    status = COALESCE(sqlc.narg('status'), status),
    source = COALESCE(sqlc.narg('source'), source),
    variants_json = COALESCE(sqlc.narg('variants_json'), variants_json),
    importance = COALESCE(sqlc.narg('importance'), importance),
    consistency = COALESCE(sqlc.narg('consistency'), consistency),
    role_type = COALESCE(sqlc.narg('role_type'), role_type),
    tags_json = COALESCE(sqlc.narg('tags_json'), tags_json),
    props_json = COALESCE(sqlc.narg('props_json'), props_json),
    bio = COALESCE(sqlc.narg('bio'), bio),
    bio_fragments_json = COALESCE(sqlc.narg('bio_fragments_json'), bio_fragments_json),
    image_gen_override_json = COALESCE(sqlc.narg('image_gen_override_json'), image_gen_override_json),
    version = COALESCE(sqlc.narg('version'), version)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateCharacterImage :one
UPDATE characters
SET image_url = COALESCE(sqlc.narg('image_url'), image_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    image_status = COALESCE(sqlc.narg('image_status'), image_status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteCharacter :exec
UPDATE characters SET deleted_at = now() WHERE id = sqlc.arg('id');
