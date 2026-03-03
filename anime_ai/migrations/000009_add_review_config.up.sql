-- 审核配置迁移：扩展 review_status 列、添加 reviewer_type 索引

ALTER TABLE shots ALTER COLUMN review_status TYPE VARCHAR(32);
ALTER TABLE shot_images ALTER COLUMN review_status TYPE VARCHAR(32);
ALTER TABLE shot_videos ALTER COLUMN review_status TYPE VARCHAR(32);

CREATE INDEX IF NOT EXISTS idx_review_records_reviewer_type ON review_records (reviewer_type);
