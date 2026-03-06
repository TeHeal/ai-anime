-- 回滚：将无项目任务的 project_id 设为空 UUID 后恢复 NOT NULL
UPDATE tasks SET project_id = '00000000-0000-0000-0000-000000000000' WHERE project_id IS NULL;
ALTER TABLE tasks ALTER COLUMN project_id SET NOT NULL;
