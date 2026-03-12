return {
	{
		url = "nvim-treesitter/nvim-treesitter",
		lazy = false,
		config = function()
			-- Setup package
			require("nvim-treesitter").install({ "c", "cpp", "nix", "python" })
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all", -- or list filetypes
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = true },
			})

			-- Enable treesitter for all file types
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("UserTreesitterConfig", { clear = true }),
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},
}
