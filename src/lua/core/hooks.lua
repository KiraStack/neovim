-- Language servers
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "rust_analyzer", "tsserver" })

-- Attach LSP features when a client that supports them connects
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		vim.lsp.completion.enable(true, args.data.client_id, args.buf)
	end,
})

-- Enable treesitter for all file types
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserTreesitterConfig", { clear = true }),
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
	callback = function()
		if vim.b.format_on_save and vim.g.format_on_save then
			format({ async = true, silent = true })
		end
	end,
})
