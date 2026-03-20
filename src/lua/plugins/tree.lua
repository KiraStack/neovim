return {
	{
		url = "stevearc/oil.nvim",
		lazy = false,
		config = function()
			-- Setup package
			require("oil").setup({
				default_file_explorer = true,
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
					natural_order = true,
					is_always_hidden = function(name, data)
						return name == ".." or name == ".git"
					end,
				},
				win_options = {
					wrap = true,
				},
			})

			-- Setup keymaps
			vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Open file explorer" })
		end,
	},
}
