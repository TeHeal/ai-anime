-- name: CreateReviewRecord :one
INSERT INTO review_records (project_id, phase, target_type, target_id, reviewer_type, reviewer_id, status, round)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: GetReviewRecord :one
SELECT * FROM review_records WHERE id = $1;

-- name: ListReviewRecordsByTarget :many
SELECT * FROM review_records WHERE target_type = $1 AND target_id = $2
ORDER BY round DESC, created_at DESC;

-- name: ListReviewRecordsByProject :many
SELECT * FROM review_records WHERE project_id = $1
ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: UpdateReviewRecordDecision :exec
UPDATE review_records SET status = $2, ai_score = $3, ai_reason = $4, human_comment = $5, decided_at = now()
WHERE id = $1;

-- name: CountPendingReviews :one
SELECT count(*) FROM review_records WHERE project_id = $1 AND status = 'pending';
