-- Copyright (c) 2025, Kira Hasegawa
-- Licensed under the MIT license.
--
-- This file defines a Neovim (nvim) formatting function.
-- It is intended to be used as a custom format expression
-- or formatting callback within Neovim.
--

-- Global formatters
vim.g.formatconf = {
	c = formatters.clang_format,
	cpp = formatters.clang_format,
	css = formatters.prettierd,
	emblem = formatters.prettierd,
	graphql = formatters.prettierd,
	hbs = formatters.prettierd,
	handlebars = formatters.prettierd,
	html = formatters.prettierd,
	javascript = formatters.prettierd,
	javascriptreact = formatters.prettierd,
	less = formatters.prettierd,
	mdx = formatters.prettierd,
	markdown = formatters.prettierd,
	scss = formatters.prettierd,
	typescript = formatters.prettierd,
	typescriptreact = formatters.prettierd,
	vue = formatters.prettierd,
	json = formatters.prettierd,
	jsonc = formatters.prettierd,
	yaml = formatters.prettierd,
	lua = formatters.stylua,
	python = formatters.black,
	sh = formatters.shfmt,
} -- Formatters for each filetype
vim.g.format_on_save = true

local M = {}

-- Formatters
local formatters = {
	black = function()
		return { cmd = { "black", "-" } }
	end,
	clang_format = function()
		return { cmd = { "clang-format", "-assume-filename", vim.api.nvim_buf_get_name() } }
	end,
	prettier = function()
		return { cmd = { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name() } }
	end,
	prettierd = function()
		return { cmd = { "prettierd", "--stdin-filepath", vim.api.nvim_buf_get_name() } }
	end,
	shfmt = function()
		return { cmd = { "shfmt", "-" } }
	end,
	stylua = function()
		return {
			cmd = {
				"stylua",
				"--indent-type=Spaces",
				"--indent-width=2",
				"--stdin-filepath",
				vim.api.nvim_buf_get_name(),
				"-",
			},
		}
	end,
}

--[=[
    Format a buffer using a formatter.
    @param buf (number, optional) The buffer to format.
    @param opts (table, optional) The options to use for formatting.
--]=]
local function format_buf(buf, opts)
	buf = buf or 0
	opts = vim.tbl_extend("keep", opts or {}, {
		cmd = nil,
		stdin = {}, -- [line1, line2)
		range = {}, -- [line1, line2)
		transform = function(out)
			return vim.split(out, "\n")
		end,
		diff = "overlap",
		diff_algorithm = "histogram",
		timeout = 2500,
		silent = false,
		after_exit = function() end,
	})
	local cmd = opts.cmd
	if not vim.islist(cmd) then
		vim.notify("Invalid 'cmd': expected a list of strings", vim.log.levels.ERROR)
		return
	end
	local stdin1 = opts.stdin[1] or 1
	local stdin2 = opts.stdin[2] or vim.api.nvim_buf_line_count(buf) + 1
	local range1 = opts.range[1] or stdin1
	local range2 = opts.range[2] or stdin2
	local mode = vim.fn.mode()
	if vim.tbl_isempty(opts.range) and mode:match("[vV]") then
		local v1 = vim.api.nvim_win_get_cursor(0)[1]
		local v2 = vim.fn.getpos("v")[2]
		range1 = math.min(v1, v2)
		range2 = math.max(v1, v2) + 1
	end
	local lines = vim.api.nvim_buf_get_lines(buf, stdin1 - 1, stdin2 - 1, true)
	local file = vim.api.nvim_buf_get_name(buf)
	---@param out vim.SystemCompleted
	local on_exit = vim.schedule_wrap(function(out)
		if out.code == 0 then
			local fmt = assert(out.stdout, "No stdout")
			local fmt_lines = opts.transform(fmt)
			if opts.diff == "none" then
				vim.api.nvim_buf_set_lines(buf, stdin1 - 1, stdin2 - 1, true, fmt_lines)
				return
			end
			local lines_str = table.concat(lines, "\n") .. "\n"
			local diff_opts = { result_type = "indices", algorithm = opts.diff_algorithm }
			local diff = vim.text.diff(lines_str, fmt, diff_opts)
			if not diff then
				return
			end
			for i = #diff, 1, -1 do
				local d = diff[i]
				local a = { d[1], d[1] + d[2] }
				local b = { d[3], d[3] + d[4] }
				local a_buf = { a[1] + stdin1 - 1, a[2] + stdin1 - 1 }
				local set_hunk = function()
					local repl = b[1] == b[2] and {} or vim.list_slice(fmt_lines, b[1], b[2] - 1)
					local offs = a[1] == a[2] and 0 or -1
					vim.api.nvim_buf_set_lines(buf, a_buf[1] + offs, a_buf[2] + offs, false, repl)
				end
				if opts.diff == "any" then
					set_hunk()
				end
				if opts.diff == "contain" then
					if range1 <= a_buf[1] and range2 >= a_buf[2] then
						set_hunk()
					end
				end
				if opts.diff == "overlap" then
					if range1 <= a_buf[2] and a_buf[1] <= range2 then
						set_hunk()
					end
				end
			end
		else
			if not opts.silent then
				vim.notify(string.format("-%s- %s", cmd[1], out.stderr), vim.log.levels.ERROR)
			end
		end
		opts.after_exit(out)
	end)
	local sysopts = { ---@type vim.SystemOpts
		stdin = lines,
		text = true,
		cwd = vim.fs.dirname(file),
		timeout = opts.timeout,
	}
	return vim.system(cmd, sysopts, on_exit)
end

--[=[
    Formats the current buffer using the appropriate formatter based on filetype.
    @param opts (table, optional): Formatting options.
    @return (boolean): True if formatting was successful, false otherwise.
--]=]
local format = function(opts)
	opts = opts or {}
	local range = opts.range or {}
	local async = opts.async or false
	local formatconf = vim.g.formatconf or {}
	local conf = formatconf[vim.bo.ft]
	if not vim.is_callable(conf) then
		return false
	end
	local line1 = range[1] or 1
	local line2 = range[2] or vim.api.nvim_buf_line_count(0) + 1
	local mode = vim.fn.mode()
	if vim.tbl_isempty(range) and mode:match("[vV]") then
		local v1 = vim.api.nvim_win_get_cursor(0)[1]
		local v2 = vim.fn.getpos("v")[2]
		line1 = math.min(v1, v2)
		line2 = math.max(v1, v2) + 1
	end
	---@return vim.SystemCompleted
	local format_co = function(buf, opts)
		opts = vim.tbl_extend("keep", opts or {}, {
			range = { line1, line2 },
			silent = opts.silent,
		})
		if async then
			local co = coroutine.running()
			local after_exit = opts.after_exit
			opts.after_exit = function(out)
				if type(after_exit) == "function" then
					after_exit(out)
				end
				coroutine.resume(co, out)
			end
			format_buf(buf, opts)
			return coroutine.yield()
		else
			return format_buf(buf, opts):wait()
		end
	end
	local co = coroutine.create(function()
		local fmt_opts = conf(line1, line2)
		fmt_opts = vim.islist(fmt_opts) and fmt_opts or { fmt_opts }
		for _, opts in ipairs(fmt_opts) do
			local out = format_co(0, opts)
			if out.code ~= 0 then
				break
			end
		end
	end)
	coroutine.resume(co)
	return co
end

return M
