return {
	{
		url = "lewis6991/gitsigns.nvim",
		lazy = false,
		config = function()
			-- Setup package
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				current_line_blame = false,
				watch_gitdir = { interval = 1000 },
			})
		end,
	},
}
