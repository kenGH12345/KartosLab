#!/usr/bin/env python3
"""Validate lesson JSON file(s) against schemas/lesson.schema.json.

Usage:
  python validate_lesson_schema.py <lesson.json> [more.json ...]

Exit code 0 if all valid; prints per-error lines and exits 1 otherwise.
Also importable: `from validate_lesson_schema import validate_lesson` (same dir).

Background:
  - T-P3-02 (schema test) and T-P3-04 (generate.py --lesson) share this single
    entry point so the test and the tool never drift.
  - Only *structural* validation lives here (JSON Schema). Graph checks
    (entry reachability, route target existence, leaf nodeId refs, D5/D7
    invariants, scenarioPlayable D10) stay in the Dart layer
    (LessonPlan.fromJson / lesson_sim_host.dart).
"""
from __future__ import annotations

import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMA_PATH = os.path.join(ROOT, "schemas", "lesson.schema.json")


def _load_schema():
    with open(SCHEMA_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)


def validate_lesson(data: dict) -> list[str]:
    """Return a list of schema error messages (empty = valid)."""
    import jsonschema

    validator = jsonschema.Draft202012Validator(_load_schema())
    return [
        f"{'/'.join(str(p) for p in e.path)}: {e.message}"
        for e in validator.iter_errors(data)
    ]


def main() -> None:
    if len(sys.argv) < 2:
        # No input files: just prove the schema is constructible (AC-46 gate).
        try:
            _load_schema()
        except Exception as e:  # noqa: BLE001
            print(f"ERROR: lesson.schema.json 不可用: {e}")
            sys.exit(1)
        sys.exit(0)

    bad = 0
    for path in sys.argv[1:]:
        try:
            with open(path, "r", encoding="utf-8-sig") as f:
                data = json.load(f)
        except Exception as e:  # noqa: BLE001
            print(f"{path}: 读取/解析失败: {e}")
            bad += 1
            continue
        for msg in validate_lesson(data):
            print(f"{path}: {msg}")
            bad += 1
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
