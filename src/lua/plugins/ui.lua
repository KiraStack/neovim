return {
	{
		url = "folke/tokyonight.nvim",
		lazy = false,
		config = function()
			-- Setup package
			require("tokyonight").setup({
				style = "moon",
				transparent = true,
			})

			-- Manage theme
			vim.cmd("colorscheme tokyonight")
		end,
	},
}
