-- 审核配置迁移：为项目添加审核模式配置（README §2.2 审核方式可配置）
-- 审核配置存储在 projects.props_json 的 "review_config" 字段中
-- 同时将 review_status 列扩展到 32 字符以支持新的 AI 审核状态

-- 扩展 shots.review_status 以支持 ai_reviewing/ai_approved/ai_rejected/human_review
ALTER TABLE shots ALTER COLUMN review_status TYPE VARCHAR(32);

-- 扩展 shot_images.review_status
ALTER TABLE shot_images ALTER COLUMN review_status TYPE VARCHAR(32);

-- 扩展 shot_videos.review_status
ALTER TABLE shot_videos ALTER COLUMN review_status TYPE VARCHAR(32);

-- 为 review_records 添加 reviewer_type 索引（区分 human/ai 审核来源）
CREATE INDEX IF NOT EXISTS idx_review_records_reviewer_type ON review_records (reviewer_type);
