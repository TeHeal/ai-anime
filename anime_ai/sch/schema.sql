-- AI-Anime PostgreSQL Schema
-- 领域模型：User、Organization、Team、Project、Episode、Scene、SceneBlock
-- 使用 UUID 主键、JSONB、timestamptz

-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    username VARCHAR(64) NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    display_name VARCHAR(64) DEFAULT '',
    role VARCHAR(16) NOT NULL DEFAULT 'member'
);

CREATE UNIQUE INDEX idx_users_username ON users (username) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_deleted_at ON users (deleted_at);

-- 组织表
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    name VARCHAR(128) NOT NULL,
    avatar_url VARCHAR(512) DEFAULT '',
    plan VARCHAR(32) DEFAULT 'free',
    owner_id UUID NOT NULL REFERENCES users(id)
);

CREATE INDEX idx_organizations_owner_id ON organizations (owner_id);
CREATE INDEX idx_organizations_deleted_at ON organizations (deleted_at);

-- 组织成员表
CREATE TABLE org_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    org_id UUID NOT NULL REFERENCES organizations(id),
    user_id UUID NOT NULL REFERENCES users(id),
    role VARCHAR(16) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_org_members_org_user ON org_members (org_id, user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_org_members_deleted_at ON org_members (deleted_at);

-- 团队表
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    org_id UUID NOT NULL REFERENCES organizations(id),
    name VARCHAR(128) NOT NULL,
    description VARCHAR(512) DEFAULT ''
);

CREATE INDEX idx_teams_org_id ON teams (org_id);
CREATE INDEX idx_teams_deleted_at ON teams (deleted_at);

-- 团队成员表
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    team_id UUID NOT NULL REFERENCES teams(id),
    user_id UUID NOT NULL REFERENCES users(id),
    role VARCHAR(16) NOT NULL DEFAULT 'viewer',
    joined_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_team_members_team_user ON team_members (team_id, user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_team_members_deleted_at ON team_members (deleted_at);

-- 项目表
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(128) NOT NULL DEFAULT 'Untitled',
    story TEXT DEFAULT '',
    story_mode VARCHAR(32) DEFAULT '',
    config_json JSONB DEFAULT '{}',
    props_json JSONB DEFAULT '{}',
    storyboard_json JSONB DEFAULT '{}',
    mirror_mode BOOLEAN NOT NULL DEFAULT true,
    team_id UUID REFERENCES teams(id),
    visibility VARCHAR(16) DEFAULT 'private',
    version INT NOT NULL DEFAULT 1,
    story_locked BOOLEAN NOT NULL DEFAULT false,
    story_locked_at TIMESTAMPTZ,
    assets_locked BOOLEAN NOT NULL DEFAULT false,
    assets_locked_at TIMESTAMPTZ,
    script_locked BOOLEAN NOT NULL DEFAULT false,
    script_locked_at TIMESTAMPTZ
);

CREATE INDEX idx_projects_user_id ON projects (user_id);
CREATE INDEX idx_projects_team_id ON projects (team_id);
CREATE INDEX idx_projects_deleted_at ON projects (deleted_at);

-- 项目成员表（团队协作，支持多角色）
CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    user_id UUID NOT NULL REFERENCES users(id),
    role VARCHAR(16) NOT NULL DEFAULT 'viewer',
    roles_json JSONB NOT NULL DEFAULT '["viewer"]',
    joined_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_project_members_project_user ON project_members (project_id, user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_project_members_deleted_at ON project_members (deleted_at);

-- 集表（Episode）
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    title VARCHAR(128) DEFAULT '',
    sort_index INT NOT NULL DEFAULT 0,
    summary TEXT DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'not_started',
    current_step INT NOT NULL DEFAULT 0,
    current_phase VARCHAR(16) NOT NULL DEFAULT 'story',
    last_active_at TIMESTAMPTZ
);

CREATE INDEX idx_episodes_project_id ON episodes (project_id);
CREATE INDEX idx_episodes_deleted_at ON episodes (deleted_at);

