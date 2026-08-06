---
skill_id: wepop-xlua-api-hygiene
skill_name: WePop XLua · API 卫生
scope: project/wepop-xlua
version: 0.1.0
created_at: "2026-07-17"
triggered_by: req-tikatuka-mvp 决策 30 · 3-Time Rule
---

# WePop XLua · API 卫生

## 触发条件

在为 WePop XLua 项目（`d:/WePop_trunk/Assets/XLuaWork/Src/System/**`）写任何 Lua 业务代码前，
必须遵循本 Skill。

覆盖需求：`req-tikatuka-mvp` 及后续 WePop XLua 新玩法。

## 沉淀源（3-Time Rule 触发证据）

| 次数 | 需求 | 症状 | 详见 |
|---|---|---|---|
| 1 | req-tikatuka-mvp M6-C | MatchSystem 11 处 `_matchState = "idle"` 等硬编码枚举 | `notes.md` 决策 29 |
| 2 | req-tikatuka-mvp M7-UI-half | InGameUICtrl 编造 `waitRoll/waitPlace/waitClear` phase 值（真实 Define.PHASE 为 `ROLL/PLACE/CLEAR_WAIT`） | `notes.md` 决策 29 |
| 3 | req-tikatuka-mvp M7-UI-B 前置调研 | 4 个 System 全线编造 `GameEnv.Get().SystemPool:GetSystem` API（真实惯例是 `PPLib.PPLuaSystem.<Name>`） | `notes.md` 决策 30 · 本 Skill 触发 |

## 4 类必须先 grep 验证的 API

### 1. System 间引用（跨 System 调用）

- ✅ **真实惯例**：`PPLib.PPLuaSystem.<SystemName>:<Method>()`
  ```lua
  PPLib.PPLuaSystem.SynthesisGameMainUISystem:GetActivityID()
  PPLib.PPLuaSystem.SynthesisRewardWayDataSystem:GetActivityData()
  PPLib.PPLuaSystem.LuaEventSystem:TriggerLuaEvent(...)
  PPLib.PPLuaSystem.LuaTableSystem:GetAllRecord(...)
  ```

- ❌ **禁止编造**：
  - `GameEnv.Get().SystemPool:GetSystem("XxxSystem")` · 不存在
  - 自定义 `_getXxxSystem()` 局部辅助函数 · 无必要
  - `require("System.Xxx.XxxSystem")` 拿实例 · 只能拿 module

- **证据文件**：`d:/WePop_trunk/Assets/XLuaWork/Src/System/SynthesisGame/SynthesisGameDataSystem.lua`

### 2. 网络发包（req/rsp/ntf 收发）

- ✅ **真实惯例**：
  ```lua
  local LuaNetSystem = PPLib.PPLuaSystem.LuaNetSystem
  LuaNetSystem:Send(msg, Protocol.CS_REQ_XXX)
  LuaNetSystem:SendWithMask(msg, Protocol.CS_REQ_XXX, Protocol.CS_RES_XXX)
  ```

- ❌ **禁止编造**：
  - `self.net:Send / self.net:SendWithMask` · 无 `self.net` 字段
  - `NetworkSystem:Send` · 是 C# 层名字 · Lua 层用 `LuaNetSystem`

- **证据文件**：`d:/WePop_trunk/Assets/XLuaWork/Src/System/SynthesisGame/SynthesisGameDataSystem.lua`

### 3. UI 数据绑定（DataSystem ↔ UICtrl）

- ✅ **真实惯例**（key-value 双端匹配）：
  ```lua
  -- DataSystem 端：定义 Key + setData 推送
  function DataSys:GetXxxDataKey()
      return "DataSys_GetXxxData"
  end
  function DataSys:setXxxData(data)
      self:setData(self:GetXxxDataKey(), data)
  end

  -- UICtrl 端：BindingData / getData 拉取
  self:BindingData(dataSys:GetXxxDataKey(), function(data) ... end)
  local data = self:getData(dataSys:GetXxxDataKey())
  ```

