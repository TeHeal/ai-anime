-- 增量迁移：添加 locations 和 props 表
-- 若已通过 schema.sql 全量应用，可跳过

-- 场景资产表（Location，项目级）
CREATE TABLE IF NOT EXISTS locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR(128) NOT NULL,
    "time" VARCHAR(32) DEFAULT '',
    interior_exterior VARCHAR(8) DEFAULT '',
    atmosphere TEXT DEFAULT '',
    color_tone VARCHAR(128) DEFAULT '',
    layout TEXT DEFAULT '',
    style VARCHAR(64) DEFAULT '',
    style_id UUID,
    style_override BOOLEAN NOT NULL DEFAULT false,
    style_note TEXT DEFAULT '',
    image_url VARCHAR(512) DEFAULT '',
    reference_images_json JSONB DEFAULT '[]',
    task_id VARCHAR(64) DEFAULT '',
    image_status VARCHAR(16) DEFAULT 'none',
    status VARCHAR(16) DEFAULT 'draft',
    source VARCHAR(20) DEFAULT 'manual'
);

CREATE INDEX IF NOT EXISTS idx_locations_project_id ON locations (project_id);
CREATE INDEX IF NOT EXISTS idx_locations_deleted_at ON locations (deleted_at);

-- 道具资产表（Prop，项目级）
CREATE TABLE IF NOT EXISTS props (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR(128) NOT NULL,
    appearance TEXT DEFAULT '',
    is_key_prop BOOLEAN NOT NULL DEFAULT false,
    style VARCHAR(64) DEFAULT '',
    style_id UUID,
    style_override BOOLEAN NOT NULL DEFAULT false,
    reference_images_json JSONB DEFAULT '[]',
    image_url VARCHAR(512) DEFAULT '',
    used_by_json JSONB DEFAULT '[]',
    scenes_json JSONB DEFAULT '[]',
    status VARCHAR(16) DEFAULT 'draft',
    source VARCHAR(20) DEFAULT 'manual'
);

CREATE INDEX IF NOT EXISTS idx_props_project_id ON props (project_id);
CREATE INDEX IF NOT EXISTS idx_props_deleted_at ON props (deleted_at);

-- 触发器
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_props_updated_at BEFORE UPDATE ON props
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
