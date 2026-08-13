# AI Scenario Generator (offline dev-time tool)

Generates kratos scenario JSON via an LLM, validates it (JSON Schema + Dart
semantic gate), and (with `--write`) drops it into `assets/scenarios/<sim>/`
plus updates that sim's `manifest.json`.

This is a **dev-time tool** — it never runs inside the Flutter app. The
generated JSON is committed to the repo and loaded at runtime by each sim's
`ScenarioManager`.

## Prerequisites

- Python 3.10+ with `openai` and `jsonschema`:
  `pip install openai jsonschema`
- Flutter SDK (for the Dart semantic gate): `flutter test` is used because every
  `*_scenario.dart` transitively imports `package:flutter/material.dart`, which
  the standalone `dart run` VM cannot load.
- An OpenAI-compatible LLM endpoint. Default target is DeepSeek.

## Configure the model (any OpenAI-compatible endpoint)

Model is fully configurable — no hard-coded vendor. Set env vars or pass flags:

```bash
export DEEPSEEK_API_KEY=sk-...
export DEEPSEEK_BASE_URL=https://api.deepseek.com/v1   # OpenAI-compatible base
export DEEPSEEK_MODEL=deepseek-chat
```

To use a different provider, just point the two env vars elsewhere
(e.g. OpenAI `https://api.openai.com/v1` + `gpt-4o-mini`, or a local Ollama
`http://localhost:11434/v1` + `llama3`). CLI equivalents exist:
`--api-base`, `--api-key`, `--model`.

## Usage

Dry run (print JSON, no write, no LLM key needed if you pipe JSON in):

```bash
python scripts/ai_scenario_gen/generate.py --sim color_vision \
    --topic "challenge: produce yellow with only red+green" --level beginner
```

Generate via LLM and write to assets + manifest:

```bash
python scripts/ai_scenario_gen/generate.py --sim color_vision \
    --topic "white light through a red filter" --level beginner --write
```

Offline (no LLM): emit the assembled prompt, or feed JSON via stdin:

```bash
python scripts/ai_scenario_gen/generate.py --sim color_vision --topic x --print-prompt
cat my_scenario.json | python scripts/ai_scenario_gen/generate.py --sim color_vision --topic x --from-stdin --write
```

## Validation gates (both must pass before --write)

1. **JSON Schema** — `schemas/<sim>_scenario.schema.json` (range/enum/required).
2. **Dart semantic** — `validate_test.dart` routes the JSON through the sim's
   real `fromJson`. Catches errors a schema cannot (nested type coercion,
   internal parse failures). Run via `flutter test` (see file header).

## Supported sims

`circuit`, `color_vision`, `forces`, `optics`, `radio_waves`, `sound`,
`wave_interference`. Add a new sim by: (1) add `<sim>_scenario.schema.json` in
`schemas/`, (2) add `<sim>_scenario.md` in `docs/prompts/`, (3) register the slug
in `SIM_MAP` in `generate.py`, (4) add a `case` in `validate_test.dart`.
