# mac-dotfiles

我的 macOS 开发环境配置快照，用于展示当前的工具选择与个人设置。`home/` 下的路径对应用户主目录中的路径，包含 Fish、Git、GitHub CLI、Helix、Yazi、Starship、uv、Herdr、Karabiner、AeroSpace、Ghostty、VS Code 和 OMP 的配置。

## 配置文件在哪

所有 20 个配置文件都在 [home/](home/) 目录中。以 `.` 开头的目录和文件（例如 `.config`、`.gitconfig`）是隐藏文件；在 macOS 访达中可按 `⌘⇧.` 显示。

| 工具 | 文件入口 |
| --- | --- |
| Fish | [config.fish](home/.config/fish/config.fish)、[缩写](home/.config/fish/conf.d/abbr.fish)、[函数](home/.config/fish/functions/) |
| Git、GitHub CLI | [.gitconfig](home/.gitconfig)、[gh/config.yml](home/.config/gh/config.yml) |
| Helix | [编辑器配置](home/.config/helix/) |
| Yazi | [文件管理器配置](home/.config/yazi/) |
| Starship、uv、Herdr | [Starship](home/.config/starship.toml)、[uv](home/.config/uv/uv.toml)、[Herdr](home/.config/herdr/config.toml) |
| Karabiner、AeroSpace | [按键配置](home/.config/karabiner/karabiner.json)、[AeroSpace](home/.aerospace.toml) |
| Ghostty | [终端配置与着色器](home/Library/Application%20Support/com.mitchellh.ghostty/) |
| VS Code | [用户配置与代码片段](home/Library/Application%20Support/Code/User/) |
| OMP | [代理配置](home/.omp/agent/) |

Conda 和 Codex 配置没有收录。Fish 配置中的 Conda 初始化段及 Git 邮箱也已移除。

## 阅读说明

这些文件是个人配置展示，不是安装模板。路径、字体、应用版本和快捷键都与我的环境有关；如果要借鉴其中的设置，请先确认它在自己的设备上适用。

## 安全

仓库只收录经过筛选的配置文件。GitHub 凭据、SSH 密钥、令牌、会话、日志、历史记录、缓存和数据库均不收录。添加新文件前请检查内容；`.gitignore` 仅提供额外防护，不能替代人工检查。
