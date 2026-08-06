#!/usr/bin/env bash
# check-before-done.sh — 在标 status=done 之前的硬门禁
#
# Usage:
#   bash .codebuddy/scripts/check-before-done.sh <req-id>
#
# 检查项：
#   1. final_summary_path 不为 null
#   2. spec/最终需求.md 或 spec/最终需求简述.md 存在
#   3. process.txt 里有 closer 完成日志
#
# 全部通过 → exit 0
# 任一不通过 → 列出缺失项 + exit 1
#
# 豁免：如 process.txt 包含 "verdict=approve_go" + "跳过 closer"，视为用户显式豁免 → exit 0

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ -z "${1:-}" ]]; then
  echo "❌ Usage: check-before-done.sh <req-id>"
  exit 1
fi

REQ_ID="$1"
REQ_DIR="$PROJECT_ROOT/requirements/$REQ_ID"

if [[ ! -d "$REQ_DIR" ]]; then
  echo "❌ 需求目录不存在: $REQ_DIR"
  exit 1
fi

META="$REQ_DIR/meta.yaml"
PROCESS="$REQ_DIR/process.txt"
ERRORS=()

# === 检查豁免 ===
if grep -q "跳过 closer" "$PROCESS" 2>/dev/null && grep -q "verdict=approve_go" "$PROCESS" 2>/dev/null; then
  echo "✓ 用户已显式豁免 closer（verdict + '跳过 closer' 留底）"
  exit 0
fi

# === 检查 1: final_summary_path ===
FSP=$(grep -m1 '^final_summary_path:' "$META" 2>/dev/null | sed 's/^final_summary_path:[[:space:]]*//' | tr -d '"')
if [[ -z "$FSP" || "$FSP" == "null" ]]; then
  ERRORS+=("❌ meta.yaml.final_summary_path 为空/null（closer 未填写）")
fi

# === 检查 2: 最终需求文档存在 ===
FOUND_FINAL=false
for f in "$REQ_DIR/spec/最终需求.md" "$REQ_DIR/spec/最终需求简述.md"; do
  if [[ -f "$f" ]]; then
    FOUND_FINAL=true
    break
  fi
done
if [[ "$FOUND_FINAL" == "false" ]]; then
  ERRORS+=("❌ spec/最终需求.md 或 spec/最终需求简述.md 不存在（closer 未产出）")
fi

# === 检查 3: process.txt 有 closer 完成日志 ===
if ! grep -qi "closer.*完成\|closer.*done\|closer completed" "$PROCESS" 2>/dev/null; then
  ERRORS+=("❌ process.txt 中无 closer 完成日志")
fi

# === 检查 4: 经验质量门禁（Phase 1 新增） ===
# 检查 auto-extracted 经验是否有未审核条目
AUTO_EXTRACT_DIR="$PROJECT_ROOT/context/shared/experiences/auto-extracted"
if [[ -d "$AUTO_EXTRACT_DIR" ]]; then
  UNVERIFIED_COUNT=$(find "$AUTO_EXTRACT_DIR" -name "*.md" -exec grep -l "^status: draft" {} \; 2>/dev/null | wc -l)
  if [[ "$UNVERIFIED_COUNT" -gt 0 ]]; then
    echo "⚠️  发现 $UNVERIFIED_COUNT 个未审核 auto-extracted 经验（status=draft）"
    echo "    位置: context/shared/experiences/auto-extracted/"
    echo "    处理: 补充「问题分析」「解决方案」段后改 status: final"
    # 非阻塞警告（不加入 ERRORS），允许继续标 done
  fi
fi

# === 检查 5: 经验库上限控制（Phase 1 新增） ===
# 同一 source_req 的经验条目不超过 5 条（含 auto-extracted）
EXP_DIR="$PROJECT_ROOT/context/shared/experiences"
if [[ -d "$EXP_DIR" ]]; then
  for req_ref in $(grep -rh "^source_req:" "$EXP_DIR" --include="*.md" 2>/dev/null | sort | uniq -c | awk '$1 > 5 {print $2 " (" $1 " 条)"}'); do
    echo "⚠️  经验库上限警告: $req_ref 超过 5 条上限"
  done
fi

