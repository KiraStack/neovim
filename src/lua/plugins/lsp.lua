-- Constants
local langservers = { "clangd", "nixfmt", "pyright", "rust_analyzer" }

-- Function invoked when an LSP client attaches to a buffer
local on_attach = function(client, bufnr)
	-- Enable LSP-based completion
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Buffer-local keymaps
	local opts = { noremap = true, silent = true }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

-- Return the module
return {
	{
		url = "williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		url = "williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({ ensure_installed = langservers })
		end,
	},
	{
		url = "neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			-- Setup language servers
			vim.lsp.enable(langservers)

			-- Setup package
			-- local lspconfig = require("lspconfig")
			-- for i, langserver in ipairs(langservers) do
			-- 	lspconfig[langserver].setup({
			-- 		on_attach = function(client, bufnr) end, -- on_attach,
			-- 		flags = { debounce_text_changes = 150 },
			-- 	})
			-- end
		end,
	},
}
