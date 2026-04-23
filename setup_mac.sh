#!/bin/bash
# =============================================================================
# NOTE (Maintenance): macOS PF Firewall setup script for Maestro Ops.
# Opens ports 6379 (Redis) and 8100 (FileServer) via a custom anchor.
# Must be run with sudo. Safe to re-run (idempotent).
# =============================================================================

set -euo pipefail

# ── 변수 설정 ────────────────────────────────────────────────────────────────
ANCHOR_DIR="/etc/pf.anchors"
ANCHOR_FILE="${ANCHOR_DIR}/com.maestro.ops"
PF_CONF="/etc/pf.conf"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${PF_CONF}.bak_${TIMESTAMP}"

echo "--- PF Firewall 설정 자동화를 시작합니다 ---"

# ── sudo 권한 확인 ────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo "오류: 이 스크립트는 sudo 권한으로 실행해야 합니다." >&2
  exit 1
fi

# ── 앵커 디렉터리 확인 ────────────────────────────────────────────────────────
if [ ! -d "$ANCHOR_DIR" ]; then
  echo "오류: 앵커 디렉터리 '${ANCHOR_DIR}'가 존재하지 않습니다." >&2
  exit 1
fi

# ── 단계 1: 앵커 파일 생성 ───────────────────────────────────────────────────
echo "단계 1: 앵커 파일 생성 중... (${ANCHOR_FILE})"
cat > "$ANCHOR_FILE" <<EOF
# Maestro Ops Redis
pass in proto tcp from any to any port 6379
# Maestro Ops FileServer
pass in proto tcp from any to any port 8100
EOF
echo "  완료: 앵커 파일이 생성되었습니다."

# ── 단계 2: pf.conf 백업 ─────────────────────────────────────────────────────
echo "단계 2: pf.conf 백업 생성 중... (${BACKUP_FILE})"
cp "$PF_CONF" "$BACKUP_FILE"
echo "  완료: 백업이 생성되었습니다."

# =============================================================================
# NOTE (Maintenance): BSD sed on macOS requires a literal newline after `a\`.
# Using a helper function with a temp file avoids quoting/escaping pitfalls
# that can silently produce malformed pf.conf entries.
# =============================================================================

# ── 단계 3: pf.conf 규칙 추가 ───────────────────────────────────────────────
echo "단계 3: pf.conf 규칙 추가 중..."

# anchor "maestro.ops" 선언 추가 (중복 방지)
# =============================================================================
# NOTE (Maintenance): grep pattern must be anchored (^) to avoid matching
# "load anchor "maestro.ops"" lines. awk pattern must also be anchored (^)
# so it only matches the bare "anchor" filtering rule and NOT the substring
# found inside scrub-anchor / nat-anchor / rdr-anchor / dummynet-anchor lines,
# which belong to earlier PF rule sections and would cause ordering errors.
# =============================================================================
if ! grep -qE '^anchor "maestro.ops"' "$PF_CONF"; then
  TMPFILE=$(mktemp)
  awk '
    /^anchor "com\.apple\/\*"/ {
      print
      print "anchor \"maestro.ops\""
      next
    }
    { print }
  ' "$PF_CONF" > "$TMPFILE"
  mv "$TMPFILE" "$PF_CONF"
  echo "  추가됨: anchor \"maestro.ops\""
else
  echo "  건너뜀: anchor \"maestro.ops\" 이미 존재합니다."
fi

# load anchor 선언 추가 (중복 방지)
if ! grep -qF 'load anchor "maestro.ops"' "$PF_CONF"; then
  TMPFILE=$(mktemp)
  awk '
    /load anchor "com\.apple" from "\/etc\/pf\.anchors\/com\.apple"/ {
      print
      print "load anchor \"maestro.ops\" from \"/etc/pf.anchors/com.maestro.ops\""
      next
    }
    { print }
  ' "$PF_CONF" > "$TMPFILE"
  mv "$TMPFILE" "$PF_CONF"
  echo "  추가됨: load anchor \"maestro.ops\""
else
  echo "  건너뜀: load anchor \"maestro.ops\" 이미 존재합니다."
fi

# ── 단계 4: 문법 검사 및 적용 ────────────────────────────────────────────────
echo "단계 4: 설정 파일 문법 검토 중..."

# =============================================================================
# NOTE (Maintenance): If validation fails, restore the original pf.conf from
# backup so the system is not left with a broken firewall configuration.
# =============================================================================
if pfctl -vnf "$PF_CONF" 2>&1; then
  echo "검사 성공: 설정을 적용합니다."
  pfctl -ef "$PF_CONF"
  echo ""
  echo "--- 설정이 완료되었습니다! ---"
  echo "  Redis  포트 6379 열림"
  echo "  FileServer 포트 8100 열림"
  echo "  백업 파일: ${BACKUP_FILE}"
else
  echo "" >&2
  echo "오류: pf.conf 설정에 문제가 있습니다. 백업 파일에서 복원합니다..." >&2
  cp "$BACKUP_FILE" "$PF_CONF"
  echo "  복원 완료: ${BACKUP_FILE} -> ${PF_CONF}" >&2
  exit 1
fi
