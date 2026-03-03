package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"anime_ai/module/auth"
	"anime_ai/module/assets/character"
	"anime_ai/module/episode"
	"anime_ai/module/assets/location"
	"anime_ai/module/notification"
	"anime_ai/module/project"
	"anime_ai/module/assets/prop"
	"anime_ai/module/scene"
	"anime_ai/module/script"
	"anime_ai/module/shot"
	"anime_ai/module/shot_image"
	"anime_ai/module/storyboard"
	"anime_ai/pub/route"
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
	scriptSvc.SetEpisodeSceneServices(episodeSvc, sceneSvc)
	scriptHandler := script.NewHandler(scriptSvc)

	notificationData := notification.NewMemData()
	notificationSvc := notification.NewService(notificationData)
	notificationHandler := notification.NewHandler(notificationSvc)

	// 角色、场景资产、道具、镜头、镜图（Mem 存储）
	characterData := character.NewMemData()
	characterSvc := character.NewService(characterData, projectVerifier)
	characterHandler := character.NewHandler(characterSvc)

	locationStore := location.NewMemLocationStore()
	locationSvc := location.NewService(locationStore, projectVerifier)
	locationHandler := location.NewHandler(locationSvc)

	propStore := prop.NewMemPropStore()
	propSvc := prop.NewService(propStore, projectVerifier)
	propHandler := prop.NewHandler(propSvc)

	shotStore := shot.NewMemShotStore()
	shotReader := shot.ShotReaderAdapter(shotStore)
	shotLocker := shot.ShotLockerAdapter(shotStore)
	shotSvc := shot.NewService(shotStore, projectVerifier)
	shotHandler := shot.NewHandler(shotSvc)

	shotImageStore := shot_image.NewMemShotImageStore()
	shotImageSvc := shot_image.NewService(shotImageStore, shotReader, shotLocker, projectVerifier, nil)
	shotImageHandler := shot_image.NewHandler(shotImageSvc)

	// RBAC 中间件依赖（ProjectContext 所需）
	projectMwReader := project.ProjectReaderAdapter(projectData)
	projectMemberMwReader := project.ProjectMemberReaderAdapter(projectData)
	teamMemberMwReader := &project.NoopTeamMemberReader{}

	cfg := &route.Config{
		AuthHandler:         authHandler,
		NotificationHandler: notificationHandler,
		ProjectHandler:      projectHandler,
		EpisodeHandler:      episodeHandler,
		SceneHandler:        sceneHandler,
		ScriptHandler:       scriptHandler,
		StoryboardHandler:   storyboardHandler,
		CharacterHandler:    characterHandler,
		LocationHandler:     locationHandler,
		PropHandler:         propHandler,
		ShotHandler:         shotHandler,
		ShotImageHandler:    shotImageHandler,
		JWTSecret:           "test-jwt-secret",
		ProjectReader:       projectMwReader,
		ProjectMemberReader: projectMemberMwReader,
		TeamMemberReader:    teamMemberMwReader,
	}

	r := gin.New()
	route.Register(r, cfg)
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
			Script interface{}   `json:"script"`
			Issues []interface{} `json:"issues"`
		} `json:"data"`
	}
	if err := json.Unmarshal(parseW.Body.Bytes(), &parseResp); err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}
	// 解析实现返回 script + issues，结构正确即可
	if parseResp.Data.Script == nil {
		t.Error("script 字段应有值")
	}
	if parseResp.Data.Issues == nil {
		t.Error("issues 字段应存在")
	}
}

// TestAPI_Script_ParseSync_BlockTooManyUnknown 未识别块过多时禁止导入，返回 400
func TestAPI_Script_ParseSync_BlockTooManyUnknown(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	// 构造 >30 个 unknown 块：需有集+场，然后 31 行不匹配任何规则的内容
	var sb strings.Builder
	sb.WriteString("第1集\n1-1日，外，森林\n")
	for i := 0; i < 31; i++ {
		sb.WriteString("未识别格式的随机文本行\n")
	}
	parseBody := map[string]interface{}{
		"content":     sb.String(),
		"format_hint": "unknown",
	}
	pb, _ := json.Marshal(parseBody)
	parseReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/script/parse-sync", bytes.NewReader(pb))
	parseReq.Header.Set("Content-Type", "application/json")
	parseReq.Header.Set("Authorization", "Bearer "+token)
	parseW := httptest.NewRecorder()
	r.ServeHTTP(parseW, parseReq)

	if parseW.Code != http.StatusBadRequest {
		t.Errorf("未识别块过多应返回 400, 得 %d body=%s", parseW.Code, parseW.Body.String())
	}
	var resp struct {
		Message string `json:"message"`
	}
	if err := json.Unmarshal(parseW.Body.Bytes(), &resp); err == nil {
		if !strings.Contains(resp.Message, "未识别内容块过多") {
			t.Errorf("message 应包含「未识别内容块过多」, 得 %s", resp.Message)
		}
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

// mustCreateEpisode 创建集并返回 ID
func mustCreateEpisode(t *testing.T, r *gin.Engine, token, projectID string) string {
	t.Helper()
	body := map[string]interface{}{"title": "第一集", "summary": ""}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/episodes", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK && w.Code != http.StatusCreated {
		t.Fatalf("创建集失败: %d %s", w.Code, w.Body.String())
	}
	var resp struct {
		Data struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("解析创建集响应: %v", err)
	}
	return resp.Data.ID
}

// mustCreateScene 创建场并返回 ID
func mustCreateScene(t *testing.T, r *gin.Engine, token, projectID, episodeID string) string {
	t.Helper()
	body := map[string]interface{}{"scene_id": "S1", "location": "客厅", "time": "白天", "characters": []string{}}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/episodes/"+episodeID+"/scenes", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK && w.Code != http.StatusCreated {
		t.Fatalf("创建场失败: %d %s", w.Code, w.Body.String())
	}
	var resp struct {
		Data struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("解析创建场响应: %v", err)
	}
	return resp.Data.ID
}

