package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/module/auth"
	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/notification"
	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/module/script"
	"github.com/TeHeal/ai-anime/anime_ai/module/storyboard"
	"github.com/gin-gonic/gin"
)

// buildTestRouter 构建用于集成测试的最小路由（无 DB、无 Redis）
func buildTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	userStore, _ := auth.NewBootstrapUserStore("admin", "admin123")
	authSvc := auth.NewAuthService(userStore, "test-jwt-secret")
	authHandler := auth.NewHandler(authSvc)

	projectData := project.NewMemData()
	projectSvc := project.NewService(projectData)
	projectHandler := project.NewHandler(projectSvc)
	projectVerifier := project.NewProjectVerifier(projectData)

	episodeStore := episode.NewMemEpisodeStore()
	episodeSvc := episode.NewService(episodeStore, projectVerifier)
	episodeHandler := episode.NewHandler(episodeSvc)

	sceneStore := scene.NewMemSceneStore()
	sceneBlockStore := scene.NewMemSceneBlockStore()
	episodeReader := episode.EpisodeReaderAdapter(episodeStore)
	sceneSvc := scene.NewService(sceneStore, sceneBlockStore, episodeReader, projectVerifier)
	sceneHandler := scene.NewHandler(sceneSvc)

	storyboardAccess := project.NewStoryboardAccess(projectData)
	storyboardData := storyboard.NewMemData(storyboardAccess)
	storyboardSvc := storyboard.NewService(storyboardData, projectVerifier)
	storyboardHandler := storyboard.NewHandler(storyboardSvc)

	segmentStore := script.NewMemSegmentStore()
	scriptSvc := script.NewService(segmentStore, projectVerifier)
	scriptHandler := script.NewHandler(scriptSvc)

	notificationData := notification.NewMemData()
	notificationSvc := notification.NewService(notificationData)
	notificationHandler := notification.NewHandler(notificationSvc)

	cfg := &RouteConfig{
		AuthHandler:         authHandler,
		NotificationHandler: notificationHandler,
		ProjectHandler:      projectHandler,
		EpisodeHandler:      episodeHandler,
		SceneHandler:        sceneHandler,
		ScriptHandler:       scriptHandler,
		StoryboardHandler:   storyboardHandler,
		JWTSecret:           "test-jwt-secret",
	}

	r := gin.New()
	registerRoutes(r, cfg)
	return r
}

func TestAPI_Health(t *testing.T) {
	r := buildTestRouter()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/health", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("健康检查状态码应为 200, 得 %d", w.Code)
	}
	var body map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}
	if body["status"] != "ok" {
		t.Errorf("status 应为 ok, 得 %v", body["status"])
	}
}

func TestAPI_Login(t *testing.T) {
	r := buildTestRouter()
	body := map[string]string{"username": "admin", "password": "admin123"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("登录状态码应为 200, 得 %d body=%s", w.Code, w.Body.String())
	}
	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}
	data, ok := resp["data"].(map[string]interface{})
	if !ok {
		t.Fatalf("data 应为对象, 得 %T", resp["data"])
	}
	if data["token"] == nil || data["token"] == "" {
		t.Error("登录应返回 token")
	}
}

func TestAPI_Projects_RequireAuth(t *testing.T) {
	r := buildTestRouter()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/projects", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("未鉴权请求应返回 401, 得 %d", w.Code)
	}
}

func TestAPI_Projects_CreateAndList(t *testing.T) {
	r := buildTestRouter()

	// 登录获取 token
	loginBody := map[string]string{"username": "admin", "password": "admin123"}
	lb, _ := json.Marshal(loginBody)
	loginReq := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", bytes.NewReader(lb))
	loginReq.Header.Set("Content-Type", "application/json")
	loginW := httptest.NewRecorder()
	r.ServeHTTP(loginW, loginReq)
	if loginW.Code != http.StatusOK {
		t.Fatalf("登录失败: %d %s", loginW.Code, loginW.Body.String())
	}
	var loginResp struct {
		Data struct {
			Token string `json:"token"`
		} `json:"data"`
	}
	if err := json.Unmarshal(loginW.Body.Bytes(), &loginResp); err != nil {
		t.Fatalf("解析登录响应失败: %v", err)
	}
	token := loginResp.Data.Token
	if token == "" {
		t.Fatal("未获取到 token")
	}

	// 创建项目
	createBody := map[string]interface{}{"name": "测试项目", "story": "", "config": map[string]string{}}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建项目状态码应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	// 列出项目
	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出项目状态码应为 200, 得 %d", listW.Code)
	}
	var listResp struct {
		Data []interface{} `json:"data"`
	}
	if err := json.Unmarshal(listW.Body.Bytes(), &listResp); err != nil {
		t.Fatalf("解析列表响应失败: %v", err)
	}
	if len(listResp.Data) < 1 {
		t.Errorf("项目列表应至少有 1 项, 得 %d", len(listResp.Data))
	}
}
