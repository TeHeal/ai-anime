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

// TestAPI_Login_Fail 登录失败：错误密码
func TestAPI_Login_Fail(t *testing.T) {
	r := buildTestRouter()
	body := map[string]string{"username": "admin", "password": "wrong"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("错误密码应返回 401, 得 %d", w.Code)
	}
}

// TestAPI_Projects_Get 获取项目详情
func TestAPI_Projects_Get(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)

	// 先创建项目
	createBody := map[string]interface{}{"name": "测试项目", "story": "", "config": map[string]string{}}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Fatalf("创建项目失败: %d %s", createW.Code, createW.Body.String())
	}

	var createResp struct {
		Data struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(createW.Body.Bytes(), &createResp); err != nil {
		t.Fatalf("解析创建响应失败: %v", err)
	}
	projectID := createResp.Data.ID
	if projectID == "" {
		t.Fatal("创建响应应包含 id")
	}

	// 获取项目详情
	getReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID, nil)
	getReq.Header.Set("Authorization", "Bearer "+token)
	getW := httptest.NewRecorder()
	r.ServeHTTP(getW, getReq)
	if getW.Code != http.StatusOK {
		t.Errorf("获取项目应返回 200, 得 %d body=%s", getW.Code, getW.Body.String())
	}
}

// TestAPI_Script_ParseSync 剧本同步解析
func TestAPI_Script_ParseSync(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	parseBody := map[string]interface{}{
		"content":     "第一集\n场景1 内景 客厅\n张三：你好。",
		"format_hint": "standard",
	}
	pb, _ := json.Marshal(parseBody)
	parseReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/script/parse-sync", bytes.NewReader(pb))
	parseReq.Header.Set("Content-Type", "application/json")
	parseReq.Header.Set("Authorization", "Bearer "+token)
	parseW := httptest.NewRecorder()
	r.ServeHTTP(parseW, parseReq)

	if parseW.Code != http.StatusOK {
		t.Errorf("解析应返回 200, 得 %d body=%s", parseW.Code, parseW.Body.String())
	}
	var parseResp struct {
		Data struct {
			Script interface{} `json:"script"`
			Issues []string    `json:"issues"`
		} `json:"data"`
	}
	if err := json.Unmarshal(parseW.Body.Bytes(), &parseResp); err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}
	// 占位实现返回 script: null，结构正确即可
	if parseResp.Data.Issues == nil {
		t.Error("issues 字段应存在")
	}
}

// TestAPI_Script_ParseSync_RequireAuth 解析需鉴权
func TestAPI_Script_ParseSync_RequireAuth(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	parseBody := map[string]interface{}{"content": "test", "format_hint": "standard"}
	pb, _ := json.Marshal(parseBody)
	parseReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/script/parse-sync", bytes.NewReader(pb))
	parseReq.Header.Set("Content-Type", "application/json")
	// 故意不设置 Authorization
	parseW := httptest.NewRecorder()
	r.ServeHTTP(parseW, parseReq)

	if parseW.Code != http.StatusUnauthorized {
		t.Errorf("未鉴权应返回 401, 得 %d", parseW.Code)
	}
}

// TestAPI_Flow_Login_Project_Parse 全流程：登录 → 创建项目 → 剧本解析
func TestAPI_Flow_Login_Project_Parse(t *testing.T) {
	r := buildTestRouter()

	// 1. 登录
	token := mustLogin(t, r)
	if token == "" {
		t.Fatal("登录失败")
	}

	// 2. 创建项目
	projectID := mustCreateProject(t, r, token)
	if projectID == "" {
		t.Fatal("创建项目失败")
	}

	// 3. 剧本解析
	parseBody := map[string]interface{}{
		"content":     "第一集\n场景1 内景 客厅 日\n张三：你好，李四。\n李四：你好。",
		"format_hint": "standard",
	}
	pb, _ := json.Marshal(parseBody)
	parseReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/script/parse-sync", bytes.NewReader(pb))
	parseReq.Header.Set("Content-Type", "application/json")
	parseReq.Header.Set("Authorization", "Bearer "+token)
	parseW := httptest.NewRecorder()
	r.ServeHTTP(parseW, parseReq)

	if parseW.Code != http.StatusOK {
		t.Fatalf("剧本解析应返回 200, 得 %d body=%s", parseW.Code, parseW.Body.String())
	}
}

// mustLogin 登录并返回 token，失败则 t.Fatal
func mustLogin(t *testing.T, r *gin.Engine) string {
	t.Helper()
	body := map[string]string{"username": "admin", "password": "admin123"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("登录失败: %d %s", w.Code, w.Body.String())
	}
	var resp struct {
		Data struct {
			Token string `json:"token"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("解析登录响应: %v", err)
	}
	return resp.Data.Token
}

// mustCreateProject 创建项目并返回 ID，失败则 t.Fatal
func mustCreateProject(t *testing.T, r *gin.Engine, token string) string {
	t.Helper()
	body := map[string]interface{}{"name": "API测试项目", "story": "", "config": map[string]string{}}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/projects", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK && w.Code != http.StatusCreated {
		t.Fatalf("创建项目失败: %d %s", w.Code, w.Body.String())
	}
	var resp struct {
		Data struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("解析创建响应: %v", err)
	}
	return resp.Data.ID
}
