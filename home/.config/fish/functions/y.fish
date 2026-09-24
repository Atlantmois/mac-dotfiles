# yazi 包装函数：退出 yazi 时把 shell 的当前目录切到你最后浏览的位置。
#
# 原理：把临时文件路径通过 --cwd-file 传给 yazi，yazi 退出时把最终 cwd 写进去，
# 我们再读出来 cd 过去。相关细节：
#   * keymap 里的 `Q` = `quit --no-cwd-file` 就是「退出但不写 cwd」，
#     所以如果某次你不想改变 shell 目录，在 yazi 里用 Q 退出即可。
#   * 三处守卫都不能省：
#       read -z 读不完整（文件为空）时不 cd
#       [ "$cwd" != "$PWD" ] 目录没变就不做无意义的 cd
#       test -d "$cwd" 目录可能已被删除
#   * 用 `command yazi` 而不是 `yazi`，避免万一出现同名函数导致递归调用。
#   * `builtin cd` 同理，绕过任何 cd 的别名/函数包装。
#
# 源码取自 yazi 官方 Quick Start 的 Shell wrapper 一节（未改动逻辑，
# 只补了上面这些注释、--wraps 和 --description）。
#
# 用法：
#   y            # 在当前目录打开 yazi，退出后 shell 停在最后浏览的目录
#   y ~/projects # 带参数（参数会原样透传给 yazi）
#
# 典型链路：y  →  浏览到项目  →  退出（shell 已在项目里）  →  hx .
function y --wraps yazi --description 'yazi 包装：退出时 cd 到最后浏览的目录'
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
