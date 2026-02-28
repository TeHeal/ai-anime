-- 镜头视频 CRUD（每个镜头的视频片段）

-- name: CreateShotVideo :one
INSERT INTO shot_videos (
    shot_id, project_id, shot_image_id, video_url, task_id, status, duration,
    provider, model, params_json, version,
    review_status, review_comment, reviewed_at, reviewed_by
)
VALUES (
    sqlc.arg('shot_id'), sqlc.arg('project_id'), sqlc.narg('shot_image_id'),
    sqlc.arg('video_url'), sqlc.arg('task_id'), COALESCE(sqlc.narg('status'), 'pending'),
    COALESCE(sqlc.narg('duration'), 0), sqlc.arg('provider'), sqlc.arg('model'),
    COALESCE(sqlc.narg('params_json'), '{}'), COALESCE(sqlc.narg('version'), 1),
    sqlc.arg('review_status'), sqlc.arg('review_comment'),
    sqlc.narg('reviewed_at'), sqlc.narg('reviewed_by')
)
RETURNING *;

-- name: GetShotVideoByID :one
SELECT * FROM shot_videos
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListShotVideosByShot :many
SELECT * FROM shot_videos
WHERE shot_id = sqlc.arg('shot_id') AND deleted_at IS NULL
ORDER BY version ASC, created_at ASC;

-- name: ListShotVideosByProject :many
SELECT * FROM shot_videos
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at ASC;

-- name: GetShotVideoByShotPrimary :one
SELECT * FROM shot_videos
WHERE shot_id = sqlc.arg('shot_id') AND deleted_at IS NULL
ORDER BY version DESC
LIMIT 1;

-- name: UpdateShotVideo :one
UPDATE shot_videos
SET
    shot_image_id = sqlc.narg('shot_image_id'),
    video_url = COALESCE(sqlc.narg('video_url'), video_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status),
    duration = COALESCE(sqlc.narg('duration'), duration),
    provider = COALESCE(sqlc.narg('provider'), provider),
    model = COALESCE(sqlc.narg('model'), model),
    params_json = COALESCE(sqlc.narg('params_json'), params_json),
    version = COALESCE(sqlc.narg('version'), version),
    review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotVideoStatus :one
UPDATE shot_videos
SET video_url = COALESCE(sqlc.narg('video_url'), video_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotVideoReview :one
UPDATE shot_videos
SET review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteShotVideo :exec
UPDATE shot_videos SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: SoftDeleteShotVideosByShot :exec
UPDATE shot_videos SET deleted_at = now() WHERE shot_id = sqlc.arg('shot_id');
