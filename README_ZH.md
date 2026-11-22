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
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL_ZH.md) | 按实际能力选择原生 `agy` 或经批准的旧版兼容，可选接入额度栏。 | `4.5.0-3` 包装脚本回归测试；`4.0.6-1` 历史实测 |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL_ZH.md) | 按确认偏好添加 Lua 触摸板与快捷键覆盖；输入法、电源及硬件诊断另行手动处理。 | `4.5.0-3` 本机配置审计与沙盒测试；`4.0.6-1` 历史实测 |

---

## 兼容性与验证范围

**2026-11-22 本机审计**使用 Omarchy **`4.5.0-3`** 和 Hyprland **`0.56.2-4`**。安装器仍根据已安装的实现选择路径。

| 项目 | 本机 `4.5.0-3` | 历史 `4.0.6-1` |
| :--- | :--- | :--- |
| Agent 分发与默认值 | 原生 `agy --dangerously-skip-permissions`，设置器将 `gemini` 等别名归一为 `agy` | `gemini --yolo`，设置器不接受 `agy` |
| 默认菜单条目 | `setup.default.agent.agy` | `setup.default.agent.gemini` |
| 截图入口 | 官方包装器调用 Omasnap 并传入通知参数 | 官方包装器使用旧截图流程，可用已安装的独立 `omasnap` |
| Hyprland 工作流 | 已有原生输入法快捷键，已安装的默认模块不读取手势禁用标志 | Lua 配置缺少原生输入法快捷键和默认手势模块 |

4.5 审计核对了已安装源码、实际快捷键、触摸板值及用户服务。随后验证了快捷键迁移和原生输入法切换，沙盒测试覆盖原生 Agent 分发及手势配置迁移。4.5 结果和旧版实机测试见[双语验证记录](VALIDATION_ZH.md)。[Omarchy 4.5.0 发布记录](https://github.com/omacom/omarchy/releases/tag/v4.5.0)

---

## 🚀 精选技能详情

### 1. `omarchy-agent-agy`：Antigravity Agent 与可选额度栏

> **目标**：优先使用 Omarchy 原生 Antigravity CLI (`agy`) 支持，仅在检测到已知旧版且用户批准后使用 Gemini Shim。

#### 核心亮点
- **先检测、后选择**：读取已安装分发器与设置器的实际能力；原生路径使用 `omarchy-default-agent agy`，旧版 Shim 需单独批准，未知实现拒绝猜测。原生分发与旧版 Shim 均会跳过 Agent 权限提示。
- **安装范围明确**：仅处理获准的默认 Agent 映射与可选用户服务，不改菜单、快捷键、额度栏配置或 `shell.json`，不写 `/usr/share/omarchy/` 或 `/etc`。原生设置器可能通过 mise 安装工具并启动终端；`agy` 安装与认证须先检查。
- **额度查询与后台会话**：ai-usagebar `1.52.3` 支持通过已登录的 `agy -p "/quota"` 获取额度。`stream-json` 用户服务仅按需启用，独立验证额度是否可用。
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
- **托管 Lua 覆盖**：选择滚动方向同时启用三指拖拽、打字时禁用触摸板及替代四指手势。只有已安装的默认模块读取禁用标志时才设置它。脚本备份改动，管理独立模块和标记块，并保留个人 `input.lua`/`bindings.lua`。
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
