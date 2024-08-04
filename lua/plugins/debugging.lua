return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"Issafalcon/neotest-dotnet",
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		-- Set up C# / .NET debugging
		dap.adapters.coreclr = {
			type = "executable",
			command = "/usr/bin/netcoredbg",
			args = { "--interpreter=vscode" },
		}

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "launch - netcoredbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
				end,
			},
		}

		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})

		-- Additional keymaps for debugging
		vim.keymap.set("n", "<leader>dr", dap.repl.open, {})
		vim.keymap.set("n", "<leader>dl", dap.run_last, {})
		vim.keymap.set("n", "<leader>dj", dap.step_over, {})
		vim.keymap.set("n", "<leader>dk", dap.step_into, {})
		vim.keymap.set("n", "<leader>do", dap.step_out, {})
	end,
}
