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
local formatconf = {
	lua = formatters.stylua,
	python = formatters.black,
	sh = formatters.shfmt,
	c = formatters.clang_format,
	cpp = formatters.clang_format,
	javascript = formatters.prettierd,
	javascriptreact = formatters.prettierd,
	typescript = formatters.prettierd,
	typescriptreact = formatters.prettierd,
	html = formatters.prettierd,
	css = formatters.prettierd,
	json = formatters.prettierd,
	yaml = formatters.prettierd,
}

-- Return the module
return {
	format = function(opts)
		opts = opts or {}
		local ft = vim.bo.filetype
		local conf = formatconf[ft]
		if not conf then
			vim.notify("No formatter configured for filetype: " .. ft, vim.log.levels.WARN)
			return
		end

		local fmt_opts = conf()
		fmt_opts = vim.islist(fmt_opts) and fmt_opts or { fmt_opts }

		for _, o in ipairs(fmt_opts) do
			local buf = 0
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local sysopts = { stdin = lines, text = true, cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)) }
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
	end,
}
