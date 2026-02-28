-- name: CreateProviderUsage :one
INSERT INTO provider_usages (project_id, user_id, provider, model, capability, input_tokens, output_tokens,
    image_count, video_seconds, audio_seconds, cost_cents, task_id, metadata_json)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
RETURNING *;

-- name: SumUsageByProject :one
SELECT COALESCE(SUM(input_tokens),0)::bigint AS total_input_tokens,
       COALESCE(SUM(output_tokens),0)::bigint AS total_output_tokens,
       COALESCE(SUM(image_count),0)::bigint AS total_images,
       COALESCE(SUM(video_seconds),0)::bigint AS total_video_seconds,
       COALESCE(SUM(cost_cents),0)::bigint AS total_cost_cents
FROM provider_usages WHERE project_id = $1;

-- name: SumUsageByProjectAndProvider :many
SELECT provider, model,
       COALESCE(SUM(input_tokens),0)::bigint AS total_input_tokens,
       COALESCE(SUM(output_tokens),0)::bigint AS total_output_tokens,
       COALESCE(SUM(cost_cents),0)::bigint AS total_cost_cents
FROM provider_usages WHERE project_id = $1
GROUP BY provider, model ORDER BY total_cost_cents DESC;

-- name: ListRecentUsages :many
SELECT * FROM provider_usages WHERE project_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;