-- 场表（Scene）
CREATE TABLE scenes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    episode_id UUID NOT NULL REFERENCES episodes(id),
    scene_id VARCHAR(16) DEFAULT '',
    location VARCHAR(128) DEFAULT '',
    "time" VARCHAR(32) DEFAULT '',
    interior_exterior VARCHAR(8) DEFAULT '',
    characters_json JSONB DEFAULT '[]',
    sort_index INT NOT NULL DEFAULT 0
);

CREATE INDEX idx_scenes_episode_id ON scenes (episode_id);
CREATE INDEX idx_scenes_deleted_at ON scenes (deleted_at);

-- 内容块表（SceneBlock）
CREATE TABLE scene_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    scene_id UUID NOT NULL REFERENCES scenes(id),
    type VARCHAR(16) NOT NULL,
    character VARCHAR(64) DEFAULT '',
    emotion VARCHAR(128) DEFAULT '',
    content TEXT NOT NULL DEFAULT '',
    sort_index INT NOT NULL DEFAULT 0
);

CREATE INDEX idx_scene_blocks_scene_id ON scene_blocks (scene_id);
CREATE INDEX idx_scene_blocks_deleted_at ON scene_blocks (deleted_at);

-- ========== 资产与脚本/镜头 ==========

-- 角色表（项目级，Character）
CREATE TABLE characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(64) NOT NULL,
    alias_json JSONB DEFAULT '[]',
    appearance TEXT DEFAULT '',
    style VARCHAR(64) DEFAULT '',
    style_id UUID,
    style_override BOOLEAN NOT NULL DEFAULT false,
    personality TEXT DEFAULT '',
    voice_hint TEXT DEFAULT '',
    emotions TEXT DEFAULT '',
    scenes TEXT DEFAULT '',
    gender VARCHAR(8) DEFAULT '',
    age_group VARCHAR(16) DEFAULT '',
    voice_id VARCHAR(64) DEFAULT '',
    voice_name VARCHAR(64) DEFAULT '',
    image_url VARCHAR(512) DEFAULT '',
    reference_images_json JSONB DEFAULT '[]',
    task_id VARCHAR(64) DEFAULT '',
    image_status VARCHAR(16) DEFAULT 'none',
    shared BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(16) NOT NULL DEFAULT 'draft',
    source VARCHAR(20) NOT NULL DEFAULT 'manual',
    variants_json JSONB DEFAULT '[]',
    importance VARCHAR(16) DEFAULT '',
    consistency VARCHAR(8) DEFAULT '',
    role_type VARCHAR(16) DEFAULT '',
    tags_json JSONB DEFAULT '[]',
    props_json JSONB DEFAULT '{}',
    bio TEXT DEFAULT '',
    bio_fragments_json JSONB DEFAULT '[]',
    image_gen_override_json JSONB DEFAULT '{}',
    version INT NOT NULL DEFAULT 1
);

CREATE INDEX idx_characters_project_id ON characters (project_id);
CREATE INDEX idx_characters_user_id ON characters (user_id);
CREATE INDEX idx_characters_deleted_at ON characters (deleted_at);
CREATE UNIQUE INDEX idx_characters_project_name ON characters (project_id, name) WHERE deleted_at IS NULL;

-- 脚本分段表（Segment，项目级）
CREATE TABLE segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    sort_index INT NOT NULL DEFAULT 0,
    content TEXT DEFAULT ''
);

CREATE INDEX idx_segments_project_id ON segments (project_id);
CREATE INDEX idx_segments_deleted_at ON segments (deleted_at);

