-- Formatters
local formatters = {
	black = function(_)
		return { cmd = { "black", "-" } }
	end,
	clang_format = function(buf)
		return { cmd = { "clang-format", "-assume-filename", vim.api.nvim_buf_get_name(buf or 0) } }
	end,
	prettierd = function(buf)
		return { cmd = { "prettierd", "--stdin-filepath", vim.api.nvim_buf_get_name(buf or 0) } }
	end,
	shfmt = function(_)
		return { cmd = { "shfmt", "-" } }
	end,
	stylua = function(buf)
		return {
			cmd = {
				"stylua",
				"--indent-type=Spaces",
				"--indent-width=2",
				"--stdin-filepath",
				vim.api.nvim_buf_get_name(buf or 0),
				"-",
			},
		}
	end,
}

-- Formatters for each filetype
local formatconf = {}

-- Filetypes that use the `prettier` formatter
local prettierd_files = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"html",
	"css",
	"json",
	"yaml",
}

-- Add grouped filetypes
for _, ft in ipairs(prettierd_files) do
	formatconf[ft] = formatters.prettierd
end

-- Add other filetypes
formatconf.c = formatters.clang_format
formatconf.cpp = formatters.clang_format
formatconf.lua = formatters.stylua
formatconf.python = formatters.black
formatconf.sh = formatters.shfmt

-- Global formatting function to format the current buffer
-- using the configured formatter
function _G.format()
	local buf = 0
	local ft = vim.bo.filetype
	local conf = formatconf[ft]

	if not conf then
		vim.notify("'" .. (ft == "" and "txt" or ft) .. "' is not supported.", vim.log.levels.ERROR)
		return
	end

	local opts = conf(buf)
	opts = vim.islist(opts) and opts or { opts }

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))

	for _, o in ipairs(opts) do
		local sysopts = { stdin = lines, text = true, cwd = cwd }

		vim.system(
			o.cmd,
			sysopts,
			vim.schedule_wrap(function(out)
				if out.code == 0 then
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out.stdout, "\n"))
				else
					vim.notify(string.format("Formatting failed: %s", out.stderr), vim.log.levels.ERROR)
				end
			end)
		)
	end
end
