-- Open a terminal in the directory of the current file
vim.api.nvim_create_user_command("TermHere", function()
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  if not dir or dir == "" then
    dir = vim.loop.cwd()
  end
  vim.cmd("split term://" .. dir)
  vim.cmd("startinsert")
end, { desc = "Open terminal in current file's directory" })

vim.keymap.set("n", "<leader>tt", "<cmd>TermHere<cr>", { desc = "Terminal Here (split)" })

-- lazy.nvim requires every file in lua/plugins/ to return a spec table
return {}
