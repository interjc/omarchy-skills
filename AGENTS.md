# Agent Guidelines for `omarchy-skills`

This document defines the development, documentation, and maintenance rules for AI agents (and human contributors) working on the `interjc/omarchy-skills` repository.

---

## 🌐 1. Bilingual Documentation Policy (双语文档规范)

All major project documentation (such as `README`, `CONTRIBUTING`, and architecture guides) **must maintain full bilingual parity** (Simplified Chinese and English).

### Rules & Workflow
1. **Workflow Order (工作流顺序)**:
   - **Step 1**: Write / refine the Chinese version first (`*_ZH.md` or Chinese draft).
   - **Step 2**: Confirm accuracy, completeness, and phrasing.
   - **Step 3**: Translate and synchronize to the English version (`*.md`).
2. **File Naming Convention (文件命名约定)**:
   - English (Default): `README.md`, `CONTRIBUTING.md`, etc.
   - Chinese: `README_ZH.md`, `CONTRIBUTING_ZH.md`, etc.
3. **Language Switch Header (语言切换导航)**:
   - Every bilingual document must place a standard switcher at the top of the file:
     ```markdown
     [English](README.md) | [简体中文](README_ZH.md)
     ```

---

## 🤝 2. User Preference Confirmation Policy (用户意图与偏好确认原则)

Configurations that involve subjective user habits (e.g., scrolling direction, hotkey mapping, layout styles, timeout durations) **must follow a strict confirmation-first process**:

1. **Pre-Execution Confirmation**:
   - AI agents must never assume subjective preferences without asking.
   - Present available options clearly to the user, confirm their exact preferences, and only then proceed with modifying the configuration.
2. **Interactive & Configurable Scripts**:
   - Helper scripts (such as `scripts/setup.sh`) must support interactive prompts when run in a terminal to allow users to choose their preferred option.
   - Scripts must also accept explicit CLI flags (e.g. `--traditional-scroll`, `--natural-scroll`) for non-interactive / CI automation.
3. **Clear Documentation**:
   - All `SKILL.md` and reference files must explain the alternatives and explicitly document how users can customize each setting.

---

## 🛠️ 3. Skill Directory Structure & Standards

Each skill must follow a consistent modular structure under `skills/<skill-name>/`:

```text
skills/<skill-name>/
├── SKILL.md                 # Required: Main instruction file with YAML frontmatter
├── scripts/                 # Optional: Executable helper and setup scripts
│   └── setup.sh
├── references/              # Optional: Reference documentation, configs, or patches
└── examples/                # Optional: Example outputs, screenshots, or logs
```

### `SKILL.md` Requirements
- Must contain YAML frontmatter:
  ```yaml
  ---
  name: <skill-name>
  description: <concise 1-2 sentence description>
  ---
  ```
- Clear, structured sections explaining:
  - Background & Architecture rationale.
  - Quick Start (automated script if applicable).
  - Manual step-by-step instructions with all configurable options.
  - Verification & testing commands.

---

## ⚙️ 4. Omarchy Engineering Principles

When designing skills for Omarchy Linux:
1. **Non-Destructive Integration (无侵入性原则)**:
   - **Never** modify `/usr/share/omarchy/` directly (system updates will overwrite changes).
   - Prefer user-level overrides (`~/.config/omarchy/`, `~/.local/bin/`, `~/.config/systemd/user/`).
2. **Automation Scripts**:
   - Always use `#!/usr/bin/env bash` and `set -euo pipefail`.
   - Ensure scripts are executable (`chmod +x`).
   - Support idempotency (safe to run multiple times).

---

## 📦 5. Distribution & Installation

Always recommend the standard skills CLI:
```bash
npx skills add interjc/omarchy-skills
npx skills add interjc/omarchy-skills --skill <skill-name>
```
