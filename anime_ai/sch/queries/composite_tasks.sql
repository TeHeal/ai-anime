-- name: CreateCompositeTask :one
INSERT INTO composite_tasks (project_id, episode_id, status, timeline_json, audio_tracks_json,
    subtitle_tracks_json, output_format, resolution, created_by)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- name: GetCompositeTask :one
SELECT * FROM composite_tasks WHERE id = $1;

-- name: ListCompositeTasksByProject :many
SELECT * FROM composite_tasks WHERE project_id = $1 ORDER BY created_at DESC;

-- name: ListCompositeTasksByEpisode :many
SELECT * FROM composite_tasks WHERE episode_id = $1 ORDER BY created_at DESC;

-- name: UpdateCompositeTaskStatus :exec
UPDATE composite_tasks SET status = $2, progress = $3, error_message = $4
WHERE id = $1;

-- name: UpdateCompositeTaskOutput :exec
UPDATE composite_tasks SET status = 'done', output_url = $2, duration = $3, progress = 100, finished_at = now()
WHERE id = $1;

-- name: UpdateCompositeTaskTimeline :exec
UPDATE composite_tasks SET timeline_json = $2, audio_tracks_json = $3, subtitle_tracks_json = $4
WHERE id = $1;

-- name: StartCompositeTask :exec
UPDATE composite_tasks SET status = 'exporting', started_at = now(), progress = 0
WHERE id = $1;
