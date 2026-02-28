-- AI 用量统计（README 8.3 AI 成本控制）

-- name: ListProviderUsages :many
SELECT * FROM provider_usages
WHERE
    (sqlc.narg('project_id')::uuid IS NULL OR project_id = sqlc.narg('project_id'))
    AND (sqlc.narg('user_id')::uuid IS NULL OR user_id = sqlc.narg('user_id'))
    AND (sqlc.narg('start_at')::timestamptz IS NULL OR created_at >= sqlc.narg('start_at'))
    AND (sqlc.narg('end_at')::timestamptz IS NULL OR created_at <= sqlc.narg('end_at'))
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CreateProviderUsage :one
INSERT INTO provider_usages (
    project_id, user_id, org_id, provider, model, service_type,
    token_count, image_count, video_seconds, cost_cents, meta_json
)
VALUES (
    sqlc.narg('project_id'), sqlc.narg('user_id'), sqlc.narg('org_id'),
    sqlc.arg('provider'), sqlc.arg('model'), sqlc.arg('service_type'),
    COALESCE(sqlc.narg('token_count'), 0),
    COALESCE(sqlc.narg('image_count'), 0),
    COALESCE(sqlc.narg('video_seconds'), 0),
    COALESCE(sqlc.narg('cost_cents'), 0),
    COALESCE(sqlc.narg('meta_json'), '{}')
)
RETURNING *;
