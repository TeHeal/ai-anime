package project

import "anime_ai/pub/crossmodule"

// ProjectLockReaderAdapter 将 project.Service 适配为 crossmodule.ProjectLockReader
func ProjectLockReaderAdapter(svc *Service) crossmodule.ProjectLockReader {
	return &projectLockReaderAdapter{svc: svc}
}

type projectLockReaderAdapter struct {
	svc *Service
}

func (a *projectLockReaderAdapter) UpdateLockPhase(projectID, phase string, locked bool) error {
	return a.svc.UpdateLockPhase(projectID, phase, locked)
}

func (a *projectLockReaderAdapter) FindByIDOnly(projectID string) (*crossmodule.ProjectLockInfo, error) {
	p, err := a.svc.FindByIDOnly(projectID)
	if err != nil {
		return nil, err
	}
	return &crossmodule.ProjectLockInfo{AssetsLocked: p.AssetsLocked}, nil
}

var _ crossmodule.ProjectLockReader = (*projectLockReaderAdapter)(nil)
