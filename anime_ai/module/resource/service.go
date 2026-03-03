package resource

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// ImageGen 图生能力接口（用于 generate-image）
type ImageGen interface {
	Submit(ctx context.Context, req capability.ImageRequest, preferred string) (providerName, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.ImageResult, error)
}

// Service 素材库业务逻辑层
type Service struct {
	data     Data
	imageGen ImageGen
}

// NewService 创建 Service
func NewService(data Data) *Service {
	return &Service{data: data}
}

// SetImageGen 注入图生能力
func (s *Service) SetImageGen(g ImageGen) {
	s.imageGen = g
}

var validModalities = map[string]bool{"visual": true, "audio": true, "text": true}
var validLibraryTypes = map[string]bool{
	"style": true, "character": true, "scene": true, "prop": true,
	"expression": true, "pose": true, "effect": true, "voice": true, "prompt": true,
}

func validateModality(m string) error {
	if m != "" && !validModalities[m] {
		return fmt.Errorf("%w: 无效的素材模态 %s", pkg.ErrBadRequest, m)
	}
	return nil
}

func validateLibraryType(t string) error {
	if t != "" && !validLibraryTypes[t] {
		return fmt.Errorf("%w: 无效的子库类型 %s", pkg.ErrBadRequest, t)
	}
	return nil
}

func validateJSON(s string, name string) error {
	if s == "" {
		return nil
	}
	if !json.Valid([]byte(s)) {
		return fmt.Errorf("%w: %s 不是有效 JSON", pkg.ErrBadRequest, name)
	}
	return nil
}

