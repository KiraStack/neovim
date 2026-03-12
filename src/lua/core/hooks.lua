-- Headers
local format = require("utils.format")

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
	callback = function()
		if vim.g.format_on_save then
			local ok, fmt = pcall(require("utils.format"))
			if ok then
				fmt.format({ async = false }) -- run synchronously
			end
		end
	end,
})
