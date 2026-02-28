package project

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// NewProjectVerifier 基于 Data 创建验证器，实现 crossmodule.ProjectVerifier
func NewProjectVerifier(data Data) crossmodule.ProjectVerifier {
	return &projectVerifierImpl{data: data}
}

type projectVerifierImpl struct {
	data Data
}

func (v *projectVerifierImpl) Verify(projectID, userID string) error {
	_, err := v.data.FindByID(projectID, userID)
	if err != nil && errors.Is(err, ErrProjectNotFound) {
		return pkg.ErrNotFound
	}
	return err
}
