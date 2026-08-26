#!/usr/bin/env python3
"""AI scenario generator for kratos Flutter simulations.

Reads a sim-specific system prompt + few-shot samples, calls an OpenAI-compatible
LLM (default DeepSeek), validates the produced JSON against the sim schema, then
(optionally) writes it to assets/scenarios/<sim>/ and updates that sim's manifest.

Design notes:
- The model is fully configurable via env vars / CLI flags. We use the OpenAI
  chat-completions protocol, so any OpenAI-compatible endpoint works
  (DeepSeek, OpenAI, local Ollama, internal gateway, ...).
- JSON enforcement prefers `response_format={"type":"json_object"}`; if the
  model ignores it, we fall back to extracting the first {...} block.
- This script is a DEV-TIME tool. It never runs inside the Flutter app.

Usage:
  python scripts/ai_scenario_gen/generate.py \
      --sim color_vision \
      --topic "make a scenario where red+green produce yellow challenge" \
      --level beginner \
      --write            # omit --write to only print to stdout (dry run)
"""

import argparse
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PROMPTS_DIR = os.path.join(ROOT, "docs", "prompts")
SCHEMAS_DIR = os.path.join(ROOT, "schemas")
SCENARIOS_DIR = os.path.join(ROOT, "assets", "scenarios")

# Map a sim slug to its prompt/schema base name and the assets subdir.
# Keep in sync with docs/prompts/*.md and schemas/*.json filenames.
SIM_MAP = {
    "circuit": "circuit",
    "color_vision": "color_vision",
    "forces": "forces",
    "molarity": "molarity",
    "optics": "optics",
    "radio_waves": "radio_waves",
    "sound": "sound",
    "wave_interference": "wave_interference",
}

# assets 下的场景目录名，与 sim key 并不一致（历史原因：部分目录用连字符，
# optics 场景平铺在 assets/scenarios 根目录）。
#
# 权威来源是各 sim 的 `ScenarioManager.manifestPath`（lib/<sim>/config/）——
# 若两者不一致，生成的场景会写进 app 永远不会加载的孤儿目录。
# 实证：曾因直接用 sim key 拼路径，在 assets/scenarios/color_vision/ 留下
# manifest.json + rgb-default.json 两个死文件（真实加载路径是 color-vision/）。
SCENARIO_DIR_MAP = {
    "circuit": "circuit",
    "color_vision": "color-vision",
    "forces": "forces",
    "molarity": "molarity",
    "optics": "",  # 平铺在 assets/scenarios 根目录
    "radio_waves": "radio-waves",
    "sound": "sound",
    "wave_interference": "wave-interference",
}


def scenario_dir(sim: str) -> str:
    """返回该 sim 的场景目录绝对路径（与 Dart ScenarioManager 加载路径一致）。"""
    sub = SCENARIO_DIR_MAP[sim]
    return os.path.join(SCENARIOS_DIR, sub) if sub else SCENARIOS_DIR


def scenario_dir_display(sim: str) -> str:
    """用于日志展示的相对路径。"""
    sub = SCENARIO_DIR_MAP[sim]
    return f"assets/scenarios/{sub}/" if sub else "assets/scenarios/"


def _load_text(path: str) -> str:
    # utf-8-sig strips a leading BOM if present (some schema/*.json files have one).
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read()


def build_user_prompt(sim: str, topic: str, level: str) -> str:
    extra = (
        "\n\nGenerate ONE scenario JSON for the {sim} simulation. "
        "Teaching goal/topic from the teacher: {topic}\n"
        "Difficulty level: {level}\n"
        "Follow the schema and the few-shot examples in the system prompt exactly. "
        "Output ONLY the JSON object, no prose, no markdown fences."
    ).format(sim=sim, topic=topic, level=level)
    return extra


