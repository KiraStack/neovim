-- Editor options
vim.opt_local.indentkeys:remove(":")

-- Leader shortcuts
vim.api.nvim_buf_set_keymap(0, "n", "<F5>", ":w<CR>:!make %:p:r && %:p:r<CR>", { noremap = true, silent = true })
