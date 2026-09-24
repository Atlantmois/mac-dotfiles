# Dotfiles

我的 macOS 开发环境配置快照。`home/` 下的路径对应用户主目录中的路径，包含 Fish、Git、GitHub CLI、Helix、Yazi、Starship、uv、Herdr、Karabiner、Paneru、Ghostty、VS Code 和 OMP 的配置。

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