def call_llm(system_prompt: str, user_prompt: str, args) -> str:
    # Lazy import so the script can run schema-only / dry-run without openai installed.
    try:
        from openai import OpenAI
    except ImportError:
        sys.exit(
            "ERROR: 'openai' package not installed. Run: pip install openai\n"
            "Alternatively, set --print-prompt to emit the assembled prompt and "
            "call your LLM manually, then pipe the JSON back via --from-stdin."
        )

    client = OpenAI(api_key=args.api_key, base_url=args.api_base)
    kwargs = {
        "model": args.model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": args.temperature,
    }
    if args.max_tokens:
        kwargs["max_tokens"] = args.max_tokens
    try:
        kwargs["response_format"] = {"type": "json_object"}
    except Exception:
        pass

    resp = client.chat.completions.create(**kwargs)
    return resp.choices[0].message.content or ""


def extract_json(text: str) -> dict:
    text = text.strip()
    # Strip markdown code fences if present.
    fence = re.match(r"^```(?:json)?\s*(.*?)\s*```$", text, re.DOTALL)
    if fence:
        text = fence.group(1)
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # Fallback: grab the first balanced {...} block.
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1 and end > start:
            return json.loads(text[start : end + 1])
        raise


def validate_schema(sim: str, data: dict) -> list[str]:
    """Return a list of error strings (empty = valid)."""
    try:
        import jsonschema
    except ImportError:
        return ["WARNING: jsonschema not installed; skipped schema validation. Run: pip install jsonschema"]

    schema_path = os.path.join(SCHEMAS_DIR, f"{SIM_MAP[sim]}_scenario.schema.json")
    if not os.path.exists(schema_path):
        return [f"schema not found: {schema_path}"]
    schema = json.loads(_load_text(schema_path))
    validator = jsonschema.Draft202012Validator(schema)
    return [f"{'/'.join(str(p) for p in e.path)}: {e.message}" for e in validator.iter_errors(data)]


def run_dart_validate(sim: str, data: dict, tmp_path: str) -> tuple[bool, str]:
    """Write data to a temp file and run validate_test.dart via `flutter test`
    (Dart semantic check). fromJson classes transitively import Flutter, so a
    standalone `dart run` cannot load them; `flutter test` can.
    """
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    import shutil
    import subprocess

    flutter_bin = shutil.which("flutter") or shutil.which("flutter.bat")
    if not flutter_bin:
        return False, "ERROR: 'flutter' not found on PATH; cannot run Dart semantic gate."
    here = os.path.dirname(os.path.abspath(__file__))
    proc = subprocess.run(
        [
            flutter_bin, "test", os.path.join(here, "validate_test.dart"),
            f"--dart-define=SCENARIO_SIM={sim}",
            f"--dart-define=SCENARIO_PATH={tmp_path}",
        ],
        capture_output=True,
        text=True,
    )
    return proc.returncode == 0, proc.stdout + proc.stderr


def update_manifest(sim: str, scenario_id: str, file_name: str) -> None:
    sim_dir = scenario_dir(sim)
    os.makedirs(sim_dir, exist_ok=True)
    manifest_path = os.path.join(sim_dir, "manifest.json")
    if os.path.exists(manifest_path):
        manifest = json.loads(_load_text(manifest_path))
    else:
        manifest = {"scenarios": []}
    scenarios = manifest.get("scenarios", [])
    if any(s.get("id") == scenario_id for s in scenarios):
        print(f"NOTE: scenarioId '{scenario_id}' already in manifest; updating file only.")
    else:
        scenarios.append({"id": scenario_id, "file": file_name})
    manifest["scenarios"] = scenarios
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)


# ---------------------------------------------------------------------------
# Lesson-plan (教学剧本) mode
# ---------------------------------------------------------------------------
# 与 Dart 侧 lesson_sim_host.dart 的 D10 已实现叶子集同口径（硬编码表——两侧
# 各自维护，改一侧必须同步另一侧，参考 ai_scenario_gen_consistency_test.dart）。
LESSON_LEAF_TYPES = {
    "circuit": {"circuitClosed", "componentPowered", "bulbBrightness", "componentCount"},
    "color_vision": {"colorMatch"},
}

