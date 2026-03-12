return {
	-- {
	-- 	url = "nvim-tree/nvim-web-devicons",
	-- 	lazy = false,
	-- },
	{
		url = "preservim/nerdtree",
		lazy = false,
		config = function()
			-- Disable 'netrw' at startup
			-- vim.g.loaded_netrw = 1
			-- vim.g.loaded_netrwPlugin = 1

			-- Setup package
			-- require("nvim-tree").setup()

			-- Options
			vim.g.NERDTreeDirArrows = 1 -- nice arrows
			-- vim.g.NERDTreeMinimalUI = 1 -- debloat (disabled for appearance reasons)
			vim.g.NERDTreeShowHidden = 1 -- show hidden files
			vim.g.NERDTreeHijackNetrw = 1 -- manage netrw

			-- Shortcuts
			vim.keymap.set("n", "<Leader>e", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
		end,
	},
}
