---
name: omarchy-macbook-behavior
description: 在 Omarchy 的 Lua Hyprland 配置中设置经用户确认的 MacBook 风格触控板和快捷键偏好，包括三指拖拽和四指手势。审查当前生效的快捷键，并指导可选的多语言输入、合盖/电源配置和硬件诊断，不替换个人配置。
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy MacBook 操作习惯

## 适用范围与兼容性

已对照上游 `quattro` 提交 `bda3aaf6955404712dbd46541e6c8a75a2b16b7c` 审查，提交日期为 **2026-10-31**。另行检查的最新稳定版本标签为 **v4.0.6**。这只是一个版本快照，并不保证稳定版或更早的安装具有相同的 API、快捷键或 systemd 单元。自动化流程要求使用包含 `require("default.hypr.omarchy")` 的当前 Lua 配置；较早的 `.conf` 配置需要单独进行针对具体版本的审查。

实机 **4.0.6-1** 的 `omarchy-capture-screenshot` 仍使用 grim、`omarchy-capture-region` 和 tensaku，并不调用 `omasnap`；已安装的独立 `omasnap` 支持 `--save` / `--capture-fullscreen`，但没有 `--notify`。该机器完全没有 `default/hypr/gestures.lua`，因此本版本没有该默认模块引起的手势冲突；不能把较新 `quattro` 的行为直接套用到它上面。仅添加快捷键时使用 `--keep-trackpad`，保留现有 `input.lua`，不添加手势或禁用标志。较新构建如加载默认手势，启用替代触控板方案时仍须在导入默认配置前设置 `omarchy_default_gestures = false`。

Omarchy 已提供剪贴板历史、截图、多语言输入切换、合盖/合盖外接显示处理，以及 Apple SMC 合盖绑定。本技能仅添加少量可选的触控板/快捷键覆盖配置，不替换桌面软件栈，也不保证实现与 macOS 完全相同的行为。它绝不修改 `/usr/share/omarchy/`。

使用标准 skills CLI 安装/发现本技能：

```bash
npx skills add interjc/omarchy-skills --skill omarchy-macbook-behavior
```

## 先确认再修改

应用任何更改前，先检查实际配置并询问用户的选择。不要擅自决定滚动方向、快捷键、语言、轻触行为、空闲超时或合盖策略。

1. 运行只读审查脚本：`bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh`。它先输出当前生效的 `hyprctl binds -j`，再输出标注明确的快照表。同时检查自定义绑定和手势定义；仅查看源码片段并不能审查实际生效的绑定。
2. 选择**自然滚动**、**传统滚动**或**保留触控板设置**。自然滚动让内容随手指移动；传统滚动的方向相反。选择任一滚动方向，也就表示启用三指拖拽、打字时禁用触控板，以及下文所述的替代手势方案。现有加速度、轻触/点击选项和终端滚动系数保持不变。
3. 为截图选择**保留**、**Super+Ctrl+A**、**Alt+Shift+4** 或**两者都用**。Super+Ctrl+A 默认会替换音频功能绑定；任何选中的组合键都可能替换个人绑定。Alt+Shift+4 只是一个替代组合键，并不对应 macOS Cmd+Shift+4 的相同物理键位。
4. 为剪贴板选择**保留**或添加 **Super+Shift+Z**。这只是可选的快捷键别名，不是 Alfred 通用的默认快捷键；请检查个人配置中的冲突。原生 Super+Ctrl+V 绑定不会被移除。
5. 如用户有需要，另行讨论语言和电源更改。安装脚本不会安装软件包，也不会修改 Fcitx、Rime、系统服务、udev、logind 或 shell 定时器。

## 快速开始

从仓库根目录运行；如果安装在其他位置，请相应调整路径：

