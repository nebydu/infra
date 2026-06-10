#!/usr/bin/env sh
# OpenSearch 인덱스 템플릿 + ISM 정책 부트스트랩 — phase1-050-infra(T1-1) 운영 골격(P-2).
#
# 외부화 의도: compose one-shot(opensearch-init)과 향후 K8s Job/Helm hook이 같은 스크립트를
#   재사용하도록 분리. 적용 대상 JSON도 파일로 분리(index-template.json / ism-policy.json).
#
# 범위: 도메인-무관 일반 템플릿(app-*) + 일반 보존 ISM 골격까지만.
#   도메인 인덱스 소유권/필드 매핑은 제외(D-2/앱 계층).
#
# 환경변수:
#   OS_ENDPOINT   기본 http://opensearch:9200 (security plugin 비활성 = http, dev-local only)
set -eu

ENDPOINT="${OS_ENDPOINT:-http://opensearch:9200}"
DIR="$(dirname "$0")"

# ISM 정책 (PUT = 멱등 upsert)
curl -fsS -X PUT "${ENDPOINT}/_plugins/_ism/policies/general-retention" \
  -H 'Content-Type: application/json' \
  --data-binary "@${DIR}/ism-policy.json" >/dev/null

# 인덱스 템플릿 (PUT = 멱등 upsert)
curl -fsS -X PUT "${ENDPOINT}/_index_template/app-general" \
  -H 'Content-Type: application/json' \
  --data-binary "@${DIR}/index-template.json" >/dev/null

echo "opensearch-init done: ism=general-retention template=app-general"