# 剧本运行时宿主（D8 试点封闭集）。清单中其他 sim 场景标注"不可引用"。
LESSON_HOST_SIMS = ("circuit", "color_vision")


def _iter_leaves(cond):
    """递归收集条件树中的所有叶子（组合 all/any/not 展开）。"""
    if not isinstance(cond, dict):
        return
    if cond.get("type"):
        yield cond
        return
    for key in ("all", "any"):
        for sub in cond.get(key, []) or []:
            yield from _iter_leaves(sub)
    if isinstance(cond.get("not"), dict):
        yield from _iter_leaves(cond["not"])


def _is_completable(sim: str, data) -> bool:
    """D10 同口径可完成性：objectives/successCriteria 非空 且叶子 type ∈ 已实现集。

    与 LessonSimHosts.scenarioPlayable() 一致（含 cv 仅 rgb 屏、colorMatch≤1 静态
    互斥规则）。剔除不可完成场景——AI 不会产出引用它们的剧本。
    """
    if sim not in LESSON_LEAF_TYPES or data is None or not isinstance(data, dict):
        return False
    if sim == "color_vision":
        if data.get("screen") != "rgb":
            return False
        criteria = data.get("successCriteria")
    else:
        obj = data.get("objectives")
        if not isinstance(obj, dict):
            return False
        criteria = obj.get("successCriteria")
    if not isinstance(criteria, list) or not criteria:
        return False
    implemented = LESSON_LEAF_TYPES[sim]
    for cond in criteria:
        leaves = list(_iter_leaves(cond))
        if not leaves:
            return False
        for leaf in leaves:
            if leaf.get("type") not in implemented:
                return False
    if sim == "color_vision":
        # colorMatch 单场景只允许 1 个 colorMatch 叶子（D10 强化 · 互斥防护）
        color_matches = sum(1 for c in criteria for l in _iter_leaves(c)
                            if l.get("type") == "colorMatch")
        if color_matches > 1:
            return False
    return True


def collect_scenario_ids():
    """遍历 8 份 sim manifest 提取可引用场景 {sim, id, name} + 剔除计数。

    目录路径走 SCENARIO_DIR_MAP（连字符目录坑/optics 平铺根目录已在 map 内）。
    """
    catalog = {}
    rejected = 0
    for sim in SIM_MAP:
        sim_dir = scenario_dir(sim)
        manifest_path = os.path.join(sim_dir, "manifest.json")
        if not os.path.exists(manifest_path):
            continue
        try:
            with open(manifest_path, "r", encoding="utf-8-sig") as f:
                manifest = json.load(f)
        except Exception:  # noqa: BLE001
            continue
        for entry in manifest.get("scenarios", []):
            sid = entry.get("id")
            fname = entry.get("file")
            if not sid or not fname:
                continue
            data = None
            try:
                with open(os.path.join(sim_dir, fname), "r", encoding="utf-8-sig") as f:
                    data = json.load(f)
            except Exception:  # noqa: BLE001
                pass
            if not _is_completable(sim, data):
                rejected += 1
                continue
            catalog.setdefault(sim, []).append(
                {"id": sid, "name": entry.get("name", sid)}
            )
    return catalog, rejected


def format_scenario_catalog(catalog: dict, rejected: int) -> str:
    """分组 markdown 清单（替换 {{SCENARIO_IDS}} 占位符）。"""
    lines = ["（以下为本课时可引用场景，按 sim 分组——只引用清单内的 scenarioId）"]
    for sim in SIM_MAP:
        if sim not in catalog:
            continue
        note = "" if sim in LESSON_HOST_SIMS else "（⚠ 非剧本运行时宿主 · 不可引用）"
        lines.append(f"### {sim}{note}")
        for s in catalog[sim]:
            lines.append(f"- `{s['id']}` — {s['name']}")
    if rejected:
        lines.append(
            f"\n> 另有 {rejected} 个场景因判定不可完成或不可用被排除（未列出）。"
        )
    return "\n".join(lines)