```bash
# Read-only, even on a TTY:
bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh

# Interactive: every missing preference requires a choice, then confirmation.
bash skills/omarchy-macbook-behavior/scripts/setup.sh

# Explicit automation: ALL three preference categories are mandatory.
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --natural-scroll --screenshot-hotkey alt-shift-4 --clipboard-hotkey super-shift-z

# Keep trackpad and screenshot behavior; add only a clipboard alias:
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey keep --clipboard-hotkey super-shift-z

# Shortcut-only on the legacy release; preserve personal input.lua:
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z
```

触控板参数：`--natural-scroll`、`--traditional-scroll`、`--keep-trackpad`。截图选项值：`keep`、`super-ctrl-a`、`alt-shift-4`、`both`。剪贴板选项值：`keep`、`super-shift-z`。未知参数、缺失值、无效选项以及不完整的非交互调用都会在写入前失败。明确且完整的参数表示同意执行；代理仍须先取得用户的偏好选择。

### 截图命令检测

请求截图快捷键时，脚本通过 `type -P omarchy-capture-screenshot` 解析 `PATH` 上实际可执行的封装命令，并只读检查该文件，不会运行截图命令来探测能力。`${OMARCHY_PATH:-/usr/share/omarchy}` 仅提供安装位置背景；其中的同名源码可能与 `PATH` 上的命令不同，不能作为检测依据：

- 如果在实际解析出的可执行文件中发现行首的 `omasnap ...` 或 `exec omasnap ...` 命令调用，选择 `omarchy-capture-screenshot`。注释、参数中的名称和 `omasnap_args` 变量不算命令调用。
- 如果实际封装是旧版 grim/tensaku、无法识别或无法读取，或者 `PATH` 上没有可执行封装，则选择 `PATH` 上已安装的裸命令 `omasnap`，不附加 `--notify`、`--save` 或其他参数，不退回到旧截图工作流。
- 两条路径都要求 `omasnap` 在 `PATH` 上可执行。缺少所需命令时，在任何写入前报错，不会静默省略截图绑定。截图选项为 `keep` 时不需要这些工具。

脚本输出精确的 `Screenshot command: omarchy-capture-screenshot` 或 `Screenshot command: omasnap`。新版封装提供通知和截图目录兼容行为；直接调用路径采用已安装 omasnap 自身的预览、保存和目录行为，不保证与新版封装相同。

### 受管理的集成

安装脚本保留 `input.lua`、`bindings.lua` 和其他个人模块。它使用唯一的 `.macbook-backup.*` 文件名备份发生更改的文件，随后仅管理 `macbook_behavior.lua` 以及 `~/.config/hypr/hyprland.lua` 中的两个标记块：

```lua
-- BEGIN omarchy-macbook-behavior gestures
omarchy_default_gestures = false
-- END omarchy-macbook-behavior gestures
require("default.hypr.omarchy")
-- ... existing personal modules and other configuration remain unchanged ...
-- BEGIN omarchy-macbook-behavior overrides
require("hypr.macbook_behavior")
-- END omarchy-macbook-behavior overrides
```

仅在选择更改触控板设置时，才会安装前面的标记块。覆盖模块在个人配置之后最后加载。使用相同选项重复运行不会再编辑文件或创建备份；偏好发生变化时，会替换本技能先前生成的选项。**`keep` 表示移除该类别之前由本技能管理的覆盖配置，让个人/上游行为保持原样**，而不是锁定先前生成的选项。所有类别均选择 keep 时，生成的覆盖配置不改变行为。安装脚本会拒绝作为符号链接的目标文件，以及缺少本技能所有权标头的已有覆盖文件。请保留该标头，并通过重新运行脚本调整偏好；手动自定义应放在独立的个人文件中。

脚本不会主动重新加载 Hyprland，但 Hyprland 可能在文件写入时自动重新加载。请立即在当前会话中检查并测试：

```bash
hyprctl reload
hyprctl configerrors
hyprctl binds -j
```

### 已有安装