-- 镜头表（Shot，脚本指令，项目级）
CREATE TABLE shots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    segment_id UUID REFERENCES segments(id),
    scene_id UUID REFERENCES scenes(id),
    sort_index INT NOT NULL DEFAULT 0,
    prompt TEXT DEFAULT '',
    style_prompt TEXT DEFAULT '',
    image_url VARCHAR(512) DEFAULT '',
    video_url VARCHAR(512) DEFAULT '',
    task_id VARCHAR(64) DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    duration INT NOT NULL DEFAULT 5,
    camera_type VARCHAR(32) DEFAULT '',
    camera_angle VARCHAR(32) DEFAULT '',
    dialogue TEXT DEFAULT '',
    character_name VARCHAR(64) DEFAULT '',
    character_id UUID REFERENCES characters(id),
    emotion VARCHAR(32) DEFAULT '',
    voice VARCHAR(64) DEFAULT '',
    voice_name VARCHAR(64) DEFAULT '',
    lip_sync VARCHAR(32) DEFAULT '口型同步',
    transition VARCHAR(16) DEFAULT '',
    audio_design TEXT DEFAULT '',
    priority VARCHAR(16) DEFAULT '',
    negative_prompt TEXT DEFAULT '',
    version INT NOT NULL DEFAULT 1,
    locked_by UUID REFERENCES users(id),
    locked_at TIMESTAMPTZ,
    review_status VARCHAR(16) DEFAULT '',
    review_comment TEXT DEFAULT '',
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES users(id)
);

CREATE INDEX idx_shots_project_id ON shots (project_id);
CREATE INDEX idx_shots_segment_id ON shots (segment_id);
CREATE INDEX idx_shots_scene_id ON shots (scene_id);
CREATE INDEX idx_shots_deleted_at ON shots (deleted_at);

-- 镜图表（ShotImage，每个镜头的关键帧图像，支持多候选）
CREATE TABLE shot_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    shot_id UUID NOT NULL REFERENCES shots(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    image_url VARCHAR(512) NOT NULL DEFAULT '',
    task_id VARCHAR(64) DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    provider VARCHAR(32) DEFAULT '',
    model VARCHAR(64) DEFAULT '',
    prompt TEXT DEFAULT '',
    negative_prompt TEXT DEFAULT '',
    params_json JSONB DEFAULT '{}',
    version INT NOT NULL DEFAULT 1,
    review_status VARCHAR(16) DEFAULT '',
    review_comment TEXT DEFAULT '',
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES users(id)
);

CREATE INDEX idx_shot_images_shot_id ON shot_images (shot_id);
CREATE INDEX idx_shot_images_project_id ON shot_images (project_id);
CREATE INDEX idx_shot_images_deleted_at ON shot_images (deleted_at);

-- 镜头视频表（ShotVideo，每个镜头的视频片段）
CREATE TABLE shot_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    shot_id UUID NOT NULL REFERENCES shots(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    shot_image_id UUID REFERENCES shot_images(id),
    video_url VARCHAR(512) NOT NULL DEFAULT '',
    task_id VARCHAR(64) DEFAULT '',
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    duration INT NOT NULL DEFAULT 0,
    provider VARCHAR(32) DEFAULT '',
    model VARCHAR(64) DEFAULT '',
    params_json JSONB DEFAULT '{}',
    version INT NOT NULL DEFAULT 1,
    review_status VARCHAR(16) DEFAULT '',
    review_comment TEXT DEFAULT '',
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES users(id)
);

CREATE INDEX idx_shot_videos_shot_id ON shot_videos (shot_id);
CREATE INDEX idx_shot_videos_project_id ON shot_videos (project_id);
CREATE INDEX idx_shot_videos_deleted_at ON shot_videos (deleted_at);

-- 场景资产表（Location，项目级）
CREATE TABLE locations (
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

CREATE INDEX idx_locations_project_id ON locations (project_id);
CREATE INDEX idx_locations_deleted_at ON locations (deleted_at);

-- 道具资产表（Prop，项目级）
CREATE TABLE props (
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

CREATE INDEX idx_props_project_id ON props (project_id);
CREATE INDEX idx_props_deleted_at ON props (deleted_at);

-- ========== 风格资产 ==========

-- 风格表（Style，项目级）
CREATE TABLE styles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR(128) NOT NULL,
    description TEXT DEFAULT '',
    category VARCHAR(32) DEFAULT '',
    preview_url VARCHAR(512) DEFAULT '',
    prompt_template TEXT DEFAULT '',
    negative_prompt TEXT DEFAULT '',
    params_json JSONB DEFAULT '{}',
    status VARCHAR(16) DEFAULT 'draft',
    source VARCHAR(20) DEFAULT 'manual'
);

CREATE INDEX idx_styles_project_id ON styles (project_id);
CREATE INDEX idx_styles_deleted_at ON styles (deleted_at);

-- ========== 资产版本 ==========

-- 资产版本表（AssetVersion，通用资产版本管理）
CREATE TABLE asset_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    asset_type VARCHAR(32) NOT NULL,
    asset_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    version INT NOT NULL DEFAULT 1,
    snapshot_json JSONB NOT NULL DEFAULT '{}',
    change_note TEXT DEFAULT '',
    created_by UUID NOT NULL REFERENCES users(id)
);

