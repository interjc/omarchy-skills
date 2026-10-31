<div align="right">

[English](README.md) | [简体中文](README_ZH.md)

</div>

# Omarchy Skills 🧙‍♂️

专为 **[Omarchy Linux](https://omarchy.org)** 整理的 AI Agent 技能、用户级定制与自动化工作流合集。

由 **Justin**（[@interjc](https://x.com/interjc) · [interjc.net](https://interjc.net)）创建并维护。

---

## 🌟 项目愿景

**Omarchy Skills** 将日常使用 Omarchy Linux 的配置经验与桌面工作流整理为模块化 AI Skills，供 Antigravity、Claude Code、Codex 等助手发现和使用。先检查已安装版本与个人配置，再确认偏好，只应用获准的改动。

---

## 📦 快速安装

推荐使用 `npx skills` 工具安装本仓库中的 Skills：

```bash
# 添加本仓库中的所有技能
npx skills add interjc/omarchy-skills

# 或者直接安装指定技能
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
npx skills add interjc/omarchy-skills --skill omarchy-macbook-behavior
```

---

## 📚 Skills 技能目录

| 技能名称 | 描述说明 | 验证范围 |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL_ZH.md) | 按实际能力选择原生 `agy` 或经批准的旧版兼容；后台会话与额度栏为可选项。 | 沙盒测试；`4.0.6-1` 旧版映射、服务和配额实测 |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL_ZH.md) | 按确认偏好添加 Lua 触摸板与快捷键覆盖；输入法、电源及硬件诊断另行手动处理。 | 沙盒测试；`4.0.6-1` 快捷键加载和截图输出实测 |

---

## 兼容性与验证范围

**2026-10-31 审计快照**：分别检查稳定标签 **`v4.0.6`** 与默认分支 **`quattro`** 的提交 **`bda3aaf6955404712dbd46541e6c8a75a2b16b7c`**，不将开发分支能力视为稳定版已发布功能。

| 项目 | `v4.0.6` | 固定的 `quattro` 快照 |
| :--- | :--- | :--- |
| Agent 分发与默认值 | `gemini --yolo`；默认设置器拒绝 `agy` | 原生 `agy --dangerously-skip-permissions`；`gemini` 等别名归一为 `agy` |
| 默认菜单条目 | `setup.default.agent.gemini` | `setup.default.agent.agy` |
| 截图入口 | 实机包装器仍为旧截图流程，保留已安装的 `omasnap` | 官方包装器调用 Omasnap，优先使用包装器 |
| Hyprland 工作流 | 不具备快照中的默认手势开关及原生输入法键位 | MacBook 自动化以此 Lua 配置为目标；旧 `.conf` 配置需单独审查 |

固定上游依据：[稳定版分发器](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-agent)、[默认设置器](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-default-agent)；[快照分发器](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-agent)、[默认设置器](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-default-agent)、[Lua 默认模块](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/omarchy.lua)、[桌面键位](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/utilities.lua)、[输入法键位](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/input-method.lua)。

已完成源码审查、Shell/Lua 语法检查及临时 `HOME`/模拟命令的沙盒测试，并在获准的 `4.0.6-1` 实机上执行两项安装器，验证旧版 Agent 分发、服务初始化、独立缓存配额查询、快捷键加载和非全黑 PNG 输出。手势手感、滚动长截图、完整输入法交互、睡眠安全及 `quattro` 原生桌面仍未实测；这不是全功能稳定性认证。环境、执行命令、备份和明确边界见[双语验证记录](VALIDATION_ZH.md)。

---

## 🚀 精选技能详情

### 1. `omarchy-agent-agy`：Antigravity Agent 与可选额度栏

> **目标**：优先使用 Omarchy 原生 Antigravity CLI (`agy`) 支持，仅在检测到已知旧版且用户批准后使用 Gemini Shim。

