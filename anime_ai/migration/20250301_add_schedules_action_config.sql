-- 修复：schedules 表缺少 action、config_json 列（与 task_type、task_params_json 并存或替代）
-- 若列已存在则跳过

DO $$
BEGIN
  -- 添加 action 列（若不存在）
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'schedules' AND column_name = 'action'
  ) THEN
    ALTER TABLE schedules ADD COLUMN action VARCHAR(64) NOT NULL DEFAULT 'pipeline';
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'schedules' AND column_name = 'task_type') THEN
      UPDATE schedules SET action = task_type WHERE action = 'pipeline';
    END IF;
  END IF;

  -- 添加 config_json 列（若不存在）
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'schedules' AND column_name = 'config_json'
  ) THEN
    ALTER TABLE schedules ADD COLUMN config_json JSONB DEFAULT '{}';
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'schedules' AND column_name = 'task_params_json') THEN
      UPDATE schedules SET config_json = COALESCE(task_params_json, '{}') WHERE config_json IS NULL OR config_json = '{}';
    END IF;
  END IF;
END $$;
