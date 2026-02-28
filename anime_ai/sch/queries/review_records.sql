-- 审核记录 CRUD（README 2.2 审核闭环、状态机、反馈给生产 AI）

-- name: CreateReviewRecord :one
INSERT INTO review_records (target_type, target_id, project_id, reviewer_id, reviewer_type, action, comment, feedback_json)
VALUES (
    sqlc.arg('target_type'), sqlc.arg('target_id'), sqlc.arg('project_id'),
    sqlc.narg('reviewer_id'),
    COALESCE(sqlc.narg('reviewer_type'), 'human'),
    sqlc.arg('action'),
    sqlc.narg('comment'),
    COALESCE(sqlc.narg('feedback_json'), '{}')
)
RETURNING *;

-- name: ListReviewRecordsByTarget :many
SELECT * FROM review_records
WHERE target_type = sqlc.arg('target_type') AND target_id = sqlc.arg('target_id')
ORDER BY created_at DESC;