def build_lesson_user_prompt(topic: str, level: str) -> str:
    return (
        "\n\nGenerate ONE lesson-plan JSON for the kratos lesson runtime. "
        "Teaching goal/topic from the teacher: {topic}\n"
        "Difficulty level: {level}\n"
        "Follow the schema and the few-shot examples in the system prompt exactly. "
        "Output ONLY the JSON object, no prose, no markdown fences."
    ).format(topic=topic, level=level)


def run_dart_validate_lesson(data: dict, topic_id: str) -> tuple[bool, str]:
    """lesson_validate_test.dart Dart gate（LessonPlan.fromJson + D10）。"""
    import re
    import shutil
    import subprocess
    import tempfile

    safe = re.sub(r"[^a-zA-Z0-9_-]", "", topic_id)[:20] or "lesson"
    tmp = os.path.join(tempfile.gettempdir(), f"{safe}-lesson-check.json")
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    flutter_bin = shutil.which("flutter") or shutil.which("flutter.bat")
    if not flutter_bin:
        return False, "ERROR: 'flutter' not found on PATH; cannot run Dart semantic gate."
    here = os.path.dirname(os.path.abspath(__file__))
    proc = subprocess.run(
        [
            flutter_bin, "test", os.path.join(here, "lesson_validate_test.dart"),
            f"--dart-define=LESSON_PATH={tmp}",
        ],
        capture_output=True,
        text=True,
    )
    return proc.returncode == 0, proc.stdout + proc.stderr


def update_lessons_manifest(lesson_id: str, file_name: str, data: dict) -> None:
    """写 assets/lessons/manifest.json（id 存在更新否则追加 · D9 sim 派生）。

    sim = entry 节点 scenario.sim；entry 为终点取首个非终点节点；无则报错。
    """
    lessons_dir = os.path.join(ROOT, "assets", "lessons")
    os.makedirs(lessons_dir, exist_ok=True)
    manifest_path = os.path.join(lessons_dir, "manifest.json")
    if os.path.exists(manifest_path):
        manifest = json.loads(_load_text(manifest_path))
    else:
        manifest = {"version": "1.0", "lessons": []}

    nodes = data.get("nodes", [])
    entry_id = data.get("entry")
    entry = next((n for n in nodes if n.get("id") == entry_id), None)
    sim = None
    if isinstance(entry, dict) and isinstance(entry.get("scenario"), dict):
        sim = entry["scenario"].get("sim")
    if not sim:
        for n in nodes:
            sc = n.get("scenario")
            if isinstance(sc, dict) and sc.get("sim"):
                sim = sc.get("sim")
                break
    if not sim:
        sys.exit("ERROR: 无法派生 lessons manifest 的 sim 字段（D9 入口归属）——"
                 "剧本 entry 节点须引用场景。")

    lessons = manifest.get("lessons", [])
    new_entry = {
        "id": lesson_id,
        "file": file_name,
        "name": data.get("name", lesson_id),
        "sim": sim,
    }
    for i, l in enumerate(lessons):
        if l.get("id") == lesson_id:
            lessons[i] = new_entry
            break
    else:
        lessons.append(new_entry)
    manifest["lessons"] = lessons
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)


