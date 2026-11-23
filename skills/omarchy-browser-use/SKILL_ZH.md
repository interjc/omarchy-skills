---
name: omarchy-browser-use
description: 在 Omarchy Linux 本地开发环境中通过 opencode browse 与 Chrome 扩展让 AI Agent 直接操控本机真实浏览器（同时支持 MCP 与 CLI），包含安装、配对、调试与安全边界说明。
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy 本地开发 Browser Use（基于 `browse` + Chrome）

## 背景与适用范围

在本地开发调试 Web 应用时，常见的无头浏览器（Headless Playwright/Puppeteer）缺少本机登录态、Cookie 与扩展环境；而部分 IDE 内置预览浏览器与日常主力 Chrome 相互隔离。

本技能整理了一套已在 **Omarchy `4.5.0-3`（2026-11-23 实测）** 调通的用户级方案：使用 [`opencode.ai/browse`](https://opencode.ai/browse)（实测版本 `0.1.5`）在本地启动轻量中继服务（`http://127.0.0.1:19988`），通过 Chrome 扩展连接用户正在使用的真实 Chrome 家族浏览器，同时为 AI Agent 提供 **MCP 服务器（`browse mcp`）** 与 **命令行工具（`browse <tool>`）** 两种调用入口。

### 架构与无侵入性原则

- **完全用户级安装**：仅写入 `~/.local/bin/browse`、`~/.config/browse`、`~/.local/share/browse`、`~/.local/state/browse`、`~/.cache/browse` 及用户选择的各 Agent 个人配置文件，**绝不修改 `/usr/share/omarchy/` 或 `/etc/`**。
- **双通道可用**：
  - **MCP 模式**：重启已运行的 Agent（如 Antigravity、OpenCode、Claude Code、Codex、Gemini CLI、VS Code 等）后，Agent 自动通过 MCP 调用浏览器工具。
  - **CLI 模式**：安装配对后**立即可用**，无需等待重启 Agent，也便于本地脚本化验证（例如 `browse navigate`、`browse snapshot`、`browse console`、`browse network`、`browse screenshot`）。
- **人类接管与权限隔离**：支持 `handoff`（登录、2FA、验证码、支付确认交由人工完成）、`--allowedOrigins`（限制可访问域名）与 `--readOnly`（只读检查标签页）。

使用标准 skills CLI 安装本技能：

```bash
npx skills add interjc/omarchy-skills --skill omarchy-browser-use
# 或安装整套技能：npx skills add interjc/omarchy-skills
```

## 先确认再修改

执行安装或修改 Agent 配置前，先检查当前状态并向用户确认以下偏好，不要默认覆盖所有 Agent 配置：

1. **检查现有状态**：运行 `bash skills/omarchy-browser-use/scripts/setup.sh --status`（或 `browse status`）确认是否已安装二进制、中继服务是否运行以及浏览器是否已完成配对。
2. **确认安装来源**：下载并执行官方安装脚本 `https://opencode.ai/browse/install`（二进制安装至 `~/.local/bin/browse`，默认自动从 `stable` 通道更新；若需关闭自动更新，可在安装后运行 `browse update --mode off` 或 `notify`）。
3. **确认要接入的 Agent 范围**：
   - `all`：自动配置本机检测到/支持的全部 Agent（OpenCode、Antigravity、Claude Code、Codex、Gemini CLI、VS Code 等）。
   - 指定列表（如 `antigravity,codex,claude,opencode`）：仅写入明确选中的 Agent 配置文件。
   - `none` / `keep`：不改动任何 Agent 的 MCP 配置，仅打印配置片段或仅以 CLI 方式使用。
4. **确认是否立即配对浏览器**：选择是否立即生成一次性配对码并等待 Chrome 扩展完成连接。

## 快速开始

从仓库根目录运行（通过 `npx skills` 安装后，请改从实际安装目录运行 `scripts/setup.sh`）：

```bash
# 1. 只读检查当前 browse 安装、中继与配对状态（不修改任何文件）
bash skills/omarchy-browser-use/scripts/setup.sh --status

# 2. 交互式向导（逐项确认后再执行）
bash skills/omarchy-browser-use/scripts/setup.sh

# 3. 非交互显式参数示例：安装 browse，仅为 Antigravity 和 Codex 写入 MCP，并生成配对码
bash skills/omarchy-browser-use/scripts/setup.sh \
  --install yes \
  --agents antigravity,codex \
  --pair yes \
  --wait-seconds 180

# 4. 仅针对已安装的 browse 生成配对码，不改动 Agent 配置
bash skills/omarchy-browser-use/scripts/setup.sh \
  --install skip \
  --agents keep \
  --pair yes
```

### 脚本参数说明

| 参数 | 可选值 | 说明 |
| :--- | :--- | :--- |
| `--status` / `--check-only` | 无 | 只读检查二进制路径、版本、中继与扩展配对状态 |
| `--install` | `yes` \| `skip` | 缺失时是否通过官方脚本下载安装 `~/.local/bin/browse`（已安装则幂等跳过下载） |
| `--agents` | `all` \| `none` \| `keep` \| 逗号列表 | 配置全部 Agent、仅打印配置、保留现状或仅配置指定 Agent（如 `antigravity,claude`） |
| `--pair` | `yes` \| `skip` | 是否运行 `browse pair` 输出一次性配对码并等待浏览器连接 |
| `--wait-seconds` | 正整数（默认 `180`） | `--pair yes` 时的最长等待秒数 |
| `--help` / `-h` | 无 | 显示帮助，不执行任何写入 |

## 手动配置与配对步骤

若希望完全手动执行，按以下四步完成：

### 1. 安装 `browse` 二进制并配置 Agent

```bash
curl -fsSL https://opencode.ai/browse/install | bash
```

- 安装器会将二进制放到 `~/.local/bin/browse`，并在终端中提供多选列表以决定为哪些 Agent 写入 MCP 配置（例如 Antigravity 写入 `~/.gemini/config/mcp_config.json`，OpenCode 写入 `~/.config/opencode/opencode.json`，Claude Code 写入 `~/.claude.json`，Codex 写入 `~/.codex/config.toml`）。
- 若要无交互指定 Agent，可运行：
  ```bash
  ~/.local/bin/browse install -a antigravity -a codex --no-open --no-wait
  ```

### 2. 安装 Chrome 扩展

在 Chrome（或 Chromium 家族浏览器）中打开 Chrome Web Store 并安装 `browse` 扩展：

- 扩展地址：`https://chromewebstore.google.com/detail/mfnicocicmmlkpjnaffgihfjhdgjkdjg`

### 3. 将浏览器与本地中继配对

安装完扩展并打开 Chrome 后，若扩展提示尚未配对（`browse found the relay on this computer, but this browser isn't paired with it yet`），运行以下命令获取一次性配对码：

```bash
~/.local/bin/browse pair --wait-seconds 180
# 或重新执行：~/.local/bin/browse install -y
```

然后在 Chrome 中：
1. 打开 **Extensions（扩展程序） → browse → Options（选项）**（或直接在扩展提示页下方点击 **Pair with a code**）。
2. 输入终端打印的一次性配对码（格式如 `XXXX-XXXX`）。
3. 点击 **Connect** 完成配对。

### 4. 重启已运行的 Agent（启用 MCP）

配对完成后：
- 重启已运行的 Agent 客户端（或在 T3 Code / 终端中开启新会话）即可加载 `browse` MCP 工具。
- 当前未重启的会话也可以**直接通过 CLI**（`~/.local/bin/browse ...`）操控已配对的 Chrome。

## 本地开发常用工作流

### 打开本地开发页面并保持可见

> **重要提示**：`browse navigate <url>` 默认打开**后台标签页**，并在空闲一段时间后自动关闭。本地开发时若希望直观看到页面并保持打开，请加上 `--keepVisible --keepOpen`：

```bash
# 打开本地 dev server 或公网页面，保持可见且不因空闲关闭
browse navigate http://localhost:3000 --keepVisible --keepOpen --group local-dev
```

命令会返回 JSON，其中 `tab` 字段为该标签页 ID（后续操作均通过 `--tab <id>` 指定）：

```json
{
  "url": "http://localhost:3000/",
  "navigated": true,
  "title": "My App",
  "status": 200,
  "tab": 1829832789
}
```

### 常用调试命令速查

```bash
# 查看页面结构与可交互元素 ref（如 e12）
browse snapshot --tab <id>

# 点击、输入、按键与等待
browse click e12 --tab <id>
browse fill e5 "hello" --tab <id>
browse press Enter --tab <id>
browse wait_for --text "Saved" --tab <id>

# 捕获控制台错误、网络请求与页面截图 / 视觉对比
browse console --tab <id>
browse network --tab <id>
browse screenshot --tab <id> --output /tmp/page.png
browse screenshot_diff --tab <id> ...

# 移动端视口 / 深浅色模式仿真
browse emulate --tab <id> --json '{"viewport":{"width":390,"height":844,"mobile":true},"colorScheme":"dark"}'

# 查看所有受管标签页 / 关闭整组或单个标签页
browse tabs
browse tabs close --tab <id>
```

### 安全边界与 Agent 沙箱注意事项

- **限制域名与只读模式**：对敏感页面或仅做排查时，建议在打开标签页时附加 `--allowedOrigins '["http://localhost:3000"]'` 或 `--readOnly`。
- **人工接管（Handoff）**：遇到登录、2FA、人机验证（CAPTCHA）或支付确认时，使用 `browse handoff --tab <id>` 交由用户本人操作，切勿尝试绕过验证。
- **Agent 终端沙箱说明**：`browse` CLI 需要读取 `~/.config/browse` 并访问本地回环地址 `http://127.0.0.1:19988`。如果在受限无网络沙箱中运行，可能会报错 `browse: browse relay did not start at http://127.0.0.1:19988`。遇到此情况时：
  - 优先在重启 Agent 后直接调用已加载的 `browse` MCP 工具；或
  - 在允许访问本地回环中继的终端环境中执行 `browse` CLI。
- **自动更新控制**：默认开启 `stable` 通道自动更新；若希望锁定版本，可执行 `browse update --mode notify` 或 `browse update --mode off`。

## 验证与回滚

### 实机验证

```bash
# 检查二进制、中继地址、扩展配对状态和已配置 Agent
browse status

# 列出可用工具
browse tools

# 冒烟测试：在真实 Chrome 中打开页面并确认返回 status 200 与 tab id
browse navigate https://www.google.com --keepVisible --keepOpen
```

### 仓库脚本离线测试

```bash
bash -n skills/omarchy-browser-use/scripts/setup.sh
bash -n skills/omarchy-browser-use/scripts/test.sh
bash skills/omarchy-browser-use/scripts/test.sh
```

### 解除配对与卸载

```bash
# 查看已配对的浏览器并按需解绑单个浏览器
browse pair --list
browse pair --revoke <browser-id-or-name>

# 完整卸载：从各 Agent 移除 MCP 配置、停止本地中继并删除 ~/.local/bin/browse 及用户数据
browse uninstall
```
