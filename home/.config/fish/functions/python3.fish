# python3 包装：当以 `python3 ok ...` 运行 CS61A ok 自动评分器时，
# 自动在 ok 后插入 --local（本地运行、不上传服务器）；其余调用原样透传。
# 若命令已含 --local，则不重复添加。
function python3 --wraps python3
    if test (count $argv) -ge 1
        and string match -q -- 'ok' $argv[1]
        if contains -- --local $argv
            command python3 $argv
        else
            command python3 ok --local $argv[2..-1]
        end
    else
        command python3 $argv
    end
end
