-- 修复：schedules 表缺少 user_id 列（部分环境由旧迁移创建）

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'schedules' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE schedules ADD COLUMN user_id UUID REFERENCES users(id);
    UPDATE schedules s
    SET user_id = (SELECT user_id FROM projects p WHERE p.id = s.project_id AND p.deleted_at IS NULL LIMIT 1)
    WHERE user_id IS NULL;
    UPDATE schedules s
    SET user_id = (SELECT id FROM users WHERE deleted_at IS NULL LIMIT 1)
    WHERE user_id IS NULL;
    DELETE FROM schedules WHERE user_id IS NULL;
    ALTER TABLE schedules ALTER COLUMN user_id SET NOT NULL;
    CREATE INDEX IF NOT EXISTS idx_schedules_user_id ON schedules (user_id);
  END IF;
END $$;
