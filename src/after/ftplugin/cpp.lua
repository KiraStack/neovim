-- Editor options
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true

-- Leader shortcuts
vim.api.nvim_buf_set_keymap(0, "n", "<F5>", ":w<CR>:!make %:r && ./ %:r<CR>", { noremap = true, silent = true })
