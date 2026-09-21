-- lazygit: make `o` open the file in this Neovim rather than the macOS default app.
--
-- `o` and `e` are separate lazygit bindings that hit separate config keys:
--   edit: e       -> the os.edit* commands, governed by os.editPreset
--   openFile: o   -> os.open, which editPreset does NOT cover
--
-- snacks.nvim already sets `editPreset = "nvim-remote"`, which is why `e` lands in
-- the parent Neovim. os.open was left at the platform default (`open {{filename}}`
-- on macOS), so the file goes to whichever app owns that extension in LaunchServices
-- -- Sublime here. Pointing os.open at the same remote invocation makes `o` behave
-- like `e`.
--
-- Neovim sets $NVIM in every :terminal buffer to v:servername, so the float lazygit
-- runs in can address the parent instance over its RPC socket. That also keeps this
-- scoped correctly: it only applies to lazygit launched from Neovim, because snacks
-- is what chains this generated file into $LG_CONFIG_FILE. A lazygit started from a
-- plain shell still uses ~/Library/Application Support/lazygit/config.yml untouched.
return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        config = {
          os = {
            editPreset = "nvim-remote",
            open = 'nvim --server "$NVIM" --remote-tab-silent {{filename}}',
          },
        },
      },
    },
  },
}
