package project

import (
	"anime_ai/pub/middleware"
	"anime_ai/pub/pkg"
)

// ProjectReaderAdapter 将 project.Data 适配为 middleware.ProjectReader（项目 ID 统一为 string）
func ProjectReaderAdapter(data Data) middleware.ProjectReader {
	return &projectReaderAdapter{data: data}
}

type projectReaderAdapter struct {
	data Data
}

func (a *projectReaderAdapter) FindByIDOnly(idStr string) (*middleware.ProjectInfo, error) {
	p, err := a.data.FindByIDOnly(idStr)
	if err != nil {
		return nil, err
	}
	info := &middleware.ProjectInfo{UserID: p.UserID, TeamID: p.TeamID}
	if p.UserIDStr != "" {
		info.UserIDStr = p.UserIDStr
	}
	return info, nil
}

// ProjectMemberReaderAdapter 将 project.Data 适配为 middleware.ProjectMemberReader
func ProjectMemberReaderAdapter(data Data) middleware.ProjectMemberReader {
	return &projectMemberReaderAdapter{data: data}
}

type projectMemberReaderAdapter struct {
	data Data
}

func (a *projectMemberReaderAdapter) FindByProjectAndUser(projectIDStr, userIDStr string) (*middleware.ProjectMemberInfo, error) {
	m, err := a.data.FindMemberByProjectAndUser(projectIDStr, userIDStr)
	if err != nil {
		return nil, err
	}
	return &middleware.ProjectMemberInfo{Role: m.Role}, nil
}

// NoopTeamMemberReader 空实现，团队成员功能尚未完成时使用
type NoopTeamMemberReader struct{}

func (n *NoopTeamMemberReader) FindByTeamAndUser(teamID, userID uint) (*middleware.TeamMemberInfo, error) {
	return nil, pkg.ErrNotFound
}
