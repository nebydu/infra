#!/usr/bin/env sh
# MinIO 버킷/정책 부트스트랩 — phase1-050-infra(T1-1) 운영 골격 슬라이스.
#
# 외부화 의도: compose one-shot(minio-init)과 향후 K8s Job/Helm post-install hook이
#   같은 스크립트를 재사용하도록 compose에서 분리(orchestrator 무관 이식성).
#
# 범위: 도메인-무관 "일반 버킷 + 정책/접근 골격"까지만.
#   실제 스크립트 객체 배치/버전관리는 T3-5(Script 파일 보관) 소유 — 여기서 만들지 않는다.
#
# 환경변수(컨테이너에서 주입):
#   MINIO_ENDPOINT       기본 http://minio:9000
#   MINIO_ROOT_USER      MinIO 루트 계정
#   MINIO_ROOT_PASSWORD  MinIO 루트 비밀번호
#   MINIO_DEFAULT_BUCKET 생성할 중립명 일반 버킷(기본 app-objects)
set -eu

ENDPOINT="${MINIO_ENDPOINT:-http://minio:9000}"
BUCKET="${MINIO_DEFAULT_BUCKET:-app-objects}"

# MinIO 기동 대기 — minio 이미지는 ubi-micro라 컨테이너 내 healthcheck가 어려워,
# 이 init의 retry 루프가 사실상 readiness 게이트 역할을 한다(멱등).
# 무한 대기 금지 — 최대 시도 후 명확히 실패 종료(one-shot이 영원히 매달리는 것 방지).
MAX_TRIES="${MINIO_INIT_MAX_TRIES:-30}"
i=1
until mc alias set local "$ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" 2>/dev/null; do
  if [ "$i" -ge "$MAX_TRIES" ]; then
    echo "minio-init FAILED: ${ENDPOINT} 에 ${MAX_TRIES}회 시도 후에도 연결 불가" >&2
    exit 1
  fi
  echo "waiting for minio at ${ENDPOINT} ... (${i}/${MAX_TRIES})"
  i=$((i + 1))
  sleep 2
done

# 일반 버킷 생성 (이미 있으면 무시 — 멱등)
mc mb --ignore-existing "local/${BUCKET}"

# 접근 제어 골격: 기본 비공개(익명 접근 차단). 운영 베이스라인 = 명시적 권한만 허용.
# 세분 RBAC/정책(도메인별)은 앱 계층/후속(T3-5, 인증 T1-2) 소유.
mc anonymous set none "local/${BUCKET}"

echo "minio-init done: bucket=${BUCKET} (private)"
