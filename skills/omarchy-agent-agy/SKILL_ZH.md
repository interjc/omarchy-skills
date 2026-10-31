---
name: omarchy-agent-agy
description: 将 Antigravity CLI（agy）接入 Omarchy，优先使用原生默认 agent，仅在已检测的旧版中使用经授权的 Gemini shim。提供可选的实验性后台会话及用量栏手动配置说明。
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy Agent：Antigravity CLI

## 审计依据与架构

本技能于 **2026-10-31** 对照 Omarchy 默认分支 `quattro` 的提交
`bda3aaf6955404712dbd46541e6c8a75a2b16b7c` 和已获取的最新稳定标签 `v4.0.6` 核对。
这两个快照不同，不能把默认分支的能力说成稳定版已经具备：

| 检查项 | quattro 提交 | v4.0.6 |
| --- | --- | --- |
| `omarchy-agent` 分发 | 原生 `agy`，使用 `--dangerously-skip-permissions` | `gemini --yolo`，没有 `agy` 分支 |
| `omarchy-default-agent` | 接受 `agy`，并把 `gemini` 等别名规范化为 `agy` | 接受并保存 `gemini`，不接受 `agy` |
| 默认菜单项 ID | `setup.default.agent.agy` | `setup.default.agent.gemini` |
| 默认快捷键 | `SUPER + SHIFT + CTRL + A` → `omarchy-agent --pick` | 同左 |

因此，优先执行原生 `omarchy-default-agent agy`。不能在原生版本中直接把默认文件写成
`gemini`，因为其分发器不再支持这个 ID。只有已检测到旧版分发器和 setter、且用户明确
同意时，才安装 `~/.local/bin/gemini` 包装器并保存旧版默认 ID `gemini`。
包装器将 `--yolo` 转换为 `--dangerously-skip-permissions`，将交互提示和单次提示
分别转换为 `-i`、`-p`，其余参数按原顺序传递，`--` 后不再解析。

所有系统脚本只读，绝不修改 `/usr/share/omarchy/`。能力检测使用
`${OMARCHY_PATH:-/usr/share/omarchy}/bin/` 中的实际分支，不猜版本；不认识的实现直接停止。

## 先确认偏好

执行配置前，向用户确认是否设为默认 agent，以及是否启用可选后台服务。
Omarchy 的原生分发和旧版 shim 都会跳过 agent 的权限询问；不能把这一点隐瞒为普通启动。
保留现有快捷键、菜单和其他 provider，不默认覆盖用户习惯。

后台 stream-json 会话是**实验性可选项**，不添加权限绕过参数，不保证初始化用量接口，
也不保证常驻可用、零 CPU 或固定内存占用。先用已安装 `agy --help` 核对参数和登录状态，
再确认是否启用。它随用户会话启动，不自动启用 lingering。

## 快速开始

标准安装方式：

```bash
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
# 或安装整套技能：npx skills add interjc/omarchy-skills
```

先自行安装并认证 `agy`，检查 `agy --version`、`agy --help`。在仓库根目录运行：

```bash
# 终端中询问尚未指定的选项，回答完成前不写入任何文件。
bash skills/omarchy-agent-agy/scripts/setup.sh

# 非交互模式必须明确给出两项偏好。
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent agy --daemon keep

# 仅旧版需要，且此标志不会强制原生版本退回 shim。
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent agy --daemon keep --legacy-shim

# 单独授权实验性后台会话；使用实际可执行文件，不必位于 /usr/bin。
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent keep --daemon enable --agy-bin /absolute/path/to/agy
```

通过 skills CLI 安装后，从实际安装目录运行 `scripts/setup.sh`，而非假定上述仓库路径存在。

