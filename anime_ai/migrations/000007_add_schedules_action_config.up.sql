-- 修复：schedules 表缺少 action、config_json 列

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'schedules' AND column_name = 'action'
  ) THEN
    ALTER TABLE schedules ADD COLUMN action VARCHAR(64) NOT NULL DEFAULT 'pipeline';
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'schedules' AND column_name = 'task_type') THEN
      UPDATE schedules SET action = task_type WHERE action = 'pipeline';
    END IF;
  END IF;

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
