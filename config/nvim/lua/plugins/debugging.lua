vim.g.dotnet_build_project = function()
	local default_path = vim.fn.getcwd() .. "/"
	if vim.g["dotnet_last_proj_path"] ~= nil then
		default_path = vim.g["dotnet_last_proj_path"]
	end
	local path = vim.fn.input("Path to your *proj file", default_path, "file")
	vim.g["dotnet_last_proj_path"] = path
	local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"
	print("")
	print("Cmd to execute: " .. cmd)
	local f = os.execute(cmd)
	if f == 0 then
		print("\nBuild: ✔️ ")
	else
		print("\nBuild: ❌ (code: " .. f .. ")")
	end
end

vim.g.dotnet_get_dll_path = function()
	local request = function()
		return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
	end

	if vim.g["dotnet_last_dll_path"] == nil then
		vim.g["dotnet_last_dll_path"] = request()
	else
		if
			vim.fn.confirm("Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"], "&yes\n&no", 2)
			== 1
		then
			vim.g["dotnet_last_dll_path"] = request()
		end
	end

	return vim.g["dotnet_last_dll_path"]
end

vim.g.dotnet_get_pid = function()
	local request = function()
		local grep_expression = vim.fn.input("Process Name (grep expression): ")

		vim.g["dotnet_last_pid_grep"] = grep_expression

		return vim.g.get_pid(grep_expression)
	end

	if vim.g["dotnet_last_pid"] == nil then
		vim.g["dotnet_last_pid"] = request()
	else
		local pid_of_grep = vim.g.get_pid(vim.g["dotnet_last_pid_grep"])

		vim.fn.print("Currently the pid of '" .. vim.g["dotnet_last_pid_grep"] .. "' is: \t" .. pid_of_grep .. "\t")

		if vim.fn.confirm("Do you want to change the pid?\n" .. vim.g["dotnet_last_pid"], "&yes\n&no", 2) == 1 then
			if vim.fn.confirm("Do you want to change grep?", "&yes\n&no", 2) == 1 then
				vim.g["dotnet_last_pid"] = request()
			else
				vim.g["dotnet_last_pid"] = vim.g.get_pid(vim.g["dotnet_last_pid_grep"])
			end
		end
	end

	return vim.g["dotnet_last_pid"]
end

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
				name = "Attach to Process",
				request = "attach",
				processId = function()
					return vim.g.dotnet_get_pid()
				end,
			},
			{
				type = "coreclr",
				name = "Launch - netcoredbg",
				request = "launch",
				program = function()
					if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
						vim.g.dotnet_build_project()
					end
					return vim.g.dotnet_get_dll_path()
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

		vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = ">", texthl = "", linehl = "", numhl = "" })

		-- TODO: eventually move this out to a dotnet config file
		vim.api.nvim_set_keymap(
			"n",
			"<C-b>",
			":lua vim.g.dotnet_build_project()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}
