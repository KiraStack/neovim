local paths = {
	data = vim.fn.stdpath("data") .. "/site/pack/ext", -- base package folder
	start = nil,
	opt = nil,
	plugins = vim.fn.stdpath("config") .. "/lua/plugins", -- plugin modules folder
}

-- Derive directories
paths.start = paths.data .. "/start"
paths.opt = paths.data .. "/opt"

-- Get listed packages
local packages = {}
local handle = vim.loop.fs_scandir(paths.plugins)

-- Check if any plugins were listed
if handle then
	while true do
		-- Get the next entry
		local file, kind = vim.loop.fs_scandir_next(handle)

		-- Terminate if no more entries were found
		if not file then
			break
		end

		-- Check if the given entry can be defined as a plugin module
		if kind == "file" and file:match("%.lua$") and file ~= "init.lua" then
			-- Load the plugin
			local name = file:gsub("%.lua$", "") -- strip file ext.
			local ok, res = pcall(require, "plugins." .. name)

			-- Check if the plugin could be loaded
			if ok and type(res) == "table" then
				vim.list_extend(packages, res) -- merge the plugin table
			else
				error(res)
			end
		end
	end
end

-- Create a table of (active) plugin folder names
local activePkgs = {}
for i, package in ipairs(packages) do
	activePkgs[vim.fn.fnamemodify(package.url, ":t")] = true
end

-- Remove unused packages
for _, dir in ipairs({ paths.start, paths.opt }) do
	local handle = vim.loop.fs_scandir(dir)
	if handle then
		while true do
			-- Get the next entry
			local name, kind = vim.loop.fs_scandir_next(handle)

			-- Terminate if no more entries were found
			if not name then
				break
			end

			-- Check if the current directory is 'unused'
			if kind == "directory" and not activePkgs[name] then
				print("Removing unused plugin: '" .. name .. "'")
				vim.fn.delete(dir .. "/" .. name, "rf")
			end
		end
	end
end

-- Configure packages
for i, package in ipairs(packages) do
	local name = vim.fn.fnamemodify(package.url, ":t")
	local path = (package.lazy and paths.opt or paths.start) .. "/" .. name

	-- Check if the package has a 'home' (folder)
	-- If not, clone it (via GitHub)
	if vim.fn.empty(vim.fn.glob(path)) > 0 then
		print("Adding missing package: '" .. package.url .. "'")
		vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. package.url, path })
	end

	-- If the plugin is 'immediate' (not 'lazy'), add it to runtime
	if not package.lazy then
		vim.opt.rtp:prepend(path)
	end

	-- If the plugin defines an 'init' function, call it safely
	if package.config then
		pcall(package.config)
	end
end

-- Write formatted string to console
print("Recognised", #packages, "packages.")