CREATE INDEX idx_asset_versions_asset ON asset_versions (asset_type, asset_id);
CREATE INDEX idx_asset_versions_project ON asset_versions (project_id);

-- ========== 审核体系 ==========

-- 审核配置表（ReviewConfig，按项目+阶段配置审核方式）
CREATE TABLE review_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID NOT NULL REFERENCES projects(id),
    phase VARCHAR(32) NOT NULL,
    mode VARCHAR(16) NOT NULL DEFAULT 'ai',
    ai_model VARCHAR(64) DEFAULT '',
    ai_prompt TEXT DEFAULT '',
    UNIQUE (project_id, phase)
);

-- 审核记录表（ReviewRecord，审核闭环）
CREATE TABLE review_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID NOT NULL REFERENCES projects(id),
    phase VARCHAR(32) NOT NULL,
    target_type VARCHAR(32) NOT NULL,
    target_id UUID NOT NULL,
    reviewer_type VARCHAR(16) NOT NULL DEFAULT 'ai',
    reviewer_id UUID REFERENCES users(id),
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    ai_score INT,
    ai_reason TEXT DEFAULT '',
    human_comment TEXT DEFAULT '',
    round INT NOT NULL DEFAULT 1,
    decided_at TIMESTAMPTZ
);

CREATE INDEX idx_review_records_target ON review_records (target_type, target_id);
CREATE INDEX idx_review_records_project ON review_records (project_id);
CREATE INDEX idx_review_records_status ON review_records (status);

-- ========== 通知系统 ==========

-- 通知表（Notification）
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    user_id UUID NOT NULL REFERENCES users(id),
    project_id UUID REFERENCES projects(id),
    type VARCHAR(32) NOT NULL,
    title VARCHAR(256) NOT NULL,
    content TEXT DEFAULT '',
    ref_type VARCHAR(32) DEFAULT '',
    ref_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMPTZ
);

CREATE INDEX idx_notifications_user ON notifications (user_id, is_read);
CREATE INDEX idx_notifications_project ON notifications (project_id);

-- ========== 成片合成 ==========

-- 成片任务表（CompositeTask）
CREATE TABLE composite_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID NOT NULL REFERENCES projects(id),
    episode_id UUID REFERENCES episodes(id),
    status VARCHAR(16) NOT NULL DEFAULT 'editing',
    timeline_json JSONB DEFAULT '[]',
    audio_tracks_json JSONB DEFAULT '[]',
    subtitle_tracks_json JSONB DEFAULT '[]',
    output_url VARCHAR(512) DEFAULT '',
    output_format VARCHAR(16) DEFAULT 'mp4',
    resolution VARCHAR(16) DEFAULT '1080p',
    duration INT NOT NULL DEFAULT 0,
    progress INT NOT NULL DEFAULT 0,
    error_message TEXT DEFAULT '',
    created_by UUID NOT NULL REFERENCES users(id),
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ
);

CREATE INDEX idx_composite_tasks_project ON composite_tasks (project_id);
CREATE INDEX idx_composite_tasks_episode ON composite_tasks (episode_id);
CREATE INDEX idx_composite_tasks_status ON composite_tasks (status);

-- ========== 任务锁 ==========

-- 任务锁表（TaskLock，防冲突）
CREATE TABLE task_locks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID NOT NULL REFERENCES projects(id),
    resource_type VARCHAR(32) NOT NULL,
    resource_id UUID NOT NULL,
    action VARCHAR(32) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    locked_by UUID REFERENCES users(id),
    locked_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_task_locks_active ON task_locks (resource_type, resource_id, action)
    WHERE status = 'running';
