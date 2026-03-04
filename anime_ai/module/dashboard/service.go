package dashboard

import (
	"sort"
	"strconv"
	"time"

	"anime_ai/module/assets/character"
	"anime_ai/module/assets/location"
	"anime_ai/module/episode"
	"anime_ai/module/scene"
	"anime_ai/module/shot"
	"anime_ai/module/shot_image"
	"anime_ai/pub/crossmodule"
)

// Service 仪表盘聚合服务
type Service struct {
	episodeSvc    *episode.Service
	sceneStore    scene.SceneStore
	characterSvc  *character.Service
	locationSvc   *location.Service
	shotStore     shot.ShotStore
	shotImageStore crossmodule.ShotImageStore
	verifier      crossmodule.ProjectVerifier
}

// NewService 创建仪表盘服务
func NewService(
	episodeSvc *episode.Service,
	sceneStore scene.SceneStore,
	characterSvc *character.Service,
	locationSvc *location.Service,
	shotStore shot.ShotStore,
	shotImageStore crossmodule.ShotImageStore,
	verifier crossmodule.ProjectVerifier,
) *Service {
	return &Service{
		episodeSvc:    episodeSvc,
		sceneStore:    sceneStore,
		characterSvc:  characterSvc,
		locationSvc:   locationSvc,
		shotStore:     shotStore,
		shotImageStore: shotImageStore,
		verifier:      verifier,
	}
}

// Get 获取项目仪表盘数据
func (s *Service) Get(projectID, userID string) (*Dashboard, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}

	dash := &Dashboard{
		StatusCounts: map[string]int{},
		PhaseCounts:  map[string]StepCount{},
		Episodes:     []DashboardEpisode{},
	}

	// 集列表
	eps, err := s.episodeSvc.ListByProject(projectID, userID)
	if err != nil {
		return nil, err
	}
	dash.TotalEpisodes = len(eps)

	// 场列表（按 episode 分组）
	scenes, _ := s.sceneStore.ListByProject(projectID)
	scenesByEp := make(map[string][]scene.Scene)
	for _, sc := range scenes {
		scenesByEp[sc.EpisodeID] = append(scenesByEp[sc.EpisodeID], sc)
	}

	// 角色
	chars, _ := s.characterSvc.ListByProject(projectID, userID)
	charTotal := len(chars)
	charConfirmed := 0
	for _, c := range chars {
		if c.Status == character.CharacterStatusConfirmed {
			charConfirmed++
		}
	}
	dash.AssetSummary = &AssetSummary{
		CharactersTotal:     charTotal,
		CharactersConfirmed: charConfirmed,
	}

	// 场景资产
	locs, _ := s.locationSvc.List(projectID, userID)
	locTotal := len(locs)
	locConfirmed := 0
	for _, l := range locs {
		if l.Status == location.LocationStatusConfirmed {
			locConfirmed++
		}
	}
	dash.AssetSummary.LocationsTotal = locTotal
	dash.AssetSummary.LocationsConfirmed = locConfirmed

	// 镜图审核概况
	shotImages, _ := s.shotImageStore.ListByProject(projectID)
	shots, _ := s.shotStore.ListByProject(projectID)
	shotIDSet := make(map[string]bool)
	for _, sh := range shots {
		shotIDSet[sh.ID] = true
	}
	reviewPending := 0
	reviewApproved := 0
	reviewRejected := 0
	for _, img := range shotImages {
		if !shotIDSet[img.ShotID] {
			continue
		}
		switch img.ReviewStatus {
		case shot_image.ReviewStatusApproved:
			reviewApproved++
		case shot_image.ReviewStatusRejected, shot_image.ReviewStatusAIRejected:
			reviewRejected++
		case shot_image.ReviewStatusReview, shot_image.ReviewStatusAIReviewing,
			shot_image.ReviewStatusAIApproved, shot_image.ReviewStatusHumanReview:
			reviewPending++
		}
	}
	dash.ReviewSummary = &ReviewSummary{
		TotalShots:    len(shots),
		PendingReview: reviewPending,
		Approved:      reviewApproved,
		Rejected:      reviewRejected,
	}

	// 状态计数
	for _, ep := range eps {
		dash.StatusCounts[ep.Status]++
	}

	// 阶段计数（简化：按 currentPhase 统计）
	for _, ep := range eps {
		phase := ep.CurrentPhase
		if phase == "" {
			phase = "story"
		}
		pc := dash.PhaseCounts[phase]
		pc.Total++
		if ep.Status == episode.EpisodeStatusCompleted {
			pc.Done++
		}
		dash.PhaseCounts[phase] = pc
	}

	// 集详情
	for _, ep := range eps {
		epID := ep.IDStr
		if epID == "" {
			epID = strconv.FormatUint(uint64(ep.ID), 10)
		}
		epScenes := scenesByEp[epID]
		charNames := []string{}
		seen := make(map[string]bool)
		for _, sc := range epScenes {
			for _, c := range sc.GetCharacters() {
				if c != "" && !seen[c] {
					seen[c] = true
					charNames = append(charNames, c)
				}
			}
		}
		var lastActive, createdAt *time.Time
		if ep.LastActiveAt != nil {
			lastActive = ep.LastActiveAt
		}
		createdAtVal := ep.CreatedAt
		createdAt = &createdAtVal

		progress := s.buildEpisodeProgress(&ep, len(epScenes))
		dash.Episodes = append(dash.Episodes, DashboardEpisode{
			ID:           epID,
			Title:        ep.Title,
			SortIndex:    ep.SortIndex,
			Summary:      ep.Summary,
			Status:       ep.Status,
			CurrentStep:  ep.CurrentStep,
			CurrentPhase: ep.CurrentPhase,
			SceneCount:   len(epScenes),
			CharacterNames: charNames,
			LastActiveAt:  lastActive,
			CreatedAt:    createdAt,
			Progress:     progress,
		})
	}
	sort.Slice(dash.Episodes, func(i, j int) bool {
		return dash.Episodes[i].SortIndex < dash.Episodes[j].SortIndex
	})

	return dash, nil
}

func (s *Service) buildEpisodeProgress(ep *episode.Episode, sceneCount int) *EpisodeProgress {
	projID := ep.ProjectIDStr
	if projID == "" {
		projID = strconv.FormatUint(uint64(ep.ProjectID), 10)
	}
	epID := ep.IDStr
	if epID == "" {
		epID = strconv.FormatUint(uint64(ep.ID), 10)
	}
	pct := 0
	if ep.Status == episode.EpisodeStatusCompleted {
		pct = 100
	} else if ep.Status == episode.EpisodeStatusInProgress {
		pct = ep.CurrentStep * 100 / 6
		if pct > 100 {
			pct = 100
		}
	}
	return &EpisodeProgress{
		ID:           epID,
		EpisodeID:    epID,
		ProjectID:    projID,
		CurrentStep:  ep.CurrentStep,
		CurrentPhase: ep.CurrentPhase,
		OverallPct:   pct,
	}
}