- ❌ **禁止编造**：
  - UICtrl 直接调 System 的 `GetXxx()` getter · 违反 MVC 分层
  - 凭空假设 `BindingUpdate / BindingModel / ModelKey` 等 API 名称
  - 在 System 里存字段供 UICtrl 直接 access

- **证据文件**：`SynthesisGameDataSystem.lua` `GetCurStageDataKey / setCurStageData`

### 4. Define 枚举字面量

- ✅ **真实惯例**：`Define.PHASE.INIT` / `Define.MATCH_STATE.IDLE` / `Define.ROOM_STATE.NONE`
- ❌ **禁止编造**：`"init"` / `"idle"` / `"none"` 等裸字符串
- 同记忆 `qwsyn0hr` 描述的枚举卫生规则

## 使用协议（编码前必走 3 步 Gate）

写业务代码前**必须**依次：

### 步骤 1 · grep 真实 API 存在

```bash
# 语义 grep（在 workspace 内可用）
grep_search "<拟用 API>" workspace-search-paths

# 若 grep_search 受 workspace 限制无匹配，改用 read_file 走绝对路径读样板
read_file d:/WePop_trunk/Assets/XLuaWork/Src/System/<样板玩法>/<样板文件>.lua
```

**推荐样板玩法**：
- **通用 CRUD 玩法**：`SynthesisGame`（`DataSystem` + `MainUISystem` + `MainUICtrl` 齐全）
- **对战/PVP 玩法**：`BackFlowExclusiveSystem` / `DIYMatchSystem`
- **列表页/滚动**：`SynthesisGamePassStageUICtrl`

### 步骤 2 · 看 3-5 个真实调用点

- 确认调用签名（参数顺序 / 返回值形态 / 是否 self:）
- 确认命名空间前缀（`PPLib.PPLuaSystem.` vs 别的）
- 确认是否有配套 helper（如 `LuaNetSystem` 通常配 `Protocol.CS_XXX` 常量）

### 步骤 3 · 动手写业务代码

- 严格按真实签名 · 禁止编造
- 若发现样板玩法之间惯例不一致 · 停下来问用户

## 例外条款

- Skill 未覆盖的新框架 API（如某个玩法新引入 API 而现有样板玩法都没用过）：
  - 不套此 Skill · 但需按 `20-verify-before-act.mdc` 信心 < 95% 追问用户
  - 追问后若确认可用 · 应把该 API 补入本 Skill 的对应类目

## 反面案例（本 Skill 建立前的错误示范）

**错误代码**（决策 30 前 · `TikaTukaMessageSystem.lua:20-30`）：
```lua
local function _getInGameSystem()
    return nil
    -- TODO: return GameEnv.Get().SystemPool:GetSystem("TikaTukaInGameSystem")
end
```

**修复方向**（决策 30 大修）：
```lua
-- 顶部 require 或函数内延迟解析
local ingameSys = PPLib.PPLuaSystem.TikaTukaInGameSystem
ingameSys:OnMatchResBody(body)
```

## 与其他规则的关系

- 记忆卫生（枚举字面量）→ 记忆 ID `qwsyn0hr`
- §3 读后改 → `00-engineering-principles.mdc`
- 信心阈值追问 → `20-verify-before-act.mdc`
- 3-Time Rule → `10-vibecoding-protocol.mdc` 第 5 条
- 项目结构 · Lua 源码根 · `d:/WePop_trunk/Assets/XLuaWork/Src/System/**` → `50-svn-branch-safety.mdc`

## 变更历史

> 2026-07-17 by req-tikatuka-mvp 决策 30 · 首建：
> 3-Time Rule 触发新建 · 覆盖 WePop XLua 项目 4 类 API 卫生规则。
> - 触发原因：M7-UI-B 前置调研发现 M6/M7 全线编造 `GameEnv.Get().SystemPool:GetSystem` API
> - 证据基线：`d:/WePop_trunk/Assets/XLuaWork/Src/System/SynthesisGame/SynthesisGameDataSystem.lua`
> - 联动更新：`requirements/req-tikatuka-mvp/notes.md:571` 的"若第 3 次再犯"预告改为"已触发 · Skill 已建"
