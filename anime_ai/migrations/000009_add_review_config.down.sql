DROP INDEX IF EXISTS idx_review_records_reviewer_type;
ALTER TABLE shots ALTER COLUMN review_status TYPE VARCHAR(16);
ALTER TABLE shot_images ALTER COLUMN review_status TYPE VARCHAR(16);
ALTER TABLE shot_videos ALTER COLUMN review_status TYPE VARCHAR(16);
