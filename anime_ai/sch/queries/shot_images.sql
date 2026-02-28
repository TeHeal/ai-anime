-- 镜图 CRUD（每个镜头的关键帧图像）

-- name: CreateShotImage :one
INSERT INTO shot_images (
    shot_id, project_id, image_url, task_id, status, provider, model,
    prompt, negative_prompt, params_json, version,
    review_status, review_comment, reviewed_at, reviewed_by
)
VALUES (
    sqlc.arg('shot_id'), sqlc.arg('project_id'), sqlc.arg('image_url'),
    sqlc.arg('task_id'), COALESCE(sqlc.narg('status'), 'pending'),
    sqlc.arg('provider'), sqlc.arg('model'), sqlc.arg('prompt'),
    sqlc.arg('negative_prompt'), COALESCE(sqlc.narg('params_json'), '{}'),
    COALESCE(sqlc.narg('version'), 1), sqlc.arg('review_status'),
    sqlc.arg('review_comment'), sqlc.narg('reviewed_at'), sqlc.narg('reviewed_by')
)
RETURNING *;

-- name: GetShotImageByID :one
SELECT * FROM shot_images
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListShotImagesByShot :many
SELECT * FROM shot_images
WHERE shot_id = sqlc.arg('shot_id') AND deleted_at IS NULL
ORDER BY version ASC, created_at ASC;

-- name: ListShotImagesByProject :many
SELECT * FROM shot_images
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY created_at ASC;

-- name: UpdateShotImage :one
UPDATE shot_images
SET
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status),
    provider = COALESCE(sqlc.narg('provider'), provider),
    model = COALESCE(sqlc.narg('model'), model),
    prompt = COALESCE(sqlc.narg('prompt'), prompt),
    negative_prompt = COALESCE(sqlc.narg('negative_prompt'), negative_prompt),
    params_json = COALESCE(sqlc.narg('params_json'), params_json),
    version = COALESCE(sqlc.narg('version'), version),
    review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotImageStatus :one
UPDATE shot_images
SET image_url = COALESCE(sqlc.narg('image_url'), image_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotImageReview :one
UPDATE shot_images
SET review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteShotImage :exec
UPDATE shot_images SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: SoftDeleteShotImagesByShot :exec
UPDATE shot_images SET deleted_at = now() WHERE shot_id = sqlc.arg('shot_id');
