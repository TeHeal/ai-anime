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
  AND (sqlc.narg('tags_overlap')::jsonb IS NULL OR EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(tags_json) AS a,
         jsonb_array_elements_text(sqlc.narg('tags_overlap')::jsonb) AS b
    WHERE a.value = b.value
  ))
  AND (sqlc.narg('search')::text IS NULL OR sqlc.narg('search')::text = '' OR (
    name ILIKE '%' || sqlc.arg('search') || '%'
    OR description ILIKE '%' || sqlc.arg('search') || '%'
    OR tags_json::text ILIKE '%' || sqlc.arg('search') || '%'
  ))
ORDER BY
  CASE WHEN COALESCE(sqlc.arg('sort_by'), 'newest') = 'oldest' THEN updated_at END ASC NULLS LAST,
  CASE WHEN COALESCE(sqlc.arg('sort_by'), 'newest') = 'newest' THEN updated_at END DESC NULLS LAST,
  CASE WHEN sqlc.arg('sort_by') = 'name_asc' THEN name END ASC NULLS LAST,
  CASE WHEN sqlc.arg('sort_by') = 'name_desc' THEN name END DESC NULLS LAST
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountResourcesByUser :one
SELECT COUNT(*)::bigint FROM resources
WHERE user_id = sqlc.arg('user_id') AND deleted_at IS NULL
  AND (sqlc.narg('modality')::text IS NULL OR modality = sqlc.narg('modality'))
  AND (sqlc.narg('library_type')::text IS NULL OR library_type = sqlc.narg('library_type'))
  AND (sqlc.narg('tags_overlap')::jsonb IS NULL OR EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(tags_json) AS a,
         jsonb_array_elements_text(sqlc.narg('tags_overlap')::jsonb) AS b
    WHERE a.value = b.value
  ))
  AND (sqlc.narg('search')::text IS NULL OR sqlc.narg('search')::text = '' OR (
    name ILIKE '%' || sqlc.arg('search') || '%'
    OR description ILIKE '%' || sqlc.arg('search') || '%'
    OR tags_json::text ILIKE '%' || sqlc.arg('search') || '%'
  ));

-- name: UpdateResource :one
UPDATE resources
SET
    name = COALESCE(sqlc.narg('name'), name),
    library_type = COALESCE(sqlc.narg('library_type'), library_type),
    modality = COALESCE(sqlc.narg('modality'), modality),
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
