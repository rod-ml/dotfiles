-- LaTeX editing: vimtex + tectonic compiler + Skim viewer + texlab LSP.
-- Compile: <localleader>ll (write+compile), view: <localleader>lv, stop: <localleader>lk
-- Skim: forward search <localleader>lss? (from nvim to PDF); Cmd-click in Skim jumps back to nvim.

return {
  {
    "lervag/vimtex",
    lazy = false, -- vimtex recommends eager loading for inverse search
    keys = {
      -- Move vimtex group to <leader>l; Lazy moves to <leader>L below.
      { "<leader>l", group = "latex", mode = { "n", "v" } },
      { "<leader>ll", "<plug>(vimtex-compile)", desc = "Compile", mode = "n" },
      { "<leader>lv", "<plug>(vimtex-view)", desc = "View PDF", mode = "n" },
      { "<leader>lk", "<plug>(vimtex-compile-stop)", desc = "Stop compiler", mode = "n" },
      { "<leader>le", "<plug>(vimtex-errors)", desc = "Errors", mode = "n" },
      { "<leader>lq", "<plug>(vimtex-compile-clean)", desc = "Clean aux files", mode = "n" },
      { "<leader>ls", "<plug>(vimtex-toc-open)", desc = "Table of contents", mode = "n" },
    },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1 -- forward search on compile
      vim.g.vimtex_view_skim_activate = 1 -- bring Skim to front
      vim.g.vimtex_quickfix_mode = 0 -- don't auto-open quickfix on errors

      -- tectonic: self-contained compiler, auto-fetches packages.
      -- -X is the v1 CLI (same tectonic pi-study's TikZ path uses).
      vim.g.vimtex_compiler_method = "tectonic"
      vim.g.vimtex_compiler_tectonic = {
        build_dir = ".",
        options = {
          "-X",
          "compile",
          "--keep-logs",
          "--synctex",
        },
      }

      -- Conceal LaTeX syntax: renders \alpha as the glyph, etc. while editing.
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
      vim.g.vimtex_fold_enabled = 0
    end,
    config = function()
      -- New empty .tex files start from the template
      vim.api.nvim_create_autocmd({ "BufNewFile" }, {
        pattern = "*.tex",
        callback = function(args)
          local template = vim.fn.expand("~/.config/nvim/templates/tex.tex")
          if vim.fn.filereadable(template) == 1 then
            vim.cmd("0read " .. template)
          end
        end,
      })

      -- texlab LSP setup (LazyVim ships nvim-lspconfig)
      local ok, lspconfig = pcall(require, "lspconfig")
      if ok then
        lspconfig.texlab.setup({
          settings = {
            texlab = {
              build = {
                -- Let vimtex own compilation; texlab only for completion/hoover.
                executable = "tectonic",
                onSave = false,
              },
            },
          },
        })
      end
    end,
  },
}
