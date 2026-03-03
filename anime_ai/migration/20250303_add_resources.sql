-- 素材库表（用户级，阶段 4 素材库 API）
CREATE TABLE IF NOT EXISTS resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(256) NOT NULL DEFAULT '',
    library_type VARCHAR(32) NOT NULL DEFAULT 'style',
    modality VARCHAR(16) NOT NULL DEFAULT 'visual',
    thumbnail_url VARCHAR(512) DEFAULT '',
    tags_json JSONB DEFAULT '[]'::jsonb,
    version VARCHAR(32) DEFAULT '',
    metadata_json JSONB DEFAULT '{}'::jsonb,
    binding_ids_json JSONB DEFAULT '[]'::jsonb,
    description TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_resources_user_id ON resources (user_id);
CREATE INDEX IF NOT EXISTS idx_resources_modality ON resources (modality);
CREATE INDEX IF NOT EXISTS idx_resources_library_type ON resources (library_type);
CREATE INDEX IF NOT EXISTS idx_resources_deleted_at ON resources (deleted_at);

CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON resources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
