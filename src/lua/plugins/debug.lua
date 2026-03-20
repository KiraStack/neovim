return {
	{
		url = "igorlfs/nvim-dap-view",
		lazy = false,
	},
	{
		url = "mfussenegger/nvim-dap",
		lazy = false,
		config = function()
			-- Setup package
			local dap = require("dap")

			-- Setup keymaps
			vim.keymap.set("n", "<F6>", dap.continue, { desc = "Continue" })
			vim.keymap.set("n", "<F7>", ":DapViewToggle<CR>", { desc = "Toggle panel" })
			vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })

			-- Runtimes
			dap.adapters = {
				go = {
					type = "server",
					port = "${port}",
					executable = {
						command = "dlv",
						args = { "dap", "-l", "127.0.0.1:${port}" },
					},
				},
				codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = "/nix/store/yc2apx8zcx7hzj44vayijwxv050ylvdh-lldb-11.1.0/bin/lldb-vscode",
						args = { "--port", "${port}" },
					},
				},
				cppdbg = {
					id = "cppdbg",
					type = "executable",
					command = os.getenv("HOME") .. "/.local/share/nvim/mason/bin/OpenDebugAD7",
				},
			}

			-- Run targets
			dap.configurations = {
				c = {
					{
						name = "Launch (codelldb)",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = vim.fn.getcwd(),
						stopOnEntry = false,
						args = {},
					},
					{
						name = "Attach (codelldb)",
						type = "codelldb",
						request = "attach",
						pid = require("dap.utils").pick_process,
					},
				},
			}

			-- Add aliases
			dap.configurations.cpp = dap.configurations.c
		end,
	},
}
