local function get_persisted_value(key, default)
      local config_file = vim.fn.stdpath("data") .. "/dotnet_debug_config.json"
      local data = {}

      if vim.fn.filereadable(config_file) == 1 then
            local content = vim.fn.readfile(config_file)
          data = vim.fn.json_decode(table.concat(content, "\n"))
      end

      return data[key] or default
end

local function save_persisted_value(key, value)
      local config_file = vim.fn.stdpath("data") .. "/dotnet_debug_config.json"
      local data = {}

      if vim.fn.filereadable(config_file) == 1 then
            local content = vim.fn.readfile(config_file)
          data = vim.fn.json_decode(table.concat(content, "\n"))
      end

      data[key] = value
      local file = io.open(config_file, "w")
      file:write(vim.fn.json_encode(data))
      file:close()
end

local function get_dll_path()
      local saved_path = get_persisted_value("dll_path", nil)
      if saved_path then
            return saved_path
        end

      local project_dir = vim.fn.input("Enter the entry project directory: ", vim.fn.getcwd(), "dir")
      local project_name = vim.fn.fnamemodify(project_dir, ":t")
      local dll_path = project_dir .. "/bin/Debug/net8.0/" .. project_name .. ".dll"

      if vim.fn.confirm("Is this the correct DLL path?\n" .. dll_path, "&Yes\n&No", 1) == 1 then
            save_persisted_value("dll_path", dll_path)
            return dll_path
        end

      return vim.fn.input("Enter the DLL path manually: ", dll_path, "file")
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

    -- This shall stay
		dap.adapters.coreclr = {
			type = "executable",
			command = "netcoredbg",
			args = { "--interpreter=vscode" },
		}

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "Launch - netcoredbg",
				request = "launch",
				program = function()
          local dll_path = get_dll_path()
          print("Using DLL path: " .. dll_path)
          return dll_path
        end,
        env = {
          DOTNET_ENVIRONMENT = "Development",
          LASER_TYPE = "Unknown",
          ASBOLUS_ADMIN_BASE_URI = "http://127.0.0.1:20211"
        }
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
