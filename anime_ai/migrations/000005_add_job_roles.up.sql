-- 阶段一权限扩展：project_members 增加 job_roles（README §4 多角色并集）

ALTER TABLE project_members
ADD COLUMN IF NOT EXISTS job_roles JSONB NOT NULL DEFAULT '[]';

COMMENT ON COLUMN project_members.job_roles IS '工种角色数组：director,storyboarder,designer,key_animator,shot_artist,post,reviewer，权限取并集';
