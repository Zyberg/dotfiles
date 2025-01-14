local function show_references_with_custom_layout()
  require("omnisharp_extended").telescope_lsp_references(
    require("telescope.themes").get_ivy({
      layout_config = {
        height = 0.7, -- Adjust height for better visibility
        width = 0.95,
        horizontal = {
          preview_width = 0.4, -- Preview width
          results_width = 0.6, -- Preview width
        },
      },
      path_display = { "smart" }, -- Shorten paths for better readability
      show_line = false, -- Show the line content with the reference
      previewer = true, -- Keep the preview window
      sorting_strategy = "descending", -- Sort references by position
      layout_strategy = "horizontal", -- Switch to horizontal layout
      attach_mappings = function(_, map)
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        
        -- Display the full path dynamically on Alt+P
        map('i', '<M-p>', function()
          local entry = action_state.get_selected_entry()
          if entry then
            vim.api.nvim_echo({{ "Full Path: " .. entry.filename, "Normal" }}, false, {})
          end
        end)
        return true
      end,
    })
  )
end


return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				-- TODO: this should be uncommented for any non-nixos system. Need to do some lua wizardry for that
        -- ensure_installed = { "lua_ls", "omnisharp", "rust_analyzer" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		-- TODO: learn how to configure this dependency plugin
		dependencies = { "Hoffs/omnisharp-extended-lsp.nvim" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lsp_config = require("lspconfig")

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gr", show_references_with_custom_layout, { noremap = true })
      vim.keymap.set("n", "gd", require("omnisharp_extended").telescope_lsp_definition, { noremap = true })
      vim.keymap.set("n", "<leader>D", function() require("omnisharp_extended").telescope_lsp_references() end, { noremap = true })
			vim.keymap.set("n", "gi", require("omnisharp_extended").telescope_lsp_implementation, { noremap = true })
			vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

			lsp_config.lua_ls.setup({
				capabilities = capabilities,
			})

			lsp_config.omnisharp.setup({
				capabilities = capabilities,
				cmd = { "OmniSharp" },
				handlers = {
					["textDocument/definition"] = require("omnisharp_extended").handler,
				},
				enable_import_completion = true,
				organize_imports_on_format = true,
				enable_roslyn_analyzers = true,
			})
		end,
	},
}
