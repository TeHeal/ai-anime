-- tasks.project_id 改为可空，支持素材库等无项目归属的任务
ALTER TABLE tasks ALTER COLUMN project_id DROP NOT NULL;
