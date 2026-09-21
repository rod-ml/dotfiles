#!/bin/bash
# symlinks dotfiles into $HOME. run from the repo root.
set -e
cd "$(dirname "$0")"

link() {  # link <repo-path> <target>
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "backing up $2 -> $2.bak"
    mv "$2" "$2.bak"
  fi
  mkdir -p "$(dirname "$2")"
  ln -sfn "$1" "$2"
}

link "$PWD/zsh/zshrc"     "$HOME/.zshrc"
link "$PWD/zsh/zprofile"  "$HOME/.zprofile"
link "$PWD/zsh/zshenv"    "$HOME/.zshenv"
link "$PWD/git/gitconfig" "$HOME/.gitconfig"
link "$PWD/git/ignore"    "$HOME/.config/git/ignore"

# whole-dir configs
for d in gh kitty moshi nvim sketchybar vicinae fish; do
  link "$PWD/config/$d" "$HOME/.config/$d"
done

# single-file configs (dirs hold untracked local state too)
mkdir -p "$HOME/.config/spotify-player" "$HOME/.config/herdr" "$HOME/.claude"
link "$PWD/config/spotify-player/theme.toml" "$HOME/.config/spotify-player/theme.toml"
[ -f "$HOME/.config/spotify-player/app.toml" ] || cp config/spotify-player/app.toml.example "$HOME/.config/spotify-player/app.toml"
link "$PWD/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

link "$PWD/claude/settings.json" "$HOME/.claude/settings.json"

# local secret files (never in the repo)
[ -f "$HOME/.secrets" ] || printf '# API keys - never commit this file\n' > "$HOME/.secrets"
chmod 600 "$HOME/.secrets"

echo "done. run 'brew bundle install' to restore packages."