| 标志 | 行为 |
| --- | --- |
| `--default-agent agy\|keep` | 选择原生或经授权的旧版映射，或者保留现有默认项 |
| `--daemon enable\|keep` | 创建并启用后台服务，或者不更改现有服务；`keep` 不会停用它 |
| `--legacy-shim` | 仅允许已检测的旧版安装 Gemini shim；它会影响 PATH 中所有 `gemini` 调用 |
| `--replace-existing` | 明确允许替换冲突的 shim、服务或 runner；先备份，不自动合并自定义代码 |
| `--agy-bin /absolute/path` | 后台服务使用的可执行文件；默认解析 PATH 中的 `agy` 并取绝对真实路径 |
| `--help` / `-h` | 显示帮助，不更改配置 |

脚本只负责默认 agent 映射和获准的服务，不安装包或插件，不改菜单、快捷键、TOML 或
`shell.json`。原生 setter 自身可能通过 mise 安装工具并打开终端，脚本不会掩盖这一行为。
若 setter 返回时尚未保存 `agy`，脚本报错提示完成安装后重跑，不提前宣称设置成功。
已是目标默认项时不重复调用 setter；相同生成文件不重复写入。
发生替换时会输出 `<文件>.backup.XXXXXX/original` 的备份位置。默认项的符号链接拒绝自动修改。
缺失选项、未知能力或文件冲突会在写入前报错；外部 setter 或 systemd 运行失败则直接返回错误，
并非跨多个操作的事务回滚。`--replace-existing` 也不会覆盖菜单或布局。

## 手动配置与可选项

### 默认 Agent 与菜单

只读检查安装目录中的 `bin/omarchy-agent`、`bin/omarchy-default-agent`，对照上面的证据表。
原生版本使用 `omarchy-default-agent agy`，无需菜单 override。
旧版可使用经审阅的 `references/gemini-wrapper.sh` 作为 `~/.local/bin/gemini`，赋予可执行权限，
并仅在已确认的旧版中把默认文件 `~/.config/omarchy/defaults/agent` 设为 `gemini`。
任何替换前先备份；已有 shim 冲突时先审阅，不盲目复制。

旧版包装器依赖 `~/.local/bin` 在 PATH 中先于其他 `gemini` 可执行文件。
用 `type -a gemini` 和 `command -v agy` 检查，也检查桌面会话的 PATH；修改 shell RC
不一定影响已启动的桌面。不要为了强制优先级卸载真正的 Gemini CLI。

仅当用户要求旧版菜单显示新名称时，先备份并读取完整
`~/.config/omarchy/extensions/omarchy-menu.jsonc`，再把
[`references/omarchy-menu.jsonc`](references/omarchy-menu.jsonc) 的成员手工合入现有 JSONC
对象，保留注释和其他条目。不把示例覆盖到现有文件，不声称脚本已经完成合并。
菜单会热重载。升级为原生支持后重新检测、使用原生 setter，并审阅旧菜单 override 和
shim 是否还被其他用途依赖，再决定是否归档；不要自动删除用户文件。

### 快捷键

默认保留 `omarchy-agent --pick`。它在未选择默认项时打开选择菜单，否则走默认分发。
如用户明确要求更改组合键，先检查冲突、备份并编辑现有 `~/.config/hypr/bindings.lua`，
参考 [`references/hyprland-bindings.lua`](references/hyprland-bindings.lua)，仍调用分发器而不是直接 `agy`。
随后运行 `hyprctl reload` 和 `hyprctl configerrors`。

### 实验性后台服务

[`references/agy-daemon.service`](references/agy-daemon.service) 是模板，不是可原样安装的服务。
脚本将 `@AGY_BIN@` 替换为已解析并转义的绝对路径，同时安装
[`references/agy-daemon.sh`](references/agy-daemon.sh) 到 `~/.local/lib/omarchy-agent-agy/`。
runner 保持 stdin 打开，不发送请求；不要据此断言 Language Server RPC 已启动或配额可用。
如果 PATH 指向 mise 等启动 shim，可通过 `--agy-bin` 选择实际安装的二进制。
升级后若二进制路径变化，审阅备份并重新运行显式启用流程。

