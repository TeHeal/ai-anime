-- 风格表（项目级，阶段 3 风格 API）

CREATE TABLE IF NOT EXISTS styles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR(128) NOT NULL,
    description TEXT DEFAULT '',
    negative_prompt TEXT DEFAULT '',
    reference_images_json JSONB DEFAULT '[]'::jsonb,
    thumbnail_url VARCHAR(512) DEFAULT '',
    is_preset BOOLEAN NOT NULL DEFAULT false,
    is_project_default BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_styles_project_id ON styles (project_id);
CREATE INDEX IF NOT EXISTS idx_styles_deleted_at ON styles (deleted_at);

DROP TRIGGER IF EXISTS update_styles_updated_at ON styles;
CREATE TRIGGER update_styles_updated_at BEFORE UPDATE ON styles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
