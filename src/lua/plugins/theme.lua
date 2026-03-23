return {
	{
		url = "folke/tokyonight.nvim",
		lazy = false,
		config = function()
			-- Setup package
			require("tokyonight").setup({
				style = "moon",
				light_style = "day",
				transparent = true,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					sidebars = "dark",
					floats = "dark",
				},
				day_brightness = 0.4,
				dim_inactive = true,
				lualine_bold = false,
				cache = true,
			})

			-- Manage theme
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