本技能的早期版本会覆盖 `input.lua`、追加直接调用 `omasnap` 的绑定/F12 绑定、写入 Fcitx/Rime 文件，并可能安装系统覆盖配置。**新版安装脚本不会自动撤销这些更改。** 请先备份并检查；适当时恢复自己在使用本技能之前的备份，而不是使用他人的默认配置。

- 启用新手势方案前，先移除个人文件中的旧手势注册。安装脚本会拒绝 `input.lua` 中明显的 `hl.gesture` 定义，但无法发现所有间接模块、别名或动态创建的手势；请检查完整的加载依赖关系。
- 移除匹配 `omasnap` 的旧 `no_screen_share` 规则，包括其他模块中的规则。它们会破坏滚动截图。安装脚本会提示 `bindings.lua` 中常见的旧规则，但无法识别所有可能的规则。
- 检查旧的截图绑定，按上述能力检测选择命令：新版封装使用 `omarchy-capture-screenshot`，旧版封装配合已安装的独立工具时使用 `omasnap`。不要在旧机器上强制切换到 grim/tensaku 工作流。只有用户希望移除时才删除旧 F12 映射；F12 不是当前上游的默认截图快捷键。
- 保留/恢复 Fcitx 配置档案、语言引擎、Rime 自定义配置和个人词典。在只有一个分组的配置档案中，切换分组的绑定从来无法正确轮换组内引擎。请对照下文的原生行为，检查旧的 Super+Space/Control+Space 输入法覆盖配置。
- 手动检查旧的 `/etc` drop-in 配置片段或 udev 规则；本安装脚本既不会安装，也不会删除它们。

## 手动配置触控板与快捷键

备份 `hyprland.lua` 和所有将要编辑的文件。选择替代触控板方案时，在导入默认配置**之前**设置 `omarchy_default_gestures = false`，然后在 `hyprland.lua` 末尾加载独立的覆盖模块。仅从 [hyprland-input.lua](references/hyprland-input.lua) 复制所需设置，并明确选择 `natural_scroll` 的值。不要整体替换 `input.lua`。仅修改快捷键时，不添加触控板设置、手势或前置禁用标志。

已审查的较新 `quattro` 默认使用三指手势操作工作区/菜单/控制台，使用四指手势移动窗口/切换全屏。这些手势与三指拖拽以及本技能的四指手势注册冲突；上述实机 4.0.6-1 没有该默认手势模块，不存在这一上游冲突。前置标志会禁用较新构建的所有上游默认手势，但不会禁用个人手势。如果只想手动修改部分手势，已验证的 API 为 `hl.gesture({ fingers = 3, direction = "up", action = "unset" })`；请在重新定义前取消注册每个有冲突的方向。不要假定添加重复手势就会覆盖先前的注册。

提供的替代方案如下：

| 手势 | 操作 |
| --- | --- |
| 三指移动 | 通过 `drag_3fg = 1` 实现鼠标左键拖拽 |
| 四指水平滑动 | 切换工作区 |
| 四指上/下滑动 | 切换 `scratchpad` 特殊工作区的显示状态 |
| 四指向内捏合 | 打开 Omarchy 菜单 |

Scratchpad 是特殊工作区，不是 macOS 的 Mission Control。硬件支持情况和拖拽手感需要在真实设备上测试。`disable_while_typing = true` 请求启用 libinput 对应行为；它无法保证在所有设备上都能防止手掌误触。除非用户另行要求调节，否则保留上游加速度和滚动系数；经确认后，可在个人输入配置中自定义可选的轻触/点击、速度和唤醒设置。

如果只手动更改快捷键，请从 [hyprland-bindings.lua](references/hyprland-bindings.lua) 选择示例，先解除所选组合键的绑定，再通过 `o.bind` 绑定。按上述检测选择 **`omarchy-capture-screenshot` 或裸命令 `omasnap`**，不要假定同名封装在所有版本都调用相同工具。除非明确要求，否则不要更改原生 Print/Super+Ctrl+Alt+C。不需要额外的覆盖层规则；绝不要为 `omasnap` 添加 `no_screen_share`。

