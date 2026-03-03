-- 回滚会丢失 user_id 数据，谨慎执行
ALTER TABLE schedules DROP COLUMN IF EXISTS user_id;
DROP INDEX IF EXISTS idx_schedules_user_id;
