-- 项目事件流表（任务过程管理：持久化事件、断流恢复、审核追踪）
-- id（BIGSERIAL）即 seq，全局单调递增，零写入竞争
CREATE TABLE project_events (
    id         BIGSERIAL PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    task_id    VARCHAR(64),
    user_id    UUID NOT NULL REFERENCES users(id),
    event_type VARCHAR(64) NOT NULL,
    target_type VARCHAR(32),
    target_id  VARCHAR(64),
    payload    JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_project_events_project ON project_events(project_id, id);
CREATE INDEX idx_project_events_task ON project_events(task_id, id);
CREATE INDEX idx_project_events_user ON project_events(user_id, id);
