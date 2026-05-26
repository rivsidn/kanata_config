# AGENTS.md instructions for /home/yuchao/github/kanata_config

<INSTRUCTIONS>
## 仓库概览

这是一个 Kanata 键位映射配置仓库，主要维护键盘重映射配置、安装脚本和键位图。

- `kanata.kbd`：主键位配置文件，定义基础层、符号层、Shift/Caps 行为、Left Alt 快捷键和配置重载逻辑。
- `kanata.private.kbd`：本地私有宏配置文件，用于 `Left Alt+M` 后接数字或字母触发私有宏；不要在其中提交真实敏感内容。
- `install.sh`：安装脚本，将配置复制到 `~/.config/kanata`，生成并安装 systemd service，然后启用和重启服务。
- `kanata.service.temp`：systemd service 模板，由 `install.sh` 渲染后安装。
- `kanata-layout.svg`：键位映射图源文件。
- `kanata-layout.png`：由 SVG 对应生成的键位映射图片。

## 仓库约束

- 修改键位配置时，优先编辑 `kanata.kbd`；涉及本地私有宏时再编辑 `kanata.private.kbd`。
- 每次键位更新后，必须先运行配置校验，确认测试正常，例如：`kanata --cfg kanata.kbd --check`。
- 每次键位更新并测试正常后，必须同步更新键位图文件，确保图片与配置一致：
  - `kanata-layout.svg`
  - `kanata-layout.png`
- 不要只修改 `kanata.kbd` 而遗漏图片文件；如果因为工具或环境限制无法更新图片，必须在最终回复中明确说明。
</INSTRUCTIONS>
