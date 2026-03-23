local format = require("utils.format")

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
	callback = _G.format,
})