启用动作使用 `systemctl --user daemon-reload` 和 `enable --now`；文件变化时重启服务。
手动撤销启用使用 `systemctl --user disable --now agy-daemon.service`。

### 用量栏，需单独批准

第三方插件在 shell 中执行非沙箱代码。先审阅并获得安装和布局调整许可，再运行：

```bash
omarchy pkg aur add ai-usagebar-bin
omarchy plugin add https://github.com/akitaonrails/ai-usagebar.git --enable
```

备份并就地编辑 `~/.config/ai-usagebar/config.toml`，参考
[`references/ai-usagebar.toml`](references/ai-usagebar.toml)。若已有 `[antigravity]`，在其中调整
`enabled = true`，不要重复表头或覆盖其他 provider，也不要默认改变 primary/UI 偏好。
第三方版本的字段和命令以已安装版本的帮助及其文档为准。

先读取并备份**完整** `~/.config/omarchy/shell.json`。Omarchy 要求顶层 `"version": 1`，
用户文件是完整配置，不与系统默认值深合并。保留现有所有字段和布局，只在用户选定的区域
数组中加入 `{"id": "akitaonrails.ai-usagebar"}`，若已存在则不重复添加。
不要把局部示例当完整文件覆盖。若尚无用户文件，先复制安装目录的完整默认配置再编辑。
布局保存会热重载；必要时使用：

```bash
omarchy-shell shell reloadConfig
# 或完整重启：omarchy restart shell
```

## 验证与维护

```bash
omarchy-default-agent               # 原生为 agy，已授权旧版为 gemini
command -v agy
type -a gemini                     # 仅旧版需要检查 shim 优先级
# 以下会启动跳过权限询问的 agent，只在用户批准后运行：
omarchy agent --inline
omarchy agent prompt "Hello Antigravity"
# 仅选择后台服务后：
systemctl --user is-active agy-daemon.service
systemctl --user status agy-daemon.service
journalctl --user -u agy-daemon.service -n 50 --no-pager
ai-usagebar --help
ai-usagebar --vendor antigravity    # 先以当前帮助确认参数支持
```

通过快捷键和菜单分别确认默认项，查看实际用量或错误，不预设配额周期、输出数值或 RPC 方法。
若显示离线，先在可见终端运行已登录的 `agy` 对比，再检查服务日志及当前版本的参数支持。
不要把“服务 active”等同于配额查询成功。

包维护可用 `omarchy update`，或系统提供的 AUR helper；不存在 `omarchy pkg aur update`。
插件使用 `omarchy plugin update akitaonrails.ai-usagebar`，更新前保留本地改动；
必要时运行 `omarchy-shell shell rescanPlugins`。每次升级后重新检查能力、CLI 参数和用量查询。

仓库内离线检查（不会运行真实安装）：

```bash
bash -n skills/omarchy-agent-agy/scripts/setup.sh
bash -n skills/omarchy-agent-agy/references/gemini-wrapper.sh
bash -n skills/omarchy-agent-agy/references/agy-daemon.sh
bash skills/omarchy-agent-agy/scripts/test.sh
# 可选：对已有只读 checkout 的两个固定上游快照执行相同 mock 验证。
bash skills/omarchy-agent-agy/scripts/test.sh /tmp/opencode/omarchy-latest
```

测试使用临时 HOME、Omarchy 和 systemctl mock；不验证真实登录、桌面显示、后台资源占用或第三方配额接口。

## 上游引用

- [quattro agent 分发器（固定提交）](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-agent)
- [quattro 默认项 setter（固定提交）](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-default-agent)
- [v4.0.6 agent 分发器](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-agent)
- [v4.0.6 默认项 setter](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-default-agent)
- [原生菜单 ID](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/omarchy/omarchy-menu.jsonc)、[默认快捷键](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/utilities.lua)
- [完整 shell 配置](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/config/omarchy/shell.json)、[ai-usagebar 文档](https://github.com/akitaonrails/ai-usagebar)
