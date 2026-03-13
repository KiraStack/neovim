-- Headers
local format = require("utils.format")

-- Keymaps
-- vim.keymap.set("n", "<leader>o", ":source<CR>", { desc = "Source current file" })
-- vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save current file" })
vim.keymap.set("n", "q", "<C-w>q", { desc = "Quit current window" })
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("n", "<leader>lf", function()
	format.format()
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>h", ":help<CR>", { desc = "Open help" })
-- vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
