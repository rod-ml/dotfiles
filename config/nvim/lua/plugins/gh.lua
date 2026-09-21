-- Two fixes for gh.nvim (upstream's last commit is 2024-09-02, so neither is coming
-- from the plugin). Both are applied from config rather than by editing plugin files,
-- which `:Lazy update` would revert.

local unpack = table.unpack or unpack

--- Fix 1: gh.nvim double-escapes comment bodies. ------------------------------------
--
-- extract_text() runs `vim.fn.shellescape(body)` (issues/issue_buffer.lua:424,
-- commits/commit_buffer.lua:386, pr/init.lua:725,768) but the body then goes to
-- gh_exec(), which runs `vim.fn.system(args)` with a LIST. A list execs the process
-- directly, so no shell ever consumes the escaping and the literal `'...'` wrapper is
-- posted to GitHub as comment text.
--
-- That silently breaks @claude mentions: the comment arrives as `'@claude ...'`, the
-- workflow's `contains(body, '@claude')` substring test still matches so the job
-- starts, but claude-code-action's stricter mention check rejects it -> "No trigger
-- was met", and the run goes green having done nothing.

-- Inverse of vim.fn.shellescape: strip the wrapping quotes and collapse the '\''
-- sequence it uses to embed a literal apostrophe.
local function unshellescape(s)
  if type(s) ~= "string" then
    return s
  end
  if #s >= 2 and s:sub(1, 1) == "'" and s:sub(-1) == "'" then
    return (s:sub(2, -2):gsub("'\\''", "'"))
  end
  return s
end

-- Which argument holds the body, per ghcli function. submit_review is the odd one
-- out: submit_review(number, review_id, body, action).
local body_arg = {
  create_pull_issue_comment = 2,
  update_pull_issue_comment = 2,
  create_commit_comment = 2,
  update_commit_comment = 2,
  submit_review = 3,
}

local function patch_ghcli()
  local ok, ghcli = pcall(require, "litee.gh.ghcli")
  if not ok then
    return
  end
  for name, idx in pairs(body_arg) do
    local orig = ghcli[name]
    if type(orig) == "function" then
      ghcli[name] = function(...)
        local n = select("#", ...)
        local args = { ... }
        args[idx] = unshellescape(args[idx])
        return orig(unpack(args, 1, n))
      end
    end
  end
end

--- Fix 2: <leader>Gio can't reach closed issues. ------------------------------------
--
-- GHOpenIssue with no argument lists via GET /repos/{owner}/{repo}/issues, and that
-- endpoint defaults to state=open. gh.nvim never passes `state` (ghcli/init.lua:223),
-- so closed issues are never in the list. The plugin's request builder is unreachable
-- from config (async_request is module-local), so this is a replacement picker that
-- asks for state=all and hands off to gh.nvim's public open_issue_by_number().
--
-- Single page of 100; this repo is nowhere near that. `gh api --paginate` would need
-- --slurp to stay valid JSON, which isn't worth it here.
local function open_issue_any_state()
  vim.notify("Fetching issues...", vim.log.levels.INFO)
  vim.system({
    "gh",
    "api",
    "--method",
    "GET",
    "-F",
    "per_page=100",
    "-F",
    "state=all", -- the whole point: include closed
    "/repos/{owner}/{repo}/issues",
  }, { text = true }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      vim.notify("gh failed: " .. (res.stderr or "unknown error"), vim.log.levels.ERROR)
      return
    end
    local ok, data = pcall(vim.json.decode, res.stdout)
    if not ok or type(data) ~= "table" then
      vim.notify("Could not parse gh output", vim.log.levels.ERROR)
      return
    end
    -- This endpoint returns PRs too; they carry a `pull_request` key.
    local issues = {}
    for _, it in ipairs(data) do
      if not it.pull_request then
        issues[#issues + 1] = it
      end
    end
    if #issues == 0 then
      vim.notify("No issues found", vim.log.levels.WARN)
      return
    end
    vim.ui.select(issues, {
      prompt = "Select an issue to open:",
      format_item = function(it)
        return string.format(
          "#%d  [%s]  %s  (@%s)",
          it.number,
          it.state,
          it.title,
          it.user and it.user.login or "?"
        )
      end,
    }, function(choice)
      if choice then
        require("litee.gh.issues").open_issue_by_number(choice.number)
      end
    end)
  end))
end

return {
  {
    "ldelossa/gh.nvim",
    keys = {
      -- Overrides LazyVim's `<cmd>GHOpenIssue<cr>` mapping for the same lhs.
      { "<leader>Gio", open_issue_any_state, desc = "Open (incl. closed)" },
    },
    init = function()
      vim.api.nvim_create_user_command("GHOpenIssueAll", open_issue_any_state, {})
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(ev)
          if ev.data == "gh.nvim" then
            patch_ghcli()
          end
        end,
      })
    end,
  },
}
