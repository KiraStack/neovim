return {
	{
		url = "nvim-treesitter/nvim-treesitter",
		lazy = false,
		config = function()
			local lspconfig = require("lspconfig")
			local langservers = { "clangd" }

			-- Configure treesitter
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "cpp", "nix" }, -- "all"
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = true },
			})

			-- Configure language servers
			for _, server in ipairs(langservers) do
				lspconfig[server].setup({
					on_attach = function(client, bufnr)
						vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
					end,
					flags = { debounce_text_changes = 150 },
				})
			end
		end,
	},
}
