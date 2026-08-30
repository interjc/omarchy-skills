<div align="right">

[English](CONTRIBUTING.md) | [简体中文](CONTRIBUTING_ZH.md)

</div>

# Contributing Guide 🤝

Thank you for your interest in contributing to **Omarchy Skills**!

Whether you want to share your Omarchy Linux AI automation recipes, submit a brand-new skill, fix script edge cases, or polish documentation, we welcome and appreciate your contributions.

---

## Table of Contents

1. [Ways to Contribute](#-ways-to-contribute)
2. [Skill Authoring Standards](#-skill-authoring-standards)
3. [Bilingual Documentation Policy](#-bilingual-documentation-policy)
4. [Omarchy Engineering & Design Principles](#-omarchy-engineering--design-principles)
5. [Development & Pull Request Workflow](#-development--pull-request-workflow)
6. [Code & Scripting Standards](#-code--scripting-standards)

---

## 💡 Ways to Contribute

- **Add a New Skill**: Package common Omarchy Linux power-user workflows, customizations, or integrations into reusable skills that AI agents can execute.
- **Improve Existing Skills**: Optimize setup scripts, handle corner cases, or improve runtime reliability.
- **Documentation & Localization**: Proofread guides, clarify instructions, or refine bilingual translations.
- **Report Issues**: If you run into compatibility issues across Omarchy versions or hardware configurations, please open a detailed GitHub Issue.

---

## 🛠️ Skill Authoring Standards

Each skill must reside in its own self-contained directory under `skills/<skill-name>/`:

```text
skills/<skill-name>/
├── SKILL.md                 # Required: Main instruction document (with YAML Frontmatter)
├── scripts/                 # Optional: Executable automation or maintenance scripts
│   └── setup.sh
├── references/              # Optional: Reference configs, patches, or architectural notes
└── examples/                # Optional: Example outputs, screenshots, or logs
```

### `SKILL.md` Format Requirements

`SKILL.md` must begin with valid YAML Frontmatter so agentic systems can discover and index the skill:

```markdown
---
name: omarchy-example-skill
description: A concise 1-2 sentence description explaining what this skill does and when to use it.
---

# Detailed Skill Title

## Background & Rationale
...

## Quick Start (Automated)
...

## Manual Setup Steps
...

## Verification & Testing
...
```

---

## 🌐 Bilingual Documentation Policy

To ensure seamless accessibility for both global developers and AI agents, **all primary project documentation must maintain full bilingual parity (English and Simplified Chinese)**.

### Mandatory Workflow
1. **Step 1 (Draft in Chinese)**: Write or update the Chinese documentation first (e.g., `README_ZH.md`, `CONTRIBUTING_ZH.md`).
2. **Step 2 (Review & Validate)**: Confirm technical accuracy, completeness, and clarity.
3. **Step 3 (Translate & Sync English)**: Faithfully translate the verified content into the corresponding English file (e.g., `README.md`, `CONTRIBUTING.md`), ensuring identical structure, headers, and key details.

### Language Switcher Header
Every bilingual document must include the standard language switcher at the top:
```markdown
<div align="right">

[English](CONTRIBUTING.md) | [简体中文](CONTRIBUTING_ZH.md)

</div>
```

---

## ⚙️ Omarchy Engineering & Design Principles

When writing skills and scripts for Omarchy Linux, adhere to these core principles:

1. **Non-Destructive Integration (Survives Updates)**:
   - **Never** modify system files inside `/usr/share/omarchy/` directly. Doing so risks having changes overwritten on `omarchy update`.
   - Always prefer user-level extensions and overrides:
     - Configuration: `~/.config/omarchy/`, `~/.config/omarchy/extensions/`
     - Binaries & Wrappers: `~/.local/bin/` (ensure it is on the user's `$PATH`)
     - Background Services: `~/.config/systemd/user/`
2. **Idempotency**:
   - Automation scripts should be safe to run multiple times without causing side effects or corrupting existing configurations.
3. **Confirmation-First for User Preferences**:
   - For subjective preferences (e.g. scrolling direction, hotkey bindings, UI themes, timeouts), agents and contributors must always confirm the user's specific requirements before modifying configurations, and provide interactive selection or CLI flags in scripts.
4. **Safety & Transparency**:
   - Do not silently overwrite existing user configs without checking or providing user notice.

---

## 🚀 Development & Pull Request Workflow

1. **Fork the Repository** to your GitHub account.
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/my-new-skill
   ```
3. **Develop & Test Locally**:
   - Create your skill directory under `skills/`.
   - Ensure all scripts have executable permissions: `chmod +x skills/<skill-name>/scripts/*.sh`.
   - Thoroughly test the installation, runtime execution, and rollback in a real Omarchy Linux environment.
4. **Synchronize Bilingual Docs**:
   - Register your new skill in the catalog table of both `README_ZH.md` and `README.md`.
5. **Commit and Open a Pull Request**:
   - Use Conventional Commits (e.g., `feat(skill): add omarchy-foo skill` or `docs: update contributing guide`).
   - Open a PR with a description of the test environment and verified results.

---

## 📜 Code & Scripting Standards

- **Shell Scripts**:
  - Must start with `#!/usr/bin/env bash`.
  - Must enforce strict mode: `set -euo pipefail`.
  - Print clear, structured progress logs (e.g., `echo "==> [1/3] Setting up..."`).
- **Markdown**:
  - Always specify code block syntax languages (`bash`, `jsonc`, `toml`, `lua`, etc.).
  - Maintain clean header hierarchies.

---

Thank you again for helping grow the **Omarchy Skills** ecosystem! 🎉
