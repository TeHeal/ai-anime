# AGENTS

## Cursor Cloud specific instructions

### Testing preferences

- **不要录制视频**：除非用户明确要求，否则不录制演示视频。

### Services

- **Go 后端** (`anime_ai`): 在 anime_ai 目录下 `go run .` 或 `air` 热重载，默认端口 3737，需要 CGO_ENABLED=1（SQLite）
- **Flutter 前端** (`anime_ui`): `flutter run -d web-server --web-port 8080`，连接后端需 `--dart-define=API_BASE_URL=http://localhost:3737/api/v1`
- **Redis**: 后端异步任务队列依赖，`redis-server --daemonize yes` 启动
- 默认管理员账号: admin / admin123

### Dev commands

- 参见 `anime_ai/Makefile` 和 `r.sh` / `s.sh` 脚本
- Flutter 代码生成: `dart run build_runner build --delete-conflicting-outputs`（修改 freezed/json_serializable 模型后需运行）

### Gotchas

- `anime_ai/config.yaml` 包含 API 密钥，已在 `.gitignore` 中，不要提交
- Go 1.25+ 必须，系统默认 Go 版本可能不够
- Flutter SDK 需 ^3.11.0，当前 stable (3.41) 满足
