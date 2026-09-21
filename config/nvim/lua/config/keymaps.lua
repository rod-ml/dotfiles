-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Reopen the home dashboard. Snacks.dashboard.open() with no args puts it in a float
-- (dismiss with q or <esc>), so it overlays the current layout rather than replacing
-- the buffer in this window -- unlike the one shown at startup. Pass { win = 0 } if you
-- want that takeover behaviour instead.
--
-- Wrapped in a function so `Snacks` is looked up when the key is pressed rather than
-- when this file loads, which keeps it independent of plugin load order.
vim.keymap.set("n", "<leader>h", function()
  Snacks.dashboard.open()
end, { desc = "Home Dashboard" })

-- <leader>L opens Lazy (moved off <leader>l so vimtex owns <leader>l for LaTeX)
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>l", "", { desc = "latex (vimtex)" })
