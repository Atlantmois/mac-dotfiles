#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 || ( $# -eq 1 && $1 != --apply ) ]]; then
  echo "Usage: $0 [--apply]" >&2
  exit 2
fi

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
home_dir=${HOME:?HOME must be set}
apply=false
[[ $# -eq 1 ]] && apply=true

timestamp=$(date '+%Y%m%d-%H%M%S')
backup_root="$home_dir/.local/state/dotfiles-backups/$timestamp"
count=0

while IFS= read -r -d '' src; do
  rel=${src#"$repo_dir/home/"}
  dest="$home_dir/$rel"

  if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
    echo "Already linked: $rel"
    continue
  fi
  if [[ -d "$dest" && ! -L "$dest" ]]; then
    echo "Refusing to replace directory: $dest" >&2
    exit 1
  fi

  if [[ $apply == false ]]; then
    if [[ -e "$dest" || -L "$dest" ]]; then
      echo "Would back up and link: $rel"
    else
      echo "Would link: $rel"
    fi
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    backup="$backup_root/$rel"
    mkdir -p "$(dirname "$backup")"
    if [[ -e "$backup" || -L "$backup" ]]; then
      echo "Backup collision: $backup" >&2
      exit 1
    fi
    mv "$dest" "$backup"
    echo "Backed up: $rel"
  fi
  ln -s "$src" "$dest"
  echo "Linked: $rel"
  count=$((count + 1))
done < <(find "$repo_dir/home" -type f -print0 | sort -z)

if [[ $apply == true ]]; then
  echo "Linked $count files. Backups, if any: $backup_root"
else
  echo "Preview only. Run ./install.sh --apply to make changes."
fi
