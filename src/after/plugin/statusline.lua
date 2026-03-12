-- Generate the statusline
function _G.statusline()
	-- Get current LSP clients
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local status = ""

	-- Show attached LSP client names in the statusline
	if #clients > 1 then
		local names = {}
		for _, client in ipairs(clients) do
			table.insert(names, client.name:gsub("language.server", "ls"))
		end
		status = "[" .. table.concat(names, ", ") .. "]"
	end

	return table.concat({
		"%f", -- filename
		"%h%w%m%r", -- buffer flags
		"%=", -- right align
		status, -- dynamic LSP status
		" %-14(%l,%c%V%)", -- cursor position
		"%P", -- percentage through file
	}, " ")
end
