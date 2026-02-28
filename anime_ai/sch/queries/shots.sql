-- 镜头 CRUD（脚本指令，项目级）

-- name: CreateShot :one
INSERT INTO shots (
    project_id, segment_id, scene_id, sort_index, prompt, style_prompt,
    image_url, video_url, task_id, status, duration, camera_type, camera_angle,
    dialogue, character_name, character_id, emotion, voice, voice_name, lip_sync,
    transition, audio_design, priority, negative_prompt, version,
    locked_by, locked_at, review_status, review_comment, reviewed_at, reviewed_by
)
VALUES (
    sqlc.arg('project_id'), sqlc.narg('segment_id'), sqlc.narg('scene_id'), sqlc.arg('sort_index'),
    sqlc.arg('prompt'), sqlc.arg('style_prompt'), sqlc.arg('image_url'), sqlc.arg('video_url'),
    sqlc.arg('task_id'), COALESCE(sqlc.narg('status'), 'pending'), COALESCE(sqlc.narg('duration'), 5),
    sqlc.arg('camera_type'), sqlc.arg('camera_angle'), sqlc.arg('dialogue'),
    sqlc.arg('character_name'), sqlc.narg('character_id'), sqlc.arg('emotion'),
    sqlc.arg('voice'), sqlc.arg('voice_name'), COALESCE(sqlc.narg('lip_sync'), '口型同步'),
    sqlc.arg('transition'), sqlc.arg('audio_design'), sqlc.arg('priority'),
    sqlc.arg('negative_prompt'), COALESCE(sqlc.narg('version'), 1),
    sqlc.narg('locked_by'), sqlc.narg('locked_at'), sqlc.arg('review_status'),
    sqlc.arg('review_comment'), sqlc.narg('reviewed_at'), sqlc.narg('reviewed_by')
)
RETURNING *;

-- name: GetShotByID :one
SELECT * FROM shots
WHERE id = sqlc.arg('id') AND deleted_at IS NULL;

-- name: ListShotsByProject :many
SELECT * FROM shots
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: ListShotsBySegment :many
SELECT * FROM shots
WHERE segment_id = sqlc.arg('segment_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: ListShotsByScene :many
SELECT * FROM shots
WHERE scene_id = sqlc.arg('scene_id') AND deleted_at IS NULL
ORDER BY sort_index ASC;

-- name: UpdateShot :one
UPDATE shots
SET
    segment_id = COALESCE(sqlc.narg('segment_id'), segment_id),
    scene_id = COALESCE(sqlc.narg('scene_id'), scene_id),
    sort_index = COALESCE(sqlc.narg('sort_index'), sort_index),
    prompt = COALESCE(sqlc.narg('prompt'), prompt),
    style_prompt = COALESCE(sqlc.narg('style_prompt'), style_prompt),
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    video_url = COALESCE(sqlc.narg('video_url'), video_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status),
    duration = COALESCE(sqlc.narg('duration'), duration),
    camera_type = COALESCE(sqlc.narg('camera_type'), camera_type),
    camera_angle = COALESCE(sqlc.narg('camera_angle'), camera_angle),
    dialogue = COALESCE(sqlc.narg('dialogue'), dialogue),
    character_name = COALESCE(sqlc.narg('character_name'), character_name),
    character_id = sqlc.narg('character_id'),
    emotion = COALESCE(sqlc.narg('emotion'), emotion),
    voice = COALESCE(sqlc.narg('voice'), voice),
    voice_name = COALESCE(sqlc.narg('voice_name'), voice_name),
    lip_sync = COALESCE(sqlc.narg('lip_sync'), lip_sync),
    transition = COALESCE(sqlc.narg('transition'), transition),
    audio_design = COALESCE(sqlc.narg('audio_design'), audio_design),
    priority = COALESCE(sqlc.narg('priority'), priority),
    negative_prompt = COALESCE(sqlc.narg('negative_prompt'), negative_prompt),
    version = COALESCE(sqlc.narg('version'), version),
    locked_by = sqlc.narg('locked_by'),
    locked_at = sqlc.narg('locked_at'),
    review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotSortIndex :exec
UPDATE shots SET sort_index = sqlc.arg('sort_index')
WHERE id = sqlc.arg('id') AND project_id = sqlc.arg('project_id') AND deleted_at IS NULL;

-- name: UpdateShotImageResult :one
UPDATE shots
SET image_url = COALESCE(sqlc.narg('image_url'), image_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotVideoResult :one
UPDATE shots
SET video_url = COALESCE(sqlc.narg('video_url'), video_url),
    task_id = COALESCE(sqlc.narg('task_id'), task_id),
    status = COALESCE(sqlc.narg('status'), status)
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: UpdateShotReview :one
UPDATE shots
SET review_status = COALESCE(sqlc.narg('review_status'), review_status),
    review_comment = COALESCE(sqlc.narg('review_comment'), review_comment),
    reviewed_at = sqlc.narg('reviewed_at'),
    reviewed_by = sqlc.narg('reviewed_by')
WHERE id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteShot :exec
UPDATE shots SET deleted_at = now() WHERE id = sqlc.arg('id');

-- name: SoftDeleteShotsByProject :exec
UPDATE shots SET deleted_at = now() WHERE project_id = sqlc.arg('project_id');

-- name: CountShotsByProject :one
SELECT COUNT(*)::int FROM shots
WHERE project_id = sqlc.arg('project_id') AND deleted_at IS NULL;
