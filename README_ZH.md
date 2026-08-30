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
npx skills add interjc/omarchy-skills --skill omarchy-macbook-behavior
```

---

## 📚 Skills 技能目录

| 技能名称 | 描述说明 | 状态 |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | 在 Omarchy 中无缝将默认 Agent 替换为 Antigravity CLI (`agy`)，并支持状态栏实时额度监控。 | `v1.0.0` (稳定) |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL.md) | 贴合 MacBook / macOS 习惯的系统体验：三指拖拽、打字防误触、中/日/英输入法及快捷键。 | `v1.0.0` (稳定) |

---

## 🚀 精选技能详情

### 1. `omarchy-agent-agy` — Antigravity Agent 与状态栏集成

> **目标**：在 Omarchy 的系统 Agent 白名单、Quickshell 菜单、Hyprland 快捷键以及顶部状态栏中，无缝将旧版 `gemini` 替换为 Google Antigravity CLI (`agy`)。

#### 核心亮点
- **无侵入式 Agent 映射**：在 `~/.local/bin/gemini` 部署透明包装脚本（Shim），自动转换命令行参数（`--yolo` → `--dangerously-skip-permissions`、`-i`、`-p`）并调起 `agy`，不怕系统升级覆盖。
- **Quickshell 菜单文本定制**：在设置菜单（`SUPER + SPACE`）中显示 **"Antigravity (agy)"** 与对应图标 `󰫢`。
- **状态栏全天候额度监控 (`ai-usagebar`)**：配置轻量级 `systemd` 用户守护进程（`agy-daemon.service`，`stream-json` 模式，零空闲 CPU 占用），无需前台常开终端即可通过 RPC 查询配额。

```bash
bash skills/omarchy-agent-agy/scripts/setup.sh
```

---

### 2. `omarchy-macbook-behavior` — MacBook 人体工学与习惯定制

> **目标**：让 Omarchy Linux 的触摸板手势、输入法交互与桌面快捷键全面贴近 macOS / MacBook 经典使用习惯。

#### 核心亮点
- **触摸板人体工学与手势**：
  - **三指拖拽 (`drag_3fg = 1`)**：无缝还原 macOS 辅助功能的三指拖移，选中文本与移动窗口无需用力按压。
  - **打字防误触 (`disable_while_typing = true`)**：键盘打字时自动禁用触摸板，彻底避免掌心误触光标乱跳。
  - **自然滚动 (`natural_scroll = true`)**：滚轮方向与 macOS 触控板完全一致。
  - **轻触点击与点按手势**：单指左键、双指右键、三指中键。
- **macOS 多语言输入法生态 (Fcitx5 + 雾凇拼音 + Mozc)**：
  - **中文**：`fcitx5-rime` 深度集成 **Rime-Ice (雾凇拼音)** 词库。
  - **日语**：`fcitx5-mozc` (Google 日语输入法引擎)。
  - **快捷键对齐**：`Control + Space` 切换输入法，单按左 `Shift` 即时中英文切换，`Super + Space` 循环切换输入法组。
  - **独立窗口状态 (`ShareInputState = No`)**：各应用窗口独立记忆中英文状态。
- **MacBook 级电源与睡眠管理 (合盖即走 & 蛤壳模式)**：
  - **合盖即走**：笔记本合盖即刻安全锁屏并挂起睡眠，按键/触摸即刻秒醒。
  - **蛤壳外接屏模式 (Clamshell)**：外接显示器时合盖不休眠，无缝关闭内屏并转移主显示输出。
  - **Logind 锁屏延迟保护 (`InhibitDelayMaxSec=15`)**：确保显示安全锁屏彻底完成后再进入硬件睡眠。
- **macOS 风格截屏与系统快捷键**：
  - `ALT + SHIFT + 4` 还原 Mac 区域截图（`omasnap`），`PRINT` / `F12` 全屏截图。

```bash
bash skills/omarchy-macbook-behavior/scripts/setup.sh
```

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