#### 核心亮点
- **先检测、后选择**：读取已安装分发器与设置器的实际能力；原生路径使用 `omarchy-default-agent agy`，旧版 Shim 需单独批准，未知实现拒绝猜测。原生分发与旧版 Shim 均会跳过 Agent 权限提示。
- **安装范围明确**：仅处理获准的默认 Agent 映射与可选用户服务，不改菜单、快捷键、额度栏配置或 `shell.json`，不写 `/usr/share/omarchy/` 或 `/etc`。原生设置器可能通过 mise 安装工具并启动终端；`agy` 安装与认证须先检查。
- **实验性后台会话**：`stream-json` 用户服务单独选择启用；不保证额度接口、持续在线、零 CPU 或固定内存占用，服务运行不等于额度查询成功。
- **手动可选集成**：`ai-usagebar` 包、插件、完整状态栏布局及旧版菜单改名需分别审查和批准，按技能文档合并，不能直接覆盖个人配置。保留原生 `SUPER + SHIFT + CTRL + A` → `omarchy-agent --pick`。

```bash
# 交互式确认默认 Agent 与后台服务；非交互运行须显式指定两项选择
bash skills/omarchy-agent-agy/scripts/setup.sh
```

---

### 2. `omarchy-macbook-behavior`：MacBook 触摸板与快捷键偏好

> **目标**：在现有 Omarchy 桌面上添加小范围、可选的触摸板与快捷键覆盖，不替换桌面栈，也不保证复刻 macOS。

#### 核心亮点
- **偏好先行**：选择自然滚动、传统滚动或保留触摸板，再分别选择截图与剪贴板快捷键；终端中交互确认，非交互必须提供全部选择。
- **托管 Lua 覆盖**：选择滚动方向同时启用三指拖拽、打字时禁用触摸板及替代四指手势，并关闭上游默认手势。仅管理独立模块及入口中的标记块，备份改动，保留个人 `input.lua`/`bindings.lua`；手感和防误触仍依赖硬件验证。
- **先审计键位**：只读脚本区分实时绑定与上游快照。快照默认截图为 `Print` / `SUPER + CTRL + ALT + C`（不是 F12），剪贴板历史为 `SUPER + CTRL + V`；可选 `SUPER + CTRL + A` 截图会替换音频键，`ALT + SHIFT + 4` 是替代组合，`SUPER + SHIFT + Z` 仅为可选剪贴板别名。检查 PATH 中实际截图包装器，确认调用 Omasnap 才使用 `omarchy-capture-screenshot`，旧版否则保留已安装的 `omasnap`。
- **输入法另行确认**：快照原生 `SUPER + I` / `SUPER + SHIFT + I` 切换输入语言，`SUPER + SPACE` 打开菜单，`CTRL + SPACE` 保留为不吞键的终端前缀辅助。Mozc 优先用原生配置器；Rime/雾凇按需手动合并，组切换不等于组内引擎切换。
- **不是全套安装器**：不安装软件包、不写系统目录、不配置 Fcitx/Rime、电源、udev、logind 或空闲定时器。合盖与外接屏优先检查原生行为；手动可选步骤需单独诊断与批准，旧版技能遗留改动不会自动撤销。

```bash
# 只读快捷键审计
bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh

# 仅配置确认后的触摸板与快捷键偏好
bash skills/omarchy-macbook-behavior/scripts/setup.sh
```

以上脚本路径以仓库根目录为准；通过 skills CLI 安装后，请从实际安装的技能目录运行 `scripts/setup.sh`。完整选项、手动步骤、验证与回滚见各 `SKILL.md`。

---

## 🗺️ 后续路线图 (Roadmap)

- [ ] **Omarchy Waybar & Quickshell 专属小部件**：AI Agent 状态、GPU 占用与工作区增强组件。
- [ ] **Hyprland AI 高效工作流**：浮动 Scratchpad、动态窗口布局与模态 AI 快捷操作。
- [ ] **Dotfiles 配置自动化备份与同步**：Omarchy 用户配置的快照与多机同步方案。
- [ ] **本地 LLM 与 Ollama / llama.cpp 集成**：本地模型的系统级接入与状态栏快捷切换。

---

## 🤝 贡献指南

欢迎提交新的 Skill、改进现有文档或提出建议！参与贡献前请查阅 [贡献指南 (CONTRIBUTING_ZH.md)](./CONTRIBUTING_ZH.md)。

---

## 👤 作者信息

**Justin**
- 𝕏 (Twitter): [@interjc](https://x.com/interjc)
- 🌐 个人博客: [interjc.net](https://interjc.net)
- 🐙 GitHub: [@interjc](https://github.com/interjc)

---

## 📄 开源许可

本项目遵循 [MIT 许可证](./LICENSE) 开源。
