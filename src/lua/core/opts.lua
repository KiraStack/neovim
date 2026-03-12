-- Globals
vim.g.mapleader = vim.keycode("<Space>")
vim.g.maplocalleader = vim.keycode("<CR>")

-- Editor Options
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.signcolumn = "yes"
vim.o.swapfile = false
vim.o.wrap = true
vim.o.winblend = 0 -- no transparency for floating windows
vim.o.formatexpr = "%!v:lua.formatexpr()"
vim.o.statusline = "%!v:lua.statusline()"
