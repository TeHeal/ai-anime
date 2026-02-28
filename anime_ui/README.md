# anime_ui - AI-Anime 漫剧智能创作平台前端

Flutter 前端，跨平台（Web/桌面）。

## 环境要求

- Flutter SDK ^3.11.0（当前 stable 3.41 满足）
- Dart ^3.11.0

## 启动命令

```bash
# Web 模式（默认端口 8080）
flutter run -d web-server --web-port 8080

# 连接后端 API
flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1

# Chrome 模式
flutter run -d chrome --web-port 8080
```

## 代码生成

修改 freezed/json_serializable 模型后需运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 技术栈

- **路由**: go_router
- **状态管理**: flutter_riverpod
- **HTTP**: dio
- **实时**: web_socket_channel
- **数据模型**: freezed + json_serializable
- **UI**: flutter_fancy_tree_view, flutter_markdown, just_audio, solar_icons
- **主题**: 深色主题、紫色强调

## 目录结构

参见项目根目录 README.md 的「前端 (anime_ui)」章节。
