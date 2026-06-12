# codex-gate.profile — infra 도메인 delta (monitoring-harness plugin 주입값)
#
# 이 파일은 infra가 monitoring-harness 플러그인의 공통 codex-gate 골격에 주입하는
# 도메인 delta다. 실행 로직(골격)은 플러그인이 보유하며 여기에는 복제하지 않는다.
# 플러그인은 이 파일을 convention 경로(${CLAUDE_PROJECT_DIR}/.claude/codex-gate.profile)에서
# 자동 발견하여 로드한다(별도 설정 불필요 — userConfig/per-user config 의존 없음).

# ── 트리거 경로 (infra compose/collector 설정) ────────────────────────────
CODEX_GATE_TRIGGER_GLOBS=( "docker-compose.yml" "otel-collector-config.yml" "*.yml" "*.yaml" )

# ── 스킵 경로 (트리거보다 우선; 비코드 산출물) ────────────────────────────
CODEX_GATE_SKIP_GLOBS=( ".claude/*" "docs/*" "analysis/*" )

# ── 코드 변경 없음일 때 안내 메시지 ───────────────────────────────────────
CODEX_GATE_SKIP_MSG="[codex-gate] SKIP: compose/collector 설정(*.yml/*.yaml) 변경이 없어 Codex 검증을 건너뜁니다."

# ── Codex 리뷰 프롬프트 (infra 도메인 전체) ───────────────────────────────
CODEX_GATE_PROMPT="infra(Kafka/OTel Collector docker compose) 변경 리뷰. 통합본(../monitoring-meta/docs/master-design.md)이 전체 제품/아키텍처 최상위 기준이다. 다음을 read-only로만 검토하고 codex-schema.json 형식의 JSON으로만 응답하라: (1) 통합본 기준 전체 제품/아키텍처 방향 위반 (2) 토픽 명명 규칙(../monitoring-meta/adr/0005-topic-naming.md, Accepted) 위반 — kafka-init 사전 생성 토픽과 otel kafka exporter 발행 토픽이 규칙 B 논리명(command-topic/audit-topic/heartbeats-topic, job-results는 T4-2 전까지 유지)과 일치해야 한다 (3) Phase 0 데모 spec ../monitoring-meta/docs/phase0-snapshot/monitoring-demo-message-spec-v0.2.1.md 회귀 — 단, ADR-0005 토픽 재명명은 Phase 1 forward 변경이지 회귀가 아니므로 재명명 자체를 회귀로 보고하지 마라 (4) kafka-payloads(../monitoring-meta/docs/kafka-payloads.md) 메시징 계약 위반 (5) heartbeat 경로(OTLP HTTP receiver → kafka exporter otlp_proto) 위반 — ADR-0002 A-1 protobuf 전환, hub 디코더와 동시 컷오버 전제 (6) compose 구성 버그(listener/포트/헬스체크/기동 순서) 가능성. 참고: handoff 작업 spec 정합성과 위상 의도 분류는 이 gate가 아니라 analyzer/spec-guardian이 담당하므로 여기서 검사하지 않는다(이 gate 입력에는 handoff가 포함되지 않음). infra에는 빌드/테스트가 없으므로 검증 기준은 'docker compose config' 문법 검증과 설정 파일 정합성이다 — 테스트 누락 자체를 위반으로 보고하지 마라."

# ── escalation 임계: hub/script-agent와 동일 ──────────────────────────────
CODEX_GATE_FAIL_LIMIT=3
CODEX_GATE_PARSE_FAIL_LIMIT=2
