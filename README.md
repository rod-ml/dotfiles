# dotfiles

macOS setup for rody. managed with plain symlinks, no framework.

## what's here

- `zsh/` - zshrc, zprofile, zshenv (zshenv sources `~/.secrets` for API keys)
- `git/` - gitconfig and global gitignore
- `config/` - kitty, nvim, sketchybar, gh, fish, moshi, vicinae, spotify-player, herdr
- `claude/` - claude code settings
- `Brewfile` - all brew formulae and casks
- `install.sh` - symlinks everything into $HOME, backs up existing files

## secrets (not in this repo)

- `~/.secrets` - API keys (BRAVE_API_KEY, GROQ_API_KEY, ZAI_API_KEY), sourced by zshenv
- `~/.config/spotify-player/app.toml` - spotify client id/secret (see app.toml.example)
- `~/.ssh/` - keys, managed separately
- gh login token lives in the system keyring

## restore on a new mac

1. `git clone` this repo to `~/dotfiles`
2. `brew bundle install` (from the repo root)
3. `./install.sh`
4. recreate `~/.secrets` and spotify `app.toml` with real values
