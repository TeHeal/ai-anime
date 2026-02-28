-- 按集打包任务表（README 2.7 生成物下载）
CREATE TABLE IF NOT EXISTS package_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    episode_id UUID NOT NULL REFERENCES episodes(id),
    task_id VARCHAR(64) DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    output_url VARCHAR(512) DEFAULT '',
    config_json JSONB DEFAULT '{}',
    error_msg TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_package_tasks_project_id ON package_tasks (project_id);
CREATE INDEX IF NOT EXISTS idx_package_tasks_episode_id ON package_tasks (episode_id);
CREATE INDEX IF NOT EXISTS idx_package_tasks_deleted_at ON package_tasks (deleted_at);

CREATE TRIGGER update_package_tasks_updated_at BEFORE UPDATE ON package_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