# === 检查 6: AI 自主功能测试证据链（v0.2.0 · 自动化优先） ===
# agile-vibe SOP 阶段 3 强制产出 test-report/ac-verification.md + integration-test.log；缺失则警告（非阻塞，由 code-reviewer 步骤 2.5 阻塞）
AC_VERIFY="$REQ_DIR/test-report/ac-verification.md"
INTEG_LOG="$REQ_DIR/test-report/integration-test.log"
if [[ ! -f "$AC_VERIFY" ]]; then
  # 允许豁免：meta.yaml 含 test_exempt: true + test_exempt_reason 非空
  if grep -q "^test_exempt:[[:space:]]*true" "$META" 2>/dev/null; then
    EXEMPT_REASON=$(grep -m1 '^test_exempt_reason:' "$META" 2>/dev/null | sed 's/^test_exempt_reason:[[:space:]]*//' | tr -d '"')
    if [[ -z "$EXEMPT_REASON" ]]; then
      echo "⚠️  test_exempt=true 但 test_exempt_reason 为空 · 请补理由（agile-vibe SOP 9.5）"
    else
      echo "✓ 已豁免功能测试（理由: $EXEMPT_REASON）"
    fi
  else
    echo "⚠️  未发现 test-report/ac-verification.md（agile-vibe SOP 阶段 3 v0.2.0 强制产出）"
    echo "    如为纯文档/纯回溯需求，请在 meta.yaml 加 test_exempt: true + test_exempt_reason: <理由>"
    # 非阻塞：由 code-reviewer 步骤 2.5 做强制门禁
  fi
else
  # 简单校验诚实声明是否勾选
  CHECKED=$(grep -c "^- \[x\]" "$AC_VERIFY" 2>/dev/null || echo 0)
  if [[ "$CHECKED" -lt 3 ]]; then
    echo "⚠️  ac-verification.md 存在但诚实声明勾选不足 3 项（当前 $CHECKED 项 · agile-vibe SOP 9.4）"
  fi

  # v0.2.0 新增：检查 integration-test.log 是否存在（自动化断言主线）
  if [[ ! -f "$INTEG_LOG" ]]; then
    echo "⚠️  未发现 test-report/integration-test.log（v0.2.0 自动化断言主线 · 由 code-reviewer 步骤 2.5 阻塞）"
  fi

  # === 检查 6.5：零真操作检测（self-testing skill v0.2.0 语义调整） ===
  # 警告级：若 AC 表全 ⚠️/未验证 且 header 未标 "self-test not executed" 且勾了诚实声明 → 只警告不阻塞
  AC_ROWS=$(grep -cE '^\| AC-[0-9]' "$AC_VERIFY" 2>/dev/null || echo 0)
  WARN_ROWS=$(grep -cE '^\| AC-[0-9].*(⚠️|未验证|需人工抽验)' "$AC_VERIFY" 2>/dev/null || echo 0)
  HAS_NOT_EXEC_HEADER=$(grep -c "self-test not executed" "$AC_VERIFY" 2>/dev/null || echo 0)
  if [[ "$AC_ROWS" -gt 0 && "$WARN_ROWS" == "$AC_ROWS" && "$HAS_NOT_EXEC_HEADER" -eq 0 && "$CHECKED" -ge 3 ]]; then
    echo "⚠️  零真操作违规: 全部 $AC_ROWS 个 AC 均为 ⚠️/未验证/需人工抽验，但未标 'self-test not executed' 且勾选了诚实声明"
    echo "    参考: .codebuddy/skills/core/self-testing/SKILL.md #零真操作边界（v0.2.0）"
    echo "    修法: 补至少 1 个 integration_test 通过 AC，或在 header 加 'self-test not executed · reason: <说明>'"
  fi
fi

# === 结果 ===
if [[ ${#ERRORS[@]} -eq 0 ]]; then
  echo "✓ 所有 done 门禁检查通过，可以标 status=done"
  exit 0
else
  echo ""
  echo "⛔ 不能标 status=done，以下门禁未通过："
  echo ""
  for err in "${ERRORS[@]}"; do
    echo "  $err"
  done
  echo ""
  echo "解决方式："
  echo "  1. 走完 closing 流程（code-reviewer → closer → knowledge-maintainer）"
  echo "  2. 或用户显式豁免：在 process.txt 写 'verdict=approve_go / 备注: 跳过 closer'"
  echo ""
  exit 1
fi
