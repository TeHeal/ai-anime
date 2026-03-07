-- name: InsertProjectEvent :one
-- 插入项目事件，返回 id（即 seq）供实时推送附带
INSERT INTO project_events (project_id, task_id, user_id, event_type, target_type, target_id, payload)
VALUES (
    sqlc.narg('project_id'), sqlc.narg('task_id'), sqlc.arg('user_id'),
    sqlc.arg('event_type'),
    sqlc.narg('target_type'), sqlc.narg('target_id'),
    COALESCE(sqlc.narg('payload'), '{}'::jsonb)
)
RETURNING *;

-- name: ListProjectEventsAfter :many
-- 按项目补拉事件（WebSocket 重连后调用）
SELECT * FROM project_events
WHERE project_id = sqlc.arg('project_id') AND id > sqlc.arg('after_id')
ORDER BY id
LIMIT sqlc.arg('lim');

-- name: ListTaskEventsAfter :many
-- 按任务补拉事件（单次执行的过程详情）
SELECT * FROM project_events
WHERE task_id = sqlc.arg('task_id') AND id > sqlc.arg('after_id')
ORDER BY id
LIMIT sqlc.arg('lim');

-- name: ListRecentProjectEvents :many
-- 查询项目内最近 N 条事件（首次连接快照）
SELECT * FROM project_events
WHERE project_id = sqlc.arg('project_id')
ORDER BY id DESC
LIMIT sqlc.arg('lim');

-- name: ListUserEventsAfter :many
-- 按用户补拉无项目归属的事件（素材任务等）
SELECT * FROM project_events
WHERE user_id = sqlc.arg('user_id') AND project_id IS NULL AND id > sqlc.arg('after_id')
ORDER BY id
LIMIT sqlc.arg('lim');

-- name: GetLatestProjectEventID :one
-- 获取项目最新事件 ID（供 WebSocket 连接时返回起点）
SELECT COALESCE(MAX(id), 0)::bigint AS last_id FROM project_events
WHERE project_id = sqlc.arg('project_id');