## 可选输入法

当前 Omarchy 通过**会话用户单元** `omarchy-fcitx5.service` 运行 Fcitx。更改任何内容前先检查：

```bash
omarchy-input-method status
systemctl --user status omarchy-fcitx5.service
```

原生 **Super+I / Super+Shift+I** 通过 Omarchy 的 shell 轮换输入语言。**Super+Space** 打开菜单。**Ctrl+Space** 是不吞键的终端前缀辅助绑定，用于在终端中请求直接输入；不要默认将其替换为会吞键的启动器/输入法绑定。macOS 上的 Cmd+Space 通常用于 Spotlight，并不是通用的输入源切换键。升级后的安装中可能仍有 Fcitx 自定义快捷键；应先检查，而不是强行设置新的快捷键。

使用 `omarchy setup input`（或 `omarchy-setup-input`）启动当前原生交互式配置工具。确认语言，并检查拟议的软件包/配置更改。优先使用其支持的预设，包括可用时的日语 Mozc，而不是替换配置档案。不要仅为添加一种语言就使用重置/恢复默认值选项。

对于原生预设选择器可能未提供的 **Rime**：

1. 确认用户需要中文输入，仅安装所需的软件包，例如 `sudo pacman -S --needed fcitx5-rime`。仅在需要且经确认后，另行安装可用的配置编辑器。
2. 备份现有 Fcitx 配置档案/配置。使用可用的 Fcitx 输入法编辑器，将 **Rime 添加到现有分组**，保留当前键盘、其他引擎、顺序和自定义快捷键。不要用 [fcitx5-profile](references/fcitx5-profile) 或 [fcitx5-config](references/fcitx5-config) 覆盖正在使用的文件；它们仅供指导/示例参考。
3. 如选择安装 Rime-Ice，请查看其上游当前的安装说明，备份 Rime 数据目录（`${XDG_DATA_HOME:-~/.local/share}/fcitx5/rime`），并有选择地合并方案/补丁。不要将仓库克隆到正在使用的词典目录树上，也不要替换现有的 `default.custom.yaml`。[rime-default.custom.yaml](references/rime-default.custom.yaml) 仅是在安装对应方案后可选择合并的示例。
4. 通过编辑器应用更改/重新部署 Rime。如需重启，请使用 `systemctl --user restart omarchy-fcitx5.service`，而不是再启动一个 `fcitx5 -r -d` 守护进程。随后测试原生轮换切换和终端 Ctrl+Space。在已安装版本上完成测试前，不要承诺手动添加的引擎具备原生集成支持。

按窗口记忆输入状态、候选翻页和单独按 Shift 切换都是独立的用户偏好，不是前置条件。绝不要为设置这些选项而覆盖整个 Fcitx 配置。只有一个分组时，轮换 Fcitx **分组**并不会轮换其中的 US/Rime/Mozc **引擎**。

## 可选电源检查

不会自动修改任何电源设置。当前上游已提供 `InhibitDelayMaxSec=15`；[logind-inhibit-delay.conf](references/logind-inhibit-delay.conf) 是快照参考，**不是应当安装的 drop-in 配置片段**。该值表示 inhibitor 的最大延迟，并不保证挂起前锁屏界面已完成渲染。

原生合盖绑定同时处理 `Lid Switch` 和 `Apple SMC power/lid events`，调用 `omarchy-system-lid-close` 和 `omarchy-hyprland-monitor-clamshell`。不要重复添加这些绑定或 Apple 钩子。电池/交流供电、外接显示器、扩展坞状态、inhibitor、固件和唤醒设备都可能影响实际行为。请检查已安装的命令和日志，不要声称已优化睡眠/合盖外接显示行为。

