<div align="right">

[English](README.md) | [简体中文](README_ZH.md)

</div>

# Omarchy Skills 🧙‍♂️

专为 **[Omarchy Linux](https://omarchy.org)** 量身定制的生产级 AI Agent 技能、系统定制与自动化工作流合集。

由 **Justin**（[@interjc](https://x.com/interjc) · [interjc.net](https://interjc.net)）创建并维护。

---

## 🌟 项目愿景

**Omarchy Skills** 旨在将日常使用 Omarchy Linux 的进阶经验、系统配置技巧与桌面自动化实践，沉淀为开箱即用的模块化 AI Skills。AI 编程助手（如 Antigravity、Claude Code、Codex 等）能够直接发现、加载并执行这些技能，自动化完成复杂的系统集成，让你的 Omarchy 环境保持最佳状态。

---

## 📦 快速安装

推荐使用 `npx skills` 工具安装本仓库中的 Skills：

```bash
# 添加本仓库中的所有技能
npx skills add interjc/omarchy-skills

# 或者直接安装指定技能
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
```

---

## 📚 Skills 技能目录

| 技能名称 | 描述说明 | 状态 |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | 在 Omarchy 中无缝将默认 Agent 替换为 Antigravity CLI (`agy`)，并支持状态栏实时额度监控。 | `v1.0.0` (稳定) |

---

## 🚀 精选技能详情

### 1. `omarchy-agent-agy` — Antigravity Agent 与状态栏集成

> **目标**：在 Omarchy 的系统 Agent 白名单、Quickshell 菜单、Hyprland 快捷键以及顶部状态栏中，无缝将旧版 `gemini` 替换为 Google Antigravity CLI (`agy`)。

#### 核心亮点

1. **无侵入式 Agent 映射 (Non-Destructive)**：
   - 在 `~/.local/bin/gemini` 部署透明包装脚本（Shim），自动转换命令行参数（`--yolo` → `--dangerously-skip-permissions`、`-i`、`-p`）并调起 `agy`。
   - 保留 Omarchy 内部标识符 `gemini`，使系统原生命令（`omarchy agent`、`omarchy-default-agent`）正常工作，无需修改 `/usr/share/omarchy/` 任何系统文件，抵御系统升级覆盖。

2. **Quickshell 菜单文本定制**：
   - 通过 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 覆盖菜单项，在 Omarchy 设置菜单（`SUPER + SPACE`）中清晰显示 **"Antigravity (agy)"** 与对应图标 `󰫢`。

3. **状态栏全天候额度监控 (`ai-usagebar`)**：
   - 配置轻量级 `systemd` 用户级后台守护进程（`agy-daemon.service`，使用 `stream-json` 模式运行）。
   - 让 `ai-usagebar` 与桌面面板无需保持前台终端打开，即可通过 RPC 端口实时展示 Gemini 和 Claude/GPT 模型的 5 小时与每周配额进度及重置倒计时。

#### 快速部署

```bash
# 克隆或安装 Skill 后，执行一键自动化配置脚本：
bash skills/omarchy-agent-agy/scripts/setup.sh
```

如需查看详细的手动配置说明与原理解析，请参阅 [`skills/omarchy-agent-agy/SKILL.md`](./skills/omarchy-agent-agy/SKILL.md)。

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
