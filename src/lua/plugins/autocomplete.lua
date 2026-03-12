return {
	{
		url = "saghen/blink.cmp",
		lazy = true,
		config = function()
			-- Setup autocompletion
			local cmp = require("blink.cmp")
			cmp.setup()

			-- Set tab completion
			vim.keymap.set("i", "<Tab>", function()
				if cmp.is_visible() then
					return cmp.select_and_accept()
				else
					local col = vim.fn.col(".") - 1
					if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
						return vim.api.nvim_feedkeys("\t", "n", true)
					else
						return vim.api.nvim_feedkeys("", "n", true)
					end
				end
			end, { desc = "Confirm blink suggestion or insert tab" })
		end,
	},
}
