package skeleton

import (
	"fmt"
	"log/slog"
	"strings"

	"anime_ai/module/assets/character"
	"anime_ai/module/episode"
	"anime_ai/module/assets/location"
	"anime_ai/module/scene"
)

// Extractor 骨架提取器接口，供 script 模块注入
type Extractor interface {
	Extract(projectIDStr, userIDStr string) error
}

// Service 从集/场数据中提取角色名和场景名，创建骨架资产
type Service struct {
	episodeSvc   *episode.Service
	sceneSvc     *scene.Service
	characterSvc *character.Service
	locationSvc  *location.Service
}

// NewService 创建 SkeletonService
func NewService(
	episodeSvc *episode.Service,
	sceneSvc *scene.Service,
	characterSvc *character.Service,
	locationSvc *location.Service,
) *Service {
	return &Service{
		episodeSvc:   episodeSvc,
		sceneSvc:     sceneSvc,
		characterSvc: characterSvc,
		locationSvc:  locationSvc,
	}
}

// Extract 从项目下所有集/场中提取角色名和场景名，创建 status=skeleton 的骨架资产
func (s *Service) Extract(projectIDStr, userIDStr string) error {
	eps, err := s.episodeSvc.ListByProject(projectIDStr, userIDStr)
	if err != nil {
		return fmt.Errorf("列出集失败: %w", err)
	}

	// 收集角色名、场景名（场景名 -> 首次出现的 timeOfDay, intExt）
	characterNames := make(map[string]bool)
	locationMeta := make(map[string]struct{ timeOfDay, intExt string })

	for _, ep := range eps {
		epID := ep.IDStr
		if epID == "" {
			epID = fmt.Sprintf("%d", ep.ID)
		}
		scenes, err := s.sceneSvc.List(epID, userIDStr)
		if err != nil {
			return fmt.Errorf("列出场失败: %w", err)
		}
		for _, sc := range scenes {
			for _, name := range sc.Characters {
				name = strings.TrimSpace(name)
				if name != "" {
					characterNames[name] = true
				}
			}
			locName := strings.TrimSpace(sc.Location)
			if locName != "" {
				if _, ok := locationMeta[locName]; !ok {
					locationMeta[locName] = struct{ timeOfDay, intExt string }{sc.Time, sc.InteriorExterior}
				}
			}
		}
	}

	// 获取已有资产，按 name 去重
	existingChars, err := s.characterSvc.ListByProject(projectIDStr, userIDStr)
	if err != nil {
		return fmt.Errorf("列出已有角色失败: %w", err)
	}
	existingCharNames := make(map[string]bool)
	for _, c := range existingChars {
		existingCharNames[c.Name] = true
	}

	existingLocs, err := s.locationSvc.List(projectIDStr, userIDStr)
	if err != nil {
		return fmt.Errorf("列出已有场景失败: %w", err)
	}
	existingLocNames := make(map[string]bool)
	for _, loc := range existingLocs {
		existingLocNames[loc.Name] = true
	}

	// 创建骨架角色
	for name := range characterNames {
		if existingCharNames[name] {
			continue
		}
		if _, err := s.characterSvc.CreateSkeleton(projectIDStr, userIDStr, name); err != nil {
			slog.Warn("骨架角色创建失败", "name", name, "error", err)
			continue
		}
		existingCharNames[name] = true
	}

	// 创建骨架场景
	for name, meta := range locationMeta {
		if existingLocNames[name] {
			continue
		}
		if _, err := s.locationSvc.CreateSkeleton(projectIDStr, userIDStr, name, meta.timeOfDay, meta.intExt); err != nil {
			slog.Warn("骨架场景创建失败", "name", name, "error", err)
			continue
		}
		existingLocNames[name] = true
	}

	return nil
}