设置空闲定时器时，请保留**完整且符合标准格式**的 `~/.config/omarchy/shell.json`。当前格式要求包含 **`"version": 1`**，且它不是深度合并式的覆盖配置；仅包含 `{"idle": ...}` 的小文件可能丢弃/重置无关的状态栏、程序坞和插件设置。上游默认值已是**屏幕保护 150 秒 / 锁屏 300 秒**。确认时长后，仅编辑现有完整文件中用户要求的字段。如果文件不存在，请先检查 `/usr/share/omarchy/config/omarchy/shell.json` 中已安装的完整模板。不要用模板替换自定义文件。

实用的只读检查命令：

```bash
systemd-analyze cat-config systemd/logind.conf
systemd-inhibit --list
hyprctl binds -j
journalctl -b -u systemd-logind --no-pager
```

测试实际挂起、合盖或扩展坞变化之前，先保存工作并取得明确许可。在电池供电以及预期的外接显示器配置下，检查唤醒后的锁屏行为；不要仅凭超时值推断安全性。

## 硬件诊断

绝不要仅因加载了 `bcm5974`/`applespi` 就安装 udev 覆盖规则。先使用 `libinput list-devices` 确定触控板实际的事件节点，再检查 `udevadm info --query=property --name=/dev/input/eventN` 及其硬件标识。这些只读诊断在当前系统上可能需要提升权限。确定设备是否确实为内置设备、是否被错误归类为外接设备，以及是否缺少预期的打字时禁用行为。

只有在完成上述诊断并获得明确同意后，才考虑使用 [udev 示例](references/71-apple-trackpad-internal.rules)。通过已验证、针对具体设备的父设备匹配条件缩小范围；仅按驱动进行宽泛匹配并不适用于所有机器，也不是 Apple Silicon 的配置方案。备份任何现有规则，将审查后限定范围的规则安装到 `/etc/udev/rules.d/`，并在约定的维护/重启时间窗口内应用。再次验证设备属性和打字时的行为。硬件分类调整并不保证能解决手掌误触问题。

## 验证与回滚

- 运行 `hyprctl reload` 和 `hyprctl configerrors`；检查错误内容，不要只看重新加载命令的退出状态。
- 在实际硬件上测试三指文本选择和窗口拖拽、所有选中的四指手势、滚动方向，以及打字时禁用触控板的行为。
- 核对输出的截图命令，测试所选快捷键、标注、所选路径支持的通知/预览，以及**滚动截图**。直接调用路径不保证新版封装的通知行为。确保没有遗留的针对 `omasnap` 的 `no_screen_share` 规则。
- 测试剪贴板快捷键别名和现有原生快捷键；检查 `hyprctl binds -j` 是否有冲突。
- 如有可选输入法更改，测试每个引擎、原生正向/反向轮换切换、GUI/终端中的组字输入，以及终端前缀按键透传。检查用户服务，而不是再启动一个守护进程。
- 仓库检查：对每个脚本运行 `bash -n`，然后运行 `bash skills/omarchy-macbook-behavior/scripts/test-setup.sh`。沙箱测试使用临时 HOME、隔离的 `OMARCHY_PATH` 和白名单工具/模拟命令，覆盖新版封装、旧版直接调用、`OMARCHY_PATH` 与 `PATH` 的两种反向版本不匹配、缺少工具时无写入失败，以及保留触控板的快捷键安装；它们不能证明实际 Hyprland/硬件行为正常。

要禁用本安装脚本所设置的选项，请使用 `--keep-trackpad --screenshot-hotkey keep --clipboard-hotkey keep` 重新运行。要彻底移除集成，请备份当前文件，仅移除 `hyprland.lua` 中的两个标记块，然后删除受管理的 `macbook_behavior.lua`。恢复 `.macbook-backup.*` 文件前，务必先与当前内容比较，以免丢失后续的个人修改。之后重新加载并检查配置错误。受管理块之外的旧版更改需要另行手动回滚。
