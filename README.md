# Dotfiles

我的 macOS 开发环境配置快照。`home/` 下的路径对应用户主目录中的路径，包含 Fish、Git、GitHub CLI、Helix、Yazi、Starship、uv、Herdr、Karabiner、Paneru、Ghostty、VS Code 和 OMP 的配置。

## 配置文件在哪

所有 26 个配置文件都在 [home/](home/) 目录中。以 `.` 开头的目录和文件（例如 `.config`、`.gitconfig`）是隐藏文件；在 macOS 访达中可按 `⌘⇧.` 显示。

| 工具 | 文件入口 |
| --- | --- |
| Fish | [config.fish](home/.config/fish/config.fish)、[函数](home/.config/fish/functions/) |
| Git、GitHub CLI | [.gitconfig](home/.gitconfig)、[gh/config.yml](home/.config/gh/config.yml) |
| Helix | [配置与主题](home/.config/helix/) |
| Yazi | [配置与主题](home/.config/yazi/) |
| Starship、uv、Herdr | [Starship](home/.config/starship.toml)、[uv](home/.config/uv/uv.toml)、[Herdr](home/.config/herdr/config.toml) |
| Karabiner、Paneru | [按键配置](home/.config/karabiner/karabiner.json)、[窗口管理配置](home/.paneru.toml)、[辅助脚本](home/.local/bin/focus-app.sh) |
| Ghostty | [终端配置与着色器](home/Library/Application%20Support/com.mitchellh.ghostty/) |
| VS Code | [用户配置与代码片段](home/Library/Application%20Support/Code/User/) |
| OMP | [代理配置](home/.omp/agent/)、[最小模式配置](home/.omp/ompmin/)、[启动脚本](home/.local/bin/ompmin) |

Conda 和 Codex 配置没有收录。Fish 配置中的 Conda 初始化段也已移除。Git 邮箱没有收录，可在安装后写入不受版本控制的 `~/.gitconfig.local`：

```sh
git config --file "$HOME/.gitconfig.local" user.email "你的邮箱"
```

## 安装

先克隆仓库，再预览将要建立的链接：

```sh
git clone https://github.com/Atlantmois/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./install.sh
```

确认预览后运行：

```sh
./install.sh --apply
```

脚本只为 `home/` 内的文件建立符号链接。已有文件会先移到 `~/.local/state/dotfiles-backups/` 下的时间戳目录；若目标已链接到当前仓库，则跳过。它不会自动安装软件。Ghostty、Karabiner 和 VS Code 的配置使用 macOS 路径；Fish、Helix 等工具需要另行安装。

安装后修改对应配置文件就是修改仓库中的文件，可用常规 `git status`、`git add`、`git commit` 和 `git push` 更新。首次安装前可先按需调整各工具的路径、字体和快捷键。

## 安全

仓库只收录经过筛选的配置文件。GitHub 凭据、SSH 密钥、令牌、会话、日志、历史记录、缓存和数据库均不收录。添加新文件前请检查内容；`.gitignore` 仅提供额外防护，不能替代人工检查。
