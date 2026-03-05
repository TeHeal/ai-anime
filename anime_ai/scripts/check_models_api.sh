#!/bin/bash
# 验证 GET /models?service=xxx 接口
# 用法：./scripts/check_models_api.sh [API_BASE_URL] [USERNAME] [PASSWORD]

set -e
BASE="${1:-http://localhost:3737/api/v1}"
USER="${2:-admin}"
PASS="${3:-admin123}"

echo "=== 模型目录 API 联调检查 ==="
echo "API Base: $BASE"
echo ""

# 1. 登录
echo "1. 登录 ($USER)..."
LOGIN=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}")
TOKEN=$(echo "$LOGIN" | jq -r '.data.token // empty')
if [ -z "$TOKEN" ]; then
  echo "登录失败"
  echo "响应: $LOGIN"
  exit 1
fi
echo "登录成功"
echo ""

# 2. 调用 models 接口（按 service 筛选）
for SVC in image video tts music llm; do
  echo "2.$SVC GET /models?service=$SVC ..."
  RES=$(curl -s "$BASE/models?service=$SVC" -H "Authorization: Bearer $TOKEN")
  CODE=$(echo "$RES" | jq -r '.code // -1')
  if [ "$CODE" != "0" ]; then
    echo "  失败 code=$CODE: $RES"
    exit 1
  fi
  COUNT=$(echo "$RES" | jq '.data.items | length')
  echo "  成功，返回 $COUNT 个模型"
done

# 3. 无 service 应返回 400
echo ""
echo "3. 无 service 参数应返回 400..."
RES=$(curl -s -w "\n%{http_code}" "$BASE/models" -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RES" | tail -n1)
if [ "$HTTP" != "400" ]; then
  echo "  期望 400，实际 $HTTP"
  exit 1
fi
echo "  符合预期 (400)"
echo ""
echo "=== 模型目录 API 检查通过 ==="
