[English](VALIDATION.md) | [简体中文](VALIDATION_ZH.md)

# 兼容性与实机验证

## 审计基线

验证日期：**2026-10-31**。分别比较 Omarchy 最新稳定标签
[`v4.0.6`](https://github.com/omacom/omarchy/releases/tag/v4.0.6) 和默认分支
`quattro` 的固定提交
[`bda3aaf6955404712dbd46541e6c8a75a2b16b7c`](https://github.com/omacom/omarchy/tree/bda3aaf6955404712dbd46541e6c8a75a2b16b7c)。
不能仅凭发行版版本号推断 Agent、截图或输入法能力；安装器读取实际实现并拒绝未知的 Agent 分发路径。

| 组件 | 本次实机环境 |
| --- | --- |
| Omarchy 包 | `4.0.6-1` |
| Hyprland | `0.56.2`，Lua 配置 |
| Antigravity CLI | `1.4.10` |
| ai-usagebar | `1.47.0` |
| Omasnap | `1.17.0`，用户安装 |
| Fcitx5 | `5.1.23`，由用户 systemd 服务管理 |

## 已确认差异

- 实机仍使用 `gemini` 分发，原生 `agy` 是所审计 `quattro` 快照的能力。因此实机保留经用户批准的 Gemini shim，不写入无法分发的 `agy` 默认值。
- 实机的官方截图包装器仍使用 grim/区域选择流程，并非 Omasnap。安装器检查 PATH 实际解析到的包装器，只有确认它调用 Omasnap 才选用，否则使用已安装的 `omasnap`，不擅自切换截图工具。
- 实机没有新版默认手势模块。现有三指拖拽、四指手势保持原样；新版默认手势冲突的处理通过固定上游源码和沙盒验证，不声称在这台机器上完成了新版手势实测。
- `no_screen_share` 的 Omasnap 图层规则会破坏新版滚动截图，应移除，而不是继续作为安全优化安装。
- `shell.json` 必须保留完整配置及顶层 `version: 1`。输入法、电源及硬件配置不再由“一键安装”无条件覆盖。

## 实机执行

用户明确选择“保留习惯并修复”。未升级系统、安装插件、改动系统目录或测试休眠。
保留传统滚动、三指拖拽、现有四指手势、Print/F12/Super+Ctrl+A 截图、
Super+Shift+Z 剪贴板、Super+Space 输入法及 Ctrl+Space 启动器。

执行了以下已批准的安装命令，并各重复运行以检查幂等性：

```bash
bash skills/omarchy-agent-agy/scripts/setup.sh \
  --default-agent agy --daemon enable --legacy-shim --replace-existing --agy-bin /usr/bin/agy
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z
```

另外手动移除旧截图规则中的 `no_screen_share`，清除 Fcitx 中与 Ctrl+Space
启动器冲突的无效向前组切换键，再通过 `fcitx5-remote -r` 重读配置，未启动第二个输入法进程。
本次手动迁移不属于安装器的自动清理行为。

| 检查 | 实际结果 |
| --- | --- |
| Hyprland 重载 | `hyprctl reload` 成功，`hyprctl configerrors` 为空 |
| 现有偏好 | 传统滚动 `false`、三指拖拽 `1`、打字禁用触摸板 `true`；原有 `input.lua` 及 Fcitx `profile` 与备份逐字节相同 |
| 绑定加载 | Super+Ctrl+A、Print、F12、Super+Shift+Z、Ctrl+Space 各一条目标绑定 |
| 包装器 | `gemini --version` 返回实际 `agy` 版本 `1.4.10`；默认 ID 仍为 `gemini` |
| 真实分发 | 临时目录中经 PTY 启动 `omarchy-agent --inline`，出现 Antigravity 启动信息，无不支持 Agent 或参数错误；8 秒后主动超时结束，未提交提示或执行编码任务 |
| 后台服务 | 新服务 `active/running`，日志包含新的 `event: init`，检查时重启计数为 `0`；unit 通过 `systemd-analyze --user verify` |
| 配额 | 使用独立缓存目录执行 `ai-usagebar --vendor antigravity`，返回额度和重置时间，无离线错误；不仅检查服务是否 active |
| 截图输出 | `omasnap --capture-fullscreen --save` 返回成功，生成有效的 `2560 x 1600` PNG；图像统计非全黑/常量图 |
| 输入法 | 重读配置后 Fcitx 正常响应，当前组 `Default`、引擎 `rime`；未改动个人引擎列表和词库 |
| 重复安装 | 相同参数再次执行，无配置重写和新增备份 |

截图只保存在本地 `/tmp/opencode/omarchy-live-validation/`，未上传或纳入仓库。
后台内存和 CPU 仅为某次运行观测，不据此作零占用或固定资源承诺。

## 自动验证

```bash
bash skills/omarchy-agent-agy/scripts/test.sh /tmp/opencode/omarchy-latest
bash skills/omarchy-macbook-behavior/scripts/test-setup.sh
git diff --check
```

全部通过。第一个命令的额外参数是本地只读上游 checkout，可省略；提供时会使用两个固定快照的真实
Agent 脚本配合模拟可执行文件测试，不触发真实安装。另通过所有 Shell 脚本的 `bash -n` 和 Lua 参考文件语法检查。

覆盖原生/旧版 Agent、参数校验、字面量提示、PATH 冲突、可执行权限修复、备份、个人文件保留、
48 种截图后端/偏好组合、PATH 与 `OMARCHY_PATH` 不一致、加载顺序、TTY 确认及重复运行。
独立审查发现的 PATH 检测不一致和相同内容 shim 缺少执行权限问题，均已修复并增加回归用例。

## 验证边界

以下尚未完成，不能视为通过：

- 手指实际操作的拖拽手感、四指手势、防误触和滚动方向体验。
- 截图快捷键的物理按键、标注、通知、滚动长截图和屏幕共享中的交互表现。
- 各输入法的完整中日英输入、窗口状态、快捷键切换与终端前缀组合测试。
- 合盖、外接屏、实际挂起/唤醒及锁屏安全；本次有意不触发这些操作。
- `quattro` 桌面会话的原生 `agy`、新版截图包装器和输入法完整实机测试。
- 后台服务长期稳定性、资源开销和第三方接口未来可用性。

## 备份与撤销

本次手动改动前的用户配置保存在 `~/.local/state/omarchy-skills-validation-20261031/`。
Agent 安装器另输出 `<文件>.backup.XXXXXX/original`，MacBook 安装器输出
`<文件>.macbook-backup.XXXXXX`。恢复前必须比较当前文件，保留验证后新增的个人修改，
不要盲目覆盖；恢复旧图层规则也会重新引入其已知问题。

后台服务可用 `systemctl --user disable --now agy-daemon.service` 停用；
若要恢复旧服务，先比较备份、恢复获准的内容，再 `daemon-reload` 和重启。
MacBook 托管块及模块的移除步骤见该技能的“验证与回滚”。