// Create 创建素材
func (s *Service) Create(ctx context.Context, userID string, req CreateRequest) (*Resource, error) {
	if err := validateModality(req.Modality); err != nil {
		return nil, err
	}
	if err := validateLibraryType(req.LibraryType); err != nil {
		return nil, err
	}
	if err := validateJSON(req.TagsJSON, "tagsJson"); err != nil {
		return nil, err
	}
	if err := validateJSON(req.MetadataJSON, "metadataJson"); err != nil {
		return nil, err
	}
	if err := validateJSON(req.BindingIdsJSON, "bindingIdsJson"); err != nil {
		return nil, err
	}
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:   req.LibraryType,
		Modality:      req.Modality,
		ThumbnailURL:  req.ThumbnailURL,
		TagsJSON:      orEmpty(req.TagsJSON, "[]"),
		Version:       req.Version,
		MetadataJSON:  orEmpty(req.MetadataJSON, "{}"),
		BindingIdsJSON: orEmpty(req.BindingIdsJSON, "[]"),
		Description:   req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

func orEmpty(s, def string) string {
	if s == "" {
		return def
	}
	return s
}

// Get 获取素材详情
func (s *Service) Get(ctx context.Context, id, userID string) (*Resource, error) {
	return s.data.GetByIDAndUser(ctx, id, userID)
}

// List 分页列表
func (s *Service) List(ctx context.Context, userID string, req ListRequest) (*ListResponse, error) {
	if err := validateModality(req.Modality); err != nil {
		return nil, err
	}
	if err := validateLibraryType(req.LibraryType); err != nil {
		return nil, err
	}
	page := req.Page
	if page < 1 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize < 1 || pageSize > 100 {
		pageSize = 50
	}
	opts := ListDataOpts{
		Modality:    req.Modality,
		LibraryType: req.LibraryType,
		TagsOverlap: TagsToOverlapJSON(req.Tags),
		Offset:      int32((page - 1) * pageSize),
		Limit:       int32(pageSize),
	}
	items, total, err := s.data.List(ctx, userID, opts)
	if err != nil {
		return nil, err
	}
	return &ListResponse{Items: items, Total: total, Page: page, Size: pageSize}, nil
}

// Update 更新素材
func (s *Service) Update(ctx context.Context, id, userID string, req UpdateRequest) (*Resource, error) {
	r, err := s.data.GetByIDAndUser(ctx, id, userID)
	if err != nil {
		return nil, err
	}
	if req.Name != nil {
		r.Name = *req.Name
	}
	if req.ThumbnailURL != nil {
		r.ThumbnailURL = *req.ThumbnailURL
	}
	if req.TagsJSON != nil {
		if err := validateJSON(*req.TagsJSON, "tagsJson"); err != nil {
			return nil, err
		}
		r.TagsJSON = *req.TagsJSON
	}
	if req.Version != nil {
		r.Version = *req.Version
	}
	if req.MetadataJSON != nil {
		if err := validateJSON(*req.MetadataJSON, "metadataJson"); err != nil {
			return nil, err
		}
		r.MetadataJSON = *req.MetadataJSON
	}
	if req.BindingIdsJSON != nil {
		if err := validateJSON(*req.BindingIdsJSON, "bindingIdsJson"); err != nil {
			return nil, err
		}
		r.BindingIdsJSON = *req.BindingIdsJSON
	}
	if req.Description != nil {
		r.Description = *req.Description
	}
	if err := s.data.Update(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// Delete 软删除素材
func (s *Service) Delete(ctx context.Context, id, userID string) error {
	_, err := s.data.GetByIDAndUser(ctx, id, userID)
	if err != nil {
		return err
	}
	return s.data.SoftDelete(ctx, id, userID)
}

// Counts 各子库数量统计
func (s *Service) Counts(ctx context.Context, userID, modality string) (*CountsResponse, error) {
	if err := validateModality(modality); err != nil {
		return nil, err
	}
	counts, err := s.data.CountByLibraryType(ctx, userID, modality)
	if err != nil {
		return nil, err
	}
	return &CountsResponse{Counts: counts}, nil
}

// GenerateImage 调用图生能力，写入 resources 表并返回
func (s *Service) GenerateImage(ctx context.Context, userID string, req GenerateImageRequest) (*Resource, error) {
	if s.imageGen == nil {
		return nil, fmt.Errorf("%w: 图生服务未配置", pkg.ErrBadRequest)
	}
	libraryType := req.LibraryType
	if libraryType == "" {
		libraryType = "style"
	}
	modality := req.Modality
	if modality == "" {
		modality = "visual"
	}
	if err := validateLibraryType(libraryType); err != nil {
		return nil, err
	}
	if err := validateModality(modality); err != nil {
		return nil, err
	}
	imgReq := capability.ImageRequest{
		Prompt:         req.Prompt,
		NegativePrompt: req.NegativePrompt,
		Model:          req.Model,
		Width:          req.Width,
		Height:         req.Height,
		AspectRatio:    req.AspectRatio,
	}
	if req.ReferenceImageURL != "" {
		imgReq.ReferenceImageURLs = []string{req.ReferenceImageURL}
	}
	providerName, taskID, err := s.imageGen.Submit(ctx, imgReq, req.Provider)
	if err != nil {
		return nil, fmt.Errorf("图生提交失败: %w", err)
	}
	result, err := s.imageGen.Query(ctx, taskID)
	if err != nil {
		return nil, fmt.Errorf("图生查询失败: %w", err)
	}
	if result.Status != "completed" || len(result.URLs) == 0 {
		return nil, fmt.Errorf("%w: 图生失败: %s", pkg.ErrBadRequest, result.Error)
	}
	thumbnailURL := result.URLs[0]
	name := req.Name
	if name == "" {
		name = "生成图片"
	}
	r := &Resource{
		UserID:        userID,
		Name:          name,
		LibraryType:   libraryType,
		Modality:      modality,
		ThumbnailURL:  thumbnailURL,
		TagsJSON:      "[]",
		MetadataJSON:  fmt.Sprintf(`{"provider":"%s","model":"%s"}`, providerName, req.Model),
		BindingIdsJSON: "[]",
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}
