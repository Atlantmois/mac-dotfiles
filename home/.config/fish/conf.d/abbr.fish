# Interactive fish abbreviations.
if status is-interactive
    # ── General ────────────────────────────────────────────────────────
    abbr -a e exit
    abbr -a c clear
    abbr -a s 'exec fish'
    abbr -a copy pbcopy
    abbr -a ports 'lsof -nP -iTCP -sTCP:LISTEN'
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'

    # ── Git ────────────────────────────────────────────────────────────
    abbr -a gs 'git status --short --branch'
    abbr -a ga 'git add'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a gsw 'git switch'
    abbr -a gswc 'git switch -c'
    abbr -a gl 'git log --oneline --decorate -10'
    abbr -a gcm --set-cursor 'git commit -m "%"'

    # ── Homebrew ───────────────────────────────────────────────────────
    abbr -a bu 'brew update'
    abbr -a bg 'brew upgrade'
    abbr -a bi 'brew install'
    abbr -a bs 'brew search'
    abbr -a bif 'brew info'
    abbr -a bl 'brew leaves; and brew list --cask'
end
