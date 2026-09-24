# ============================================
# 全局环境变量（所有 fish 实例，包括非交互式）
# ============================================

# 编辑器
set -gx EDITOR hx
set -gx VISUAL hx

# Homebrew 镜像源
set -gx HOMEBREW_PIP_INDEX_URL "https://pypi.mirrors.ustc.edu.cn/simple"
set -gx HOMEBREW_API_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"

# Homebrew 设置
set -gx HOMEBREW_DOWNLOAD_CONCURRENCY 10
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ANALYTICS 1

# Homebrew shell 环境（实测开销约 0.01s，可接受，保持原样）
eval (/opt/homebrew/bin/brew shellenv)

# 用户本地 bin 目录
fish_add_path --prepend $HOME/.local/bin

# ============================================
# 交互式会话专用配置（仅当你手动打开终端时执行）
# ============================================

if status is-interactive
    # Starship 提示符（只在交互式终端需要）
    starship init fish | source

    # 别名（通常只在交互式中有用）
    alias python='python3'
end

# ============================================
# fzf / zoxide 集成（2026-09-19 新增）
# ============================================
# 全部用 `command -q` 守卫：工具没装时静默跳过，**绝不会因为"命令不存在"
# 让 shell 启动报错**。所以先写配置还是先装工具都不会出问题。
#
# 为什么放在 status is-interactive 里：这两个都是交互式专用的
# （fzf 的历史搜索要读交互式 history；zoxide 的目录数据库也只在交互时用），
# 放进守卫能让 `fish -c` 这类非交互调用完全跳过它们，零开销。
if status is-interactive
    # fzf：Ctrl+R 搜索历史、Ctrl+T 选文件、Alt+C 跳目录。
    # 注：fzf 0.48+ 用 `fzf --fish` 取代了旧的 source key-bindings.fish / completion.fish
    if command -q fzf
        fzf --fish | source
    end

    # zoxide：z <关键词> 跳到常去目录、zi 交互式选择
    if command -q zoxide
        zoxide init fish | source
    end
end

# 让 fzf 用 fd 来枚举文件，而不是默认的 `find`：
#   fd 尊重 .gitignore、跳过 node_modules/.git，快得多，而且不列出被忽略的文件
#   --hidden 让隐藏文件（.env 等）也能被搜到；--exclude .git 避免翻 .git 内部
# 想恢复 fzf 默认行为，删掉这三行即可。
if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
end
