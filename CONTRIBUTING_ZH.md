<div align="right">

[English](CONTRIBUTING.md) | [简体中文](CONTRIBUTING_ZH.md)

</div>

# 贡献指南 🤝

感谢你关注并有意向为 **Omarchy Skills** 作出贡献！

无论你是想分享自己在 Omarchy Linux 中的 AI 自动化技巧、提交新的 Skill、修复脚本缺陷，还是改进文档，我们都非常欢迎你的参与。

---

## 目录

1. [贡献类型](#-贡献类型)
2. [Skill 编写规范](#-skill-编写规范)
3. [双语文档撰写规范](#-双语文档撰写规范)
4. [Omarchy 工程与设计原则](#-omarchy-工程与设计原则)
5. [开发与提交流程 (PR Workflow)](#-开发与提交流程-pr-workflow)
6. [代码与脚本风格](#-代码与脚本风格)

---

## 💡 贡献类型

- **新建 Skill**：将 Omarchy 的日常使用痛点或最佳实践打包为可供 AI Agent 执行的 Skill。
- **完善现有 Skill**：优化现有配置脚本、补充边缘场景处理或提升执行性能。
- **文档与本地化**：校对文档、改进示例说明或修正中英文翻译。
- **报告问题 (Issues)**：如果你在某些 Omarchy 版本上遇到适配问题，欢迎在 GitHub Issues 提交详细反馈。

---

## 🛠️ Skill 编写规范

每一个 Skill 都应作为一个独立的模块存放在 `skills/<skill-name>/` 目录下：

```text
skills/<skill-name>/
├── SKILL.md                 # 必选：Skill 核心指令文档（含 YAML Frontmatter）
├── scripts/                 # 可选：可执行的一键自动化配置或维护脚本
│   └── setup.sh
├── references/              # 可选：相关的配置文件、补丁或参考文档
└── examples/                # 可选：示例输出、截图或日志
```

### `SKILL.md` 格式要求

`SKILL.md` 必须以合法的 YAML Frontmatter 开头，以便 AI Agent 识别与索引：

```markdown
---
name: omarchy-example-skill
description: 一两句话清晰描述该 Skill 的作用与适用场景。
---

# Skill 详细标题

## 背景与设计考量
...

## 快速配置 (Quick Start)
...

## 手动配置步骤 (Manual Setup)
...

## 验证与使用 (Verification)
...
```

---

## 🌐 双语文档撰写规范

为了确保海内外开发者与 AI Agent 都能无障碍使用本仓库，**所有核心文档必须保持中英文双语同步**。

### 工作流顺序（强制约定）
1. **第一步（先写中文）**：编写或更新中文版文档（如 `README_ZH.md`、`CONTRIBUTING_ZH.md`）。
2. **第二步（确认内容）**：确保中文表述准确、技术逻辑完整、排版规范。
3. **第三步（翻译同步英文）**：将确认后的内容忠实翻译为对应的英文版文档（如 `README.md`、`CONTRIBUTING.md`），确保两份文档在结构和要点上保持严格一致。

### 语言切换标头
所有双语文档顶部必须包含语言快速切换导航：
```markdown
<div align="right">

[English](CONTRIBUTING.md) | [简体中文](CONTRIBUTING_ZH.md)

</div>
```

---

## ⚙️ Omarchy 工程与设计原则

编写针对 Omarchy Linux 的 Skill 与脚本时，请遵循以下核心原则：

1. **无侵入性原则 (Non-Destructive)**：
   - **严禁**直接修改 `/usr/share/omarchy/` 目录下的系统文件，否则在用户执行 `omarchy update` 时会被覆盖丢失。
   - 优先使用用户级目录进行扩展与覆盖：
     - 配置目录：`~/.config/omarchy/`、`~/.config/omarchy/extensions/`
     - 可执行文件：`~/.local/bin/`（确保用户 PATH 包含此路径）
     - 用户守护进程：`~/.config/systemd/user/`
2. **幂等性 (Idempotency)**：
   - 自动化脚本应该支持多次重复执行而不产生副作用或破坏现有配置。
3. **安全性与透明度**：
   - 脚本不应静默覆盖用户的私有配置，如需修改建议在脚本中进行检测与友好提示。

---

## 🚀 开发与提交流程 (PR Workflow)

1. **Fork 本仓库** 到你的 GitHub 账号。
2. **创建特性分支**：
   ```bash
   git checkout -b feature/my-new-skill
   ```
3. **编写与本地测试**：
   - 按照规范在 `skills/` 下添加目录与文件。
   - 确保 `scripts/*.sh` 具有可执行权限：`chmod +x skills/<skill-name>/scripts/*.sh`。
   - 在真实的 Omarchy 环境中完整测试安装、运行与卸载逻辑。
4. **同步双语文档**：
   - 在 `README_ZH.md` 与 `README.md` 的技能目录表中登记新 Skill。
5. **提交 Commit 并发起 Pull Request**：
   - 推荐使用 Conventional Commits 格式（如 `feat(skill): add omarchy-foo skill` 或 `docs: update contributing guide`）。
   - 提交 PR 并详细描述该 Skill 的测试环境与验证效果。

---

## 📜 代码与脚本风格

- **Shell 脚本规范**：
  - 必须以 `#!/usr/bin/env bash` 开头。
  - 启用严格模式：`set -euo pipefail`。
  - 关键步骤输出清晰的日志信息（例如 `echo "==> [1/3] Setting up..."`）。
- **Markdown 规范**：
  - 代码块必须指明语言标识符（如 `bash`、`jsonc`、`toml`、`lua` 等）。
  - 保持各级标题层级分明，避免无意义的空行堆叠。

---

再次感谢你为 **Omarchy Skills** 生态建设添砖加瓦！🎉
