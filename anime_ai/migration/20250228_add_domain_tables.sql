-- 增量迁移：补充领域模型表（README §三）
-- Notification、ReviewRecord、Schedule、CompositeTask、AssetVersion、ProviderUsage

-- 通知表
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(32) NOT NULL DEFAULT 'task_complete',
    title VARCHAR(256) NOT NULL DEFAULT '',
    body TEXT DEFAULT '',
    link_url VARCHAR(512) DEFAULT '',
    read_at TIMESTAMPTZ,
    meta_json JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications (read_at) WHERE read_at IS NULL;

-- 审核记录表
CREATE TABLE IF NOT EXISTS review_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    target_type VARCHAR(32) NOT NULL,
    target_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    reviewer_id UUID REFERENCES users(id),
    reviewer_type VARCHAR(16) NOT NULL DEFAULT 'human',
    action VARCHAR(16) NOT NULL,
    comment TEXT DEFAULT '',
    feedback_json JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_review_records_target ON review_records (target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_review_records_project_id ON review_records (project_id);

-- 定时任务表
CREATE TABLE IF NOT EXISTS schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(128) NOT NULL DEFAULT '',
    cron_expr VARCHAR(64) NOT NULL,
    action VARCHAR(64) NOT NULL DEFAULT 'pipeline',
    config_json JSONB DEFAULT '{}',
    enabled BOOLEAN NOT NULL DEFAULT true,
    last_run_at TIMESTAMPTZ,
    next_run_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_schedules_project_id ON schedules (project_id);
CREATE INDEX IF NOT EXISTS idx_schedules_next_run ON schedules (next_run_at) WHERE enabled = true AND deleted_at IS NULL;

-- 成片任务表
CREATE TABLE IF NOT EXISTS composite_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    episode_id UUID REFERENCES episodes(id),
    task_id VARCHAR(64) DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    output_url VARCHAR(512) DEFAULT '',
    config_json JSONB DEFAULT '{}',
    error_msg TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_composite_tasks_project_id ON composite_tasks (project_id);
CREATE INDEX IF NOT EXISTS idx_composite_tasks_episode_id ON composite_tasks (episode_id);
CREATE INDEX IF NOT EXISTS idx_composite_tasks_deleted_at ON composite_tasks (deleted_at);

-- 资产版本表
CREATE TABLE IF NOT EXISTS asset_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    version INT NOT NULL DEFAULT 1,
    action VARCHAR(32) NOT NULL DEFAULT 'freeze',
    stats_json TEXT DEFAULT '',
    delta_json TEXT DEFAULT '',
    note VARCHAR(512) DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_asset_versions_project_id ON asset_versions (project_id);
CREATE INDEX IF NOT EXISTS idx_asset_versions_deleted_at ON asset_versions (deleted_at);

-- AI 用量统计表
CREATE TABLE IF NOT EXISTS provider_usages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID REFERENCES projects(id),
    user_id UUID REFERENCES users(id),
    org_id UUID REFERENCES organizations(id),
    provider VARCHAR(32) NOT NULL,
    model VARCHAR(64) NOT NULL,
    service_type VARCHAR(16) NOT NULL,
    token_count INT DEFAULT 0,
    image_count INT DEFAULT 0,
    video_seconds INT DEFAULT 0,
    cost_cents INT DEFAULT 0,
    meta_json JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_provider_usages_project_id ON provider_usages (project_id);
CREATE INDEX IF NOT EXISTS idx_provider_usages_user_id ON provider_usages (user_id);
CREATE INDEX IF NOT EXISTS idx_provider_usages_created_at ON provider_usages (created_at);

-- 触发器
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_composite_tasks_updated_at BEFORE UPDATE ON composite_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_versions_updated_at BEFORE UPDATE ON asset_versions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
