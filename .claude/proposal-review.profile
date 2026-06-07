# proposal-review.profile — infra consumer 델타 (H6)
# /proposal-review command가 Codex 리뷰에 주입할 infra 문맥. 도메인 결정은 이 파일에만 둔다.
# 골격: monitoring-harness plugin shared/analysis/proposal-review-runner.sh
#
# 적용 조건: harness a455246 이상(runner의 git rev-parse fallback 포함) — 그 이전 캐시에서는
#   command 컨텍스트가 이 profile을 못 찾아 degraded(문맥 없는 리뷰)로 동작한다.
# drift 완화: 기준 문서를 추가/이동하는 작업의 DoD에 "이 profile 문맥 목록 갱신"을 포함한다.
# dry-run: 이 repo에서 `/proposal-review` 호출 → 출력 JSON context 필드가
#   "profile: .../proposal-review.profile"이면 주입 성공, "none"이면 degraded.

# repo 루트 기준 절대경로로 해석 (호출 cwd 무관하게 동작)
_INFRA_ROOT="$(git rev-parse --show-toplevel)"

# 문맥 문서 — infra의 "코드"인 설정 2파일 + meta 기준 문서.
# 통합본_v0_9.md(170KB)는 매 리뷰 주입 비용이 커서 제외(아래 POLICY에서 안내).
# ../monitoring-meta 형제 경로는 workspace 배치 의존 — 없으면 runner가 warn 후 건너뛴다.
PROPOSAL_REVIEW_CONTEXT_DOCS=(
  "$_INFRA_ROOT/docker-compose.yml"
  "$_INFRA_ROOT/otel-collector-config.yml"
  "$_INFRA_ROOT/../monitoring-meta/adr/0002-heartbeat-otlp-proto.md"
  "$_INFRA_ROOT/../monitoring-meta/adr/0005-topic-naming.md"
  "$_INFRA_ROOT/../monitoring-meta/docs/kafka-payloads.md"
  "$_INFRA_ROOT/../monitoring-meta/docs/phase0-snapshot/monitoring-demo-message-spec-v0.2.1.md"
)

PROPOSAL_REVIEW_POLICY="infra는 Kafka/OTel Collector docker compose 설정 repo다(빌드/테스트 없음 — 검증 기준은 docker compose config 문법과 설정 일관성). 결정 리뷰 시 지킬 기준: 방향 판단의 최상위 기준은 통합본 v0.9(이 입력에 미포함, 170KB라 제외 — ../monitoring-meta/docs/통합본_v0_9.md)이고, 데모 spec v0.2.1은 Phase 0 회귀 방지 가드다. 단 ADR-0005 토픽 재명명은 Phase 1 forward 변경이지 회귀가 아니다. Accepted ADR(0002 heartbeat otlp_proto — hub 디코더와 동시 컷오버 전제, 0005 토픽 명명 규칙 B)과 충돌하는 제안, [Open]/미결정 ADR을 결정된 것으로 전제한 제안, 형제 repo(hub/script-agent/monitoring-meta)를 infra가 직접 수정하는 것을 전제한 제안은 block 대상이다. 작업 spec은 ../monitoring-meta/handoff/<work-id>-infra.md 경유가 원칙이므로 이를 우회하는 프로세스 제안도 결함으로 지적하라. 통합본이 직접 쟁점인데 발췌가 없으면 missing_context로 지적하라."
