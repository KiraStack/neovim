return {
	{
		url = "rafamadriz/friendly-snippets",
		lazy = false,
	},
	{
		url = "saghen/blink.cmp",
		lazy = false,
		config = function()
			-- Setup package
			local cmp = require("blink.cmp")
			cmp.setup({
				fuzzy = {
					prebuilt_binaries = {
						force_version = true,
					},
				},
			})

			-- Setup keymap for completions
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
