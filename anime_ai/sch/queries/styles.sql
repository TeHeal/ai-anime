-- name: CreateStyle :one
INSERT INTO styles (project_id, name, description, category, preview_url, prompt_template, negative_prompt, params_json, status, source)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
RETURNING *;

-- name: GetStyle :one
SELECT * FROM styles WHERE id = $1 AND deleted_at IS NULL;

-- name: ListStylesByProject :many
SELECT * FROM styles WHERE project_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC;

-- name: UpdateStyle :exec
UPDATE styles SET name = $2, description = $3, category = $4, preview_url = $5,
    prompt_template = $6, negative_prompt = $7, params_json = $8, status = $9
WHERE id = $1 AND deleted_at IS NULL;

-- name: DeleteStyle :exec
UPDATE styles SET deleted_at = now() WHERE id = $1 AND deleted_at IS NULL;
