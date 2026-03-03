-- 素材库 CRUD（用户级）

-- name: CreateResource :one
INSERT INTO resources (
    user_id, name, library_type, modality, thumbnail_url,
    tags_json, version, metadata_json, binding_ids_json, description
)
VALUES (
    sqlc.arg('user_id'), sqlc.arg('name'), sqlc.arg('library_type'), sqlc.arg('modality'),
    COALESCE(sqlc.narg('thumbnail_url'), ''),
    COALESCE(sqlc.narg('tags_json'), '[]'::jsonb),
    COALESCE(sqlc.narg('version'), ''),
    COALESCE(sqlc.narg('metadata_json'), '{}'::jsonb),
    COALESCE(sqlc.narg('binding_ids_json'), '[]'::jsonb),
    COALESCE(sqlc.narg('description'), '')
)
RETURNING *;

-- name: GetResourceByID :one
SELECT * FROM resources
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: GetResourceByIDAndUser :one
SELECT * FROM resources
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: ListResourcesByUser :many
SELECT * FROM resources
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
  AND (sqlc.narg('modality')::text IS NULL OR modality = sqlc.narg('modality'))
  AND (sqlc.narg('library_type')::text IS NULL OR library_type = sqlc.narg('library_type'))
  AND (sqlc.narg('tags_overlap')::jsonb IS NULL OR tags_json && sqlc.narg('tags_overlap')::jsonb)
ORDER BY updated_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountResourcesByUser :one
SELECT COUNT(*)::bigint FROM resources
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
  AND (sqlc.narg('modality')::text IS NULL OR modality = sqlc.narg('modality'))
  AND (sqlc.narg('library_type')::text IS NULL OR library_type = sqlc.narg('library_type'))
  AND (sqlc.narg('tags_overlap')::jsonb IS NULL OR tags_json && sqlc.narg('tags_overlap')::jsonb);

-- name: UpdateResource :one
UPDATE resources
SET
    name = COALESCE(sqlc.narg('name'), name),
    thumbnail_url = COALESCE(sqlc.narg('thumbnail_url'), thumbnail_url),
    tags_json = COALESCE(sqlc.narg('tags_json'), tags_json),
    version = COALESCE(sqlc.narg('version'), version),
    metadata_json = COALESCE(sqlc.narg('metadata_json'), metadata_json),
    binding_ids_json = COALESCE(sqlc.narg('binding_ids_json'), binding_ids_json),
    description = COALESCE(sqlc.narg('description'), description)
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteResource :exec
UPDATE resources SET deleted_at = now()
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id') AND deleted_at IS NULL;

-- name: CountResourcesByLibraryType :many
SELECT library_type, COUNT(*)::bigint as count
FROM resources
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
  AND (sqlc.narg('modality')::text IS NULL OR modality = sqlc.narg('modality'))
GROUP BY library_type;