def run_lesson_mode(args) -> None:
    """--lesson 主流程（方案 §7.3）：拼 prompt → 生成 → schema → 引用 → Dart → write。"""
    system_prompt = _load_text(os.path.join(PROMPTS_DIR, "lesson.md"))

    # 条件树共享附录（单一源：_shared/combinable_criteria.md · AC-51）
    shared_criteria = os.path.join(PROMPTS_DIR, "_shared", "combinable_criteria.md")
    if os.path.exists(shared_criteria):
        system_prompt += "\n\n---\n\n" + _load_text(shared_criteria)
    else:
        print(f"WARNING: 共享附录缺失 {shared_criteria} —— 生成结果可能不含组合算子说明")

    # 场景清单注入（T-P3-05 · AC-50）
    catalog, rejected = collect_scenario_ids()
    system_prompt = system_prompt.replace(
        "{{SCENARIO_IDS}}", format_scenario_catalog(catalog, rejected)
    )

    user_prompt = build_lesson_user_prompt(args.topic, args.level)

    if not args.api_key and not args.from_stdin and not args.print_prompt:
        sys.exit("ERROR: set DEEPSEEK_API_KEY (or --api-key), or use --from-stdin / --print-prompt.")

    if args.print_prompt:
        print("==== SYSTEM ====\n" + system_prompt + "\n==== USER ====\n" + user_prompt)
        return

    if args.from_stdin:
        raw = sys.stdin.read()
    else:
        raw = call_llm(system_prompt, user_prompt, args)

    try:
        data = extract_json(raw)
    except json.JSONDecodeError as e:
        sys.exit(f"ERROR: LLM output is not valid JSON: {e}\n--- raw ---\n{raw}")

    # 结构校验（与测试共享单一入口）
    from validate_lesson_schema import validate_lesson

    schema_errors = validate_lesson(data)
    if schema_errors:
        print("LESSON SCHEMA VALIDATION FAILED:")
        for e in schema_errors:
            print("  - " + e)
        sys.exit("ERROR: lesson rejected by schema validation.")

    # 本地引用校验（AC-55 前半）：所有节点 scenario ∈ 可用清单
    refs = [
        n["scenario"]["scenarioId"]
        for n in data.get("nodes", [])
        if isinstance(n.get("scenario"), dict)
    ]
    available = {s["id"] for sim in catalog.values() for s in sim}
    bad = sorted({r for r in refs if r not in available})
    if bad:
        sys.exit(f"ERROR: lesson references unavailable scenarios: {bad}")

    # Dart 语义校验（图校验 + D10）
    if not args.skip_dart:
        ok, out = run_dart_validate_lesson(data, args.topic)
        print(out.strip())
        if not ok:
            sys.exit("ERROR: lesson rejected by Dart semantic validation.")

    lesson_id = data.get("lessonId")
    if not lesson_id:
        sys.exit("ERROR: generated JSON missing 'lessonId'.")

    if args.write:
        lessons_dir = os.path.join(ROOT, "assets", "lessons")
        os.makedirs(lessons_dir, exist_ok=True)
        file_name = f"{lesson_id}.json"
        with open(os.path.join(lessons_dir, file_name), "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        update_lessons_manifest(lesson_id, file_name, data)
        print(f"WROTE: assets/lessons/{file_name} (+ lessons manifest updated)")
    else:
        print("DRY RUN (no --write): generated lesson below")
        print(json.dumps(data, ensure_ascii=False, indent=2))


def main() -> None:
    # Windows 控制台默认 GBK 无法编码 prompt/lesson 中的 emoji（✅/⚠…）
    # → 强制 UTF-8 输出（Python 3.7+；非 Windows 环境 reconfigure 为 no-op）。
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:  # noqa: BLE001
        pass

    p = argparse.ArgumentParser(description="Generate kratos scenario/lesson JSON via LLM.")
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument("--sim", choices=list(SIM_MAP.keys()), help="场景模式（生成单场景 JSON）")
    group.add_argument("--lesson", action="store_true", help="课时模式（生成 lesson-plan 剧本 JSON）")
    p.add_argument("--topic", required=True, help="teaching goal / scenario description")
    p.add_argument("--level", default="beginner")
    p.add_argument("--model", default=os.environ.get("DEEPSEEK_MODEL", "deepseek-chat"))
    p.add_argument("--api-base", default=os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1"))
    p.add_argument("--api-key", default=os.environ.get("DEEPSEEK_API_KEY", ""))
    p.add_argument("--temperature", type=float, default=0.7)
    p.add_argument("--max-tokens", type=int, default=0, help="0 = unset")
    p.add_argument("--write", action="store_true", help="write to assets/scenarios/<sim>/ and update manifest")
    p.add_argument("--print-prompt", action="store_true", help="print assembled prompt and exit (no LLM call)")
    p.add_argument("--from-stdin", action="store_true", help="read JSON from stdin instead of calling LLM")
    p.add_argument("--skip-dart", action="store_true", help="skip Dart semantic validation")
    args = p.parse_args()

    # --lesson 早分支（既有 --sim 主路径行为零变化）
    if args.lesson:
        run_lesson_mode(args)
        return

    if not args.api_key and not args.from_stdin and not args.print_prompt:
        sys.exit("ERROR: set DEEPSEEK_API_KEY (or --api-key), or use --from-stdin / --print-prompt.")

    system_prompt = _load_text(os.path.join(PROMPTS_DIR, f"{SIM_MAP[args.sim]}_scenario.md"))

    # 拼接 inquiryTask 共享附录（单一源：docs/prompts/_shared/inquiry_task.md）。
    # 该契约对所有 sim 相同，若复制进各 sim prompt 会产生 8 份副本漂移。
    shared_inquiry = os.path.join(PROMPTS_DIR, "_shared", "inquiry_task.md")
    if os.path.exists(shared_inquiry):
        system_prompt += "\n\n---\n\n" + _load_text(shared_inquiry)
    else:
        print(f"WARNING: 共享附录缺失 {shared_inquiry} —— 生成结果可能不含 inquiryTask")

    # 拼接组合判定条件共享附录（单一源：docs/prompts/_shared/combinable_criteria.md）。
    # all/any/not 组合算子对所有 sim 相同（解析端 lib/common/scenario/success_condition.dart）。
    shared_criteria = os.path.join(PROMPTS_DIR, "_shared", "combinable_criteria.md")
    if os.path.exists(shared_criteria):
        system_prompt += "\n\n---\n\n" + _load_text(shared_criteria)
    else:
        print(f"WARNING: 共享附录缺失 {shared_criteria} —— 生成结果可能不含组合算子说明")

    user_prompt = build_user_prompt(args.sim, args.topic, args.level)

    if args.print_prompt:
        print("==== SYSTEM ====\n" + system_prompt + "\n==== USER ====\n" + user_prompt)
        return

    if args.from_stdin:
        raw = sys.stdin.read()
    else:
        raw = call_llm(system_prompt, user_prompt, args)

    try:
        data = extract_json(raw)
    except json.JSONDecodeError as e:
        sys.exit(f"ERROR: LLM output is not valid JSON: {e}\n--- raw ---\n{raw}")

    schema_errors = validate_schema(args.sim, data)
    if schema_errors:
        print("SCHEMA VALIDATION FAILED:")
        for e in schema_errors:
            print("  - " + e)
        sys.exit("ERROR: scenario rejected by schema validation.")

    if not args.skip_dart:
        import tempfile

        tmp = os.path.join(tempfile.gettempdir(), f"{args.sim}-scenario-check.json")
        ok, out = run_dart_validate(args.sim, data, tmp)
        print(out.strip())
        if not ok:
            sys.exit("ERROR: scenario rejected by Dart semantic validation.")

    scenario_id = data.get("scenarioId")
    if not scenario_id:
        sys.exit("ERROR: generated JSON missing 'scenarioId'.")

    if args.write:
        sim_dir = scenario_dir(args.sim)
        os.makedirs(sim_dir, exist_ok=True)
        file_name = f"{scenario_id}.json"
        with open(os.path.join(sim_dir, file_name), "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        update_manifest(args.sim, scenario_id, file_name)
        print(f"WROTE: {scenario_dir_display(args.sim)}{file_name} (+ manifest updated)")
    else:
        print("DRY RUN (no --write): generated scenario below")
        print(json.dumps(data, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
