-- team_members 增加 job_roles 字段，支持团队级工种预设
ALTER TABLE team_members ADD COLUMN IF NOT EXISTS job_roles JSONB NOT NULL DEFAULT '[]';
