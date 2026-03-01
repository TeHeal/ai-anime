package project

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// NewProjectVerifier 基于 Data 创建验证器，实现 crossmodule.ProjectVerifier 与 ProjectMemberResolver
func NewProjectVerifier(data Data) crossmodule.ProjectVerifier {
	return &projectVerifierImpl{data: data}
}

// NewProjectMemberResolver 基于 Data 创建成员解析器
func NewProjectMemberResolver(data Data) crossmodule.ProjectMemberResolver {
	return &projectVerifierImpl{data: data}
}

type projectVerifierImpl struct {
	data Data
}

func (v *projectVerifierImpl) Verify(projectID, userID string) error {
	_, err := v.data.FindByID(projectID, userID)
	return err
}

func (v *projectVerifierImpl) Resolve(projectID, userID string) (*crossmodule.MemberInfo, error) {
	if err := v.Verify(projectID, userID); err != nil {
		return nil, err
	}
	proj, err := v.data.FindByIDOnly(projectID)
	if err != nil {
		return nil, err
	}
	if proj.UserIDStr == userID {
		return &crossmodule.MemberInfo{IsOwner: true, Role: "owner", JobRoles: []string{"director"}}, nil
	}
	m, err := v.data.FindMemberByProjectAndUser(projectID, userID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return &crossmodule.MemberInfo{IsOwner: false, Role: m.Role, JobRoles: m.JobRoles}, nil
}
