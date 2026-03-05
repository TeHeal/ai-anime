#!/bin/bash
# 联调检查：验证 /projects/:id/dashboard 接口返回的 episodes 字段
# 用法：./scripts/check_dashboard_api.sh [API_BASE_URL] [USERNAME] [PASSWORD]
# 例：  ./scripts/check_dashboard_api.sh
# 例：  ./scripts/check_dashboard_api.sh http://localhost:3737/api/v1 admin admin123

set -e
BASE="${1:-http://localhost:3737/api/v1}"
USER="${2:-admin}"
PASS="${3:-admin123}"

echo "=== Dashboard 接口联调检查 ==="
echo "API Base: $BASE"
echo ""

# 1. 登录
echo "1. 登录 ($USER)..."
LOGIN=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}")
TOKEN=$(echo "$LOGIN" | jq -r '.data.token // empty')
if [ -z "$TOKEN" ]; then
  echo "登录失败，请检查："
  echo "  - 后端是否运行 (curl $BASE/health)"
  echo "  - 用户名密码是否正确（默认 admin/admin123）"
  echo "  - 可用: $0 $BASE <username> <password>"
  echo "响应: $LOGIN"
  exit 1
fi
echo "登录成功"
echo ""

# 2. 获取项目列表
echo "2. 获取项目列表..."
PROJECTS=$(curl -s "$BASE/projects" -H "Authorization: Bearer $TOKEN")
PROJECT_ID=$(echo "$PROJECTS" | jq -r '.data[0].id // empty')
if [ -z "$PROJECT_ID" ]; then
  echo "无项目，请先创建项目并导入剧本"
  echo "响应: $PROJECTS"
  exit 1
fi
echo "使用项目 ID: $PROJECT_ID"
echo ""

# 3. 调用 Dashboard 接口
echo "3. 调用 GET /projects/$PROJECT_ID/dashboard ..."
DASH=$(curl -s "$BASE/projects/$PROJECT_ID/dashboard" -H "Authorization: Bearer $TOKEN")

# 检查 data 结构
CODE=$(echo "$DASH" | jq -r '.code // -1')
if [ "$CODE" != "0" ]; then
  echo "接口返回错误: $DASH"
  exit 1
fi

DATA=$(echo "$DASH" | jq -r '.data')
TOTAL=$(echo "$DATA" | jq -r '.totalEpisodes // 0')
EP_COUNT=$(echo "$DATA" | jq -r '.episodes | length // 0')

echo ""
echo "=== 结果 ==="
echo "totalEpisodes: $TOTAL"
echo "episodes 数组长度: $EP_COUNT"
echo ""

if [ "$EP_COUNT" = "0" ] && [ "$TOTAL" != "0" ]; then
  echo "⚠️  异常：totalEpisodes=$TOTAL 但 episodes 为空，后端需排查"
  echo "完整 data 键: $(echo "$DATA" | jq -r 'keys | join(", ")')"
  exit 1
elif [ "$EP_COUNT" = "$TOTAL" ]; then
  echo "✓ 联调正常：episodes 与 totalEpisodes 一致"
else
  echo "episodes 长度 $EP_COUNT，totalEpisodes $TOTAL"
fi
