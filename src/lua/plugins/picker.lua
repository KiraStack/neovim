return {
	{
		url = "nvim-mini/mini.pick",
		lazy = false,
		config = function()
			-- Setup package
			local pick = require("mini.pick")
			pick.setup()

			-- Open picker
			vim.keymap.set("n", "<leader>f", ":Pick files<CR>", { desc = "Open file picker" })

			-- Picker actions
			vim.keymap.set("n", "q", pick.close, { desc = "Close picker" })
			-- vim.keymap.set("n", "<CR>", pick.done, { desc = "Confirm picker" })
			-- vim.keymap.set("n", "<Esc>", pick.reset, { desc = "Reset picker" })

			-- Navigate picker list
			vim.keymap.set("n", "<Up>", pick.up, { desc = "Move up in picker" })
			vim.keymap.set("n", "<Down>", pick.down, { desc = "Move down in picker" })
		end,
	},
}
