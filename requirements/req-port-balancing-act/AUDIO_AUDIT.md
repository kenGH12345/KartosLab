# Balancing Act — Audio Audit

> Phase 0 · Source-only · 2026-09-23

---

## Verdict

| Item | Status |
|------|--------|
| Local `*.mp3` / `*.wav` / `*.ogg` | **NONE** in balancing-act tree |
| `simFeatures.supportsSound` | `true` (`package.json`) |
| UI sound category | Forced to **0** output level |
| Game sound | via **vegas `GameAudioPlayer`** (assets outside this repo) |

---

## Entry-point silencing

`js/balancing-act-main.ts` L40:

```typescript
soundManager.setOutputLevelForCategory( 'user-interface', 0 );
```

→ 常规 UI 点击音在本 sim 中被静音。

---

## Game audio triggers

**Class**: `vegas/GameAudioPlayer`（`BalanceGameView.ts`）

| Event | Method | Approx trigger | Source |
|-------|--------|----------------|--------|
| Correct answer | `correctAnswer()` | Check 正确 | BalanceGameView ~L484 |
| Wrong answer | `wrongAnswer()` | Check 错误 | ~L500, L516 |
| Game over perfect | `gameOverPerfectScore` | Level complete | ~L551–557 |
| Game over zero | `gameOverZeroScore` | Level complete | same |
| Game over imperfect | `gameOverImperfectScore` | Level complete | same |

音资源位于 **vegas / tambo** 依赖包，**不在** balancing-act `images/` 或 `assets/`。

---

## Non-Game screens

Intro / Balance Lab：**无** drop / collision / balance 专用音效调用（源码审计范围内）。

---

## Asset table

| Event | Audio Asset | Trigger | Source | Status |
|-------|-------------|---------|--------|--------|
| UI click | tambo UI category | controls | soundManager | **silenced** (level=0) |
| Correct | vegas GameAudioPlayer pack | Game Check OK | BalanceGameView | EXTERNAL (P2) |
| Wrong | vegas GameAudioPlayer pack | Game Check fail | BalanceGameView | EXTERNAL (P2) |
| Level complete variants | vegas pack | score thresholds | BalanceGameView | EXTERNAL (P2) |
| Drop / collision | — | — | — | **NOT APPLICABLE** |

---

## Migration notes

- Phase 0：**不要**自行替换音效。
- Game 音频标记为 **P2 candidate**（外部依赖）。
- Intro/Lab 可无声迁移而不丢核心行为。
- 若 Flutter 后续接入音效，优先 vendor vegas/tambo 对应资源，禁止随意网上找音。
