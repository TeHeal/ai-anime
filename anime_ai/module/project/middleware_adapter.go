package project

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// ProjectReaderAdapter 将 project.Data 适配为 middleware.ProjectReader
// middleware 使用 uint ID（从 URL 参数解析），Data 使用 string ID
func ProjectReaderAdapter(data Data) middleware.ProjectReader {
	return &projectReaderAdapter{data: data}
}

type projectReaderAdapter struct {
	data Data
}

func (a *projectReaderAdapter) FindByIDOnly(id uint) (*middleware.ProjectInfo, error) {
	idStr := strconv.FormatUint(uint64(id), 10)
	p, err := a.data.FindByIDOnly(idStr)
	if err != nil {
		return nil, err
	}
	return &middleware.ProjectInfo{
		UserID: p.UserID,
		TeamID: p.TeamID,
	}, nil
}

// ProjectMemberReaderAdapter 将 project.Data 适配为 middleware.ProjectMemberReader
func ProjectMemberReaderAdapter(data Data) middleware.ProjectMemberReader {
	return &projectMemberReaderAdapter{data: data}
}

type projectMemberReaderAdapter struct {
	data Data
}

func (a *projectMemberReaderAdapter) FindByProjectAndUser(projectID, userID uint) (*middleware.ProjectMemberInfo, error) {
	pStr := strconv.FormatUint(uint64(projectID), 10)
	uStr := strconv.FormatUint(uint64(userID), 10)
	m, err := a.data.FindMemberByProjectAndUser(pStr, uStr)
	if err != nil {
		return nil, err
	}
	return &middleware.ProjectMemberInfo{Role: m.Role}, nil
}

// NoopTeamMemberReader 空实现，团队成员功能尚未完成时使用
// 始终返回 ErrNotFound，ProjectContext 会回退到项目级权限判断
type NoopTeamMemberReader struct{}

func (n *NoopTeamMemberReader) FindByTeamAndUser(teamID, userID uint) (*middleware.TeamMemberInfo, error) {
	return nil, pkg.ErrNotFound
}
