-- gh.nvim renders issues, PRs, commits and review threads into scratch buffers
-- with `filetype=pr` (see litee/gh/issues/issue_buffer.lua). The *content* is
-- markdown, but the filetype isn't, so nothing markdown-aware touches it.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- lazy.nvim treats `ft` as a list and extends it across specs, so this adds
    -- to LazyVim's list instead of replacing it. render-markdown also falls back
    -- to the lazy `ft` spec when `file_types` is unset, so this one line covers
    -- both *loading* the plugin and telling it which buffers to render.
    ft = { "pr" },
    init = function()
      -- Treesitter resolves a parser by language name, not by filetype, and
      -- there is no `pr` language. Without this alias there's no parse tree for
      -- the buffer, so render-markdown has nothing to attach highlights to.
      vim.treesitter.language.register("markdown", "pr")
    end,
  },
}