// TestAPI_Episode_CreateAndList 集 CRUD
func TestAPI_Episode_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	epID := mustCreateEpisode(t, r, token, projectID)
	if epID == "" {
		t.Fatal("创建集应返回 id")
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/episodes", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出集应为 200, 得 %d body=%s", listW.Code, listW.Body.String())
	}
	var listResp struct {
		Data []struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(listW.Body.Bytes(), &listResp); err != nil {
		t.Fatalf("解析列表: %v", err)
	}
	if len(listResp.Data) < 1 {
		t.Errorf("集列表应至少有 1 项, 得 %d", len(listResp.Data))
	}

	getReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/episodes/"+epID, nil)
	getReq.Header.Set("Authorization", "Bearer "+token)
	getW := httptest.NewRecorder()
	r.ServeHTTP(getW, getReq)
	if getW.Code != http.StatusOK {
		t.Errorf("获取集应为 200, 得 %d", getW.Code)
	}
}

// TestAPI_Scene_CreateAndList 场 CRUD
func TestAPI_Scene_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)
	epID := mustCreateEpisode(t, r, token, projectID)

	sceneID := mustCreateScene(t, r, token, projectID, epID)
	if sceneID == "" {
		t.Fatal("创建场应返回 id")
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/episodes/"+epID+"/scenes", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出场应为 200, 得 %d body=%s", listW.Code, listW.Body.String())
	}
}

// TestAPI_Segment_CreateAndList 脚本分段 CRUD
func TestAPI_Segment_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	createBody := map[string]interface{}{"content": "镜头指令内容", "sort_index": 0}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/segments", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建分段应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/segments", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出分段应为 200, 得 %d", listW.Code)
	}
}

// TestAPI_Character_CreateAndList 角色 CRUD（全局与项目级）
func TestAPI_Character_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	createBody := map[string]interface{}{"name": "测试角色", "project_id": projectID}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/characters", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建角色应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/characters", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("按项目列出角色应为 200, 得 %d", listW.Code)
	}
}

// TestAPI_Location_CreateAndList 场景资产 CRUD
func TestAPI_Location_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	createBody := map[string]interface{}{"name": "客厅", "time": "白天", "interior_exterior": "内景"}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/locations", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建场景应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/locations", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出场景应为 200, 得 %d", listW.Code)
	}
}

// TestAPI_Prop_CreateAndList 道具资产 CRUD
func TestAPI_Prop_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	createBody := map[string]interface{}{"name": "宝剑", "appearance": "银色长剑"}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/asset-props", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建道具应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/asset-props", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出道具应为 200, 得 %d", listW.Code)
	}
}

// TestAPI_Shot_CreateAndList 镜头 CRUD
func TestAPI_Shot_CreateAndList(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	createBody := map[string]interface{}{"prompt": "角色走向门口", "duration": 5}
	cb, _ := json.Marshal(createBody)
	createReq := httptest.NewRequest(http.MethodPost, "/api/v1/projects/"+projectID+"/shots", bytes.NewReader(cb))
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+token)
	createW := httptest.NewRecorder()
	r.ServeHTTP(createW, createReq)
	if createW.Code != http.StatusOK && createW.Code != http.StatusCreated {
		t.Errorf("创建镜头应为 200/201, 得 %d body=%s", createW.Code, createW.Body.String())
	}

	listReq := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/shots", nil)
	listReq.Header.Set("Authorization", "Bearer "+token)
	listW := httptest.NewRecorder()
	r.ServeHTTP(listW, listReq)
	if listW.Code != http.StatusOK {
		t.Errorf("列出镜头应为 200, 得 %d", listW.Code)
	}
}

// TestAPI_ShotImage_GetStatus 镜图状态查询
func TestAPI_ShotImage_GetStatus(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/shot-images/status", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("获取镜图状态应为 200, 得 %d body=%s", w.Code, w.Body.String())
	}
}

// TestAPI_Storyboard_List 分镜列表
func TestAPI_Storyboard_List(t *testing.T) {
	r := buildTestRouter()
	token := mustLogin(t, r)
	projectID := mustCreateProject(t, r, token)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/projects/"+projectID+"/storyboard", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("获取分镜列表应为 200, 得 %d body=%s", w.Code, w.Body.String())
	}
}
