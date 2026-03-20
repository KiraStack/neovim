local groups = {
	"Normal",
	"NormalNC",
	"SignColumn",
	"LineNr",
	"CursorLineNr",
	-- "EndOfBuffer",
}

-- Manage theme
-- vim.cmd.colorscheme("habamax")

-- Set highlights
for i, group in ipairs(groups) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end
