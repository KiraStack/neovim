-- Copyright (c) 2026, Kira
-- Licensed under the MIT License
--
-- This file defines a Neovim (nvim) configuration.
-- It is intended to be used as a custom configuration
-- for Neovim.

-- Check if NeoVim supports the required version
if vim.fn.has("nvim-0.12") == 0 then
	vim.notify("NeoVim 0.12+ is required.", vim.log.levels.ERROR)
    return
end

-- Formatters
local formatters = {
    black = function()
        return { cmd = { "black", "-" } }
    end,
    clang_format = function()
        return { cmd = { "clang-format", "--assume-filename", vim.api.nvim_buf_get_name(0) } }
    end,
    prettier = function()
        return { cmd = { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(0) } }
    end,
    prettierd = function()
        return { cmd = { "prettierd", "--stdin-filepath", vim.api.nvim_buf_get_name(0) } }
    end,
    shfmt = function()
        return { cmd = { "shfmt", "-" } }
    end,
    stylua = function()
        return { cmd = { "stylua", "--indent-type=Spaces", "--indent-width=2", "--stdin-filepath", vim.api.nvim_buf_get_name(0), "-" } }
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

-- Format expression for LSP
_G.formatexpr = function(opts)
    local min, max = vim.v.lnum, vim.v.lnum + vim.v.count
    if format({ range = { min, max } }) then
        -- Format succeeded
        -- Do nothing
    else
        -- Fallback to handler
        return vim.lsp.formatexpr(opts)
    end
end

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
        "%f",                 -- filename
        "%h%w%m%r",           -- buffer flags
        "%=",                 -- right align
        status, -- dynamic LSP status
        " %-14(%l,%c%V%)",    -- cursor position
        "%P",                 -- percentage through file
    }, " ")
end

-- Globals
vim.g.mapleader = vim.keycode("<Space>")
vim.g.maplocalleader = vim.keycode("<CR>")

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

-- Editor Options
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.signcolumn = "yes"
vim.o.swapfile = false
vim.o.wrap = true
vim.o.winblend = 0 -- no transparency for floating windows
vim.o.formatexpr = "%!v:lua.formatexpr()"
vim.o.statusline = "%!v:lua.statusline()"

-- Leader shortcuts
vim.keymap.set("n", "<leader>o", ":source<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit current window" })
vim.keymap.set({'n','v','x'}, '<leader>y', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({'n','v','x'}, '<leader>p', '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv', { desc = "Move selected lines down" })
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv', { desc = "Move selected lines up" })
vim.keymap.set("n", "<leader>f", ":Pick files<CR>", { desc = "Open file picker" })
vim.keymap.set("n", "<leader>lf", function() format() end, { desc = "Format buffer with LSP" })
vim.keymap.set("n", "<leader>h", ":help<CR>", { desc = "Open help" })
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open Oil file explorer" })

-- Language servers
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "rust_analyzer", "tsserver" })

-- Attach LSP features when a client that supports them connects
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(args)
        vim.lsp.completion.enable(true, args.data.client_id, args.buf)
    end,
})

-- Enable treesitter for all file types
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitterConfig", { clear = true }),
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
    callback = function()
        if vim.b.format_on_save and vim.g.format_on_save then
            format({ async = true, silent = true })
        end
    end,
})

-- Handle Vim start
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("UserVimEnterConfig", { clear = true }),
    callback = function()
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

        -- Setup packages
        -- require("mini.files").setup()
        require("mini.pick").setup()

        -- Setup theme
        vim.cmd("colorscheme vague")
        vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    end,
})

-- Load plugins
vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/nvim-mini/mini.pick" },
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/vyfor/cord.nvim" }, -- Discord RP
})
