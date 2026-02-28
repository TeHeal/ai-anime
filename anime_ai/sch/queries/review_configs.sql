-- name: UpsertReviewConfig :one
INSERT INTO review_configs (project_id, phase, mode, ai_model, ai_prompt)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (project_id, phase) DO UPDATE SET mode = $3, ai_model = $4, ai_prompt = $5
RETURNING *;

-- name: GetReviewConfig :one
SELECT * FROM review_configs WHERE project_id = $1 AND phase = $2;

-- name: ListReviewConfigsByProject :many
SELECT * FROM review_configs WHERE project_id = $1 ORDER BY phase;
