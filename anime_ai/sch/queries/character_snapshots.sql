-- name: CreateCharacterSnapshot :one
INSERT INTO character_snapshots (character_id, project_id, prompt, negative_prompt, image_url, params_json, status)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: GetCharacterSnapshot :one
SELECT * FROM character_snapshots WHERE id = $1 AND deleted_at IS NULL;

-- name: ListCharacterSnapshotsByCharacter :many
SELECT * FROM character_snapshots WHERE character_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC;

-- name: ListCharacterSnapshotsByProject :many
SELECT * FROM character_snapshots WHERE project_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC;

-- name: UpdateCharacterSnapshot :exec
UPDATE character_snapshots SET prompt = $2, negative_prompt = $3, image_url = $4, params_json = $5, status = $6
WHERE id = $1 AND deleted_at IS NULL;

-- name: DeleteCharacterSnapshot :exec
UPDATE character_snapshots SET deleted_at = now() WHERE id = $1 AND deleted_at IS NULL;