CREATE INDEX idx_task_locks_project ON task_locks (project_id);
CREATE INDEX idx_task_locks_status ON task_locks (status);

-- ========== 定时调度 ==========

-- 调度任务表（Schedule）
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR(128) NOT NULL,
    cron_expr VARCHAR(64) NOT NULL,
    task_type VARCHAR(32) NOT NULL,
    task_params_json JSONB DEFAULT '{}',
    enabled BOOLEAN NOT NULL DEFAULT true,
    last_run_at TIMESTAMPTZ,
    next_run_at TIMESTAMPTZ,
    created_by UUID NOT NULL REFERENCES users(id)
);

CREATE INDEX idx_schedules_project ON schedules (project_id);
CREATE INDEX idx_schedules_enabled ON schedules (enabled, next_run_at);
CREATE INDEX idx_schedules_deleted_at ON schedules (deleted_at);

-- ========== AI 成本控制 ==========

-- AI 用量统计表（ProviderUsage）
CREATE TABLE provider_usages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    project_id UUID REFERENCES projects(id),
    user_id UUID NOT NULL REFERENCES users(id),
    provider VARCHAR(32) NOT NULL,
    model VARCHAR(64) NOT NULL,
    capability VARCHAR(16) NOT NULL,
    input_tokens INT NOT NULL DEFAULT 0,
    output_tokens INT NOT NULL DEFAULT 0,
    image_count INT NOT NULL DEFAULT 0,
    video_seconds INT NOT NULL DEFAULT 0,
    audio_seconds INT NOT NULL DEFAULT 0,
    cost_cents INT NOT NULL DEFAULT 0,
    task_id VARCHAR(64) DEFAULT '',
    metadata_json JSONB DEFAULT '{}'
);

CREATE INDEX idx_provider_usages_project ON provider_usages (project_id);
CREATE INDEX idx_provider_usages_user ON provider_usages (user_id);
CREATE INDEX idx_provider_usages_created ON provider_usages (created_at);

-- ========== 角色快照（已有，补充索引） ==========

-- 角色快照表（CharacterSnapshot，如不存在则创建）
CREATE TABLE IF NOT EXISTS character_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    character_id UUID NOT NULL REFERENCES characters(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    prompt TEXT DEFAULT '',
    negative_prompt TEXT DEFAULT '',
    image_url VARCHAR(512) DEFAULT '',
    params_json JSONB DEFAULT '{}',
    status VARCHAR(16) DEFAULT 'draft'
);

CREATE INDEX IF NOT EXISTS idx_character_snapshots_character ON character_snapshots (character_id);
CREATE INDEX IF NOT EXISTS idx_character_snapshots_project ON character_snapshots (project_id);
CREATE INDEX IF NOT EXISTS idx_character_snapshots_deleted ON character_snapshots (deleted_at);

-- 更新 updated_at 的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为各表添加 updated_at 触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_org_members_updated_at BEFORE UPDATE ON org_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_team_members_updated_at BEFORE UPDATE ON team_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_project_members_updated_at BEFORE UPDATE ON project_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_episodes_updated_at BEFORE UPDATE ON episodes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_scenes_updated_at BEFORE UPDATE ON scenes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_scene_blocks_updated_at BEFORE UPDATE ON scene_blocks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_characters_updated_at BEFORE UPDATE ON characters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_segments_updated_at BEFORE UPDATE ON segments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shots_updated_at BEFORE UPDATE ON shots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shot_images_updated_at BEFORE UPDATE ON shot_images
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shot_videos_updated_at BEFORE UPDATE ON shot_videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_props_updated_at BEFORE UPDATE ON props
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_styles_updated_at BEFORE UPDATE ON styles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_review_configs_updated_at BEFORE UPDATE ON review_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_review_records_updated_at BEFORE UPDATE ON review_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_composite_tasks_updated_at BEFORE UPDATE ON composite_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_task_locks_updated_at BEFORE UPDATE ON task_locks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_character_snapshots_updated_at BEFORE UPDATE ON character_snapshots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
