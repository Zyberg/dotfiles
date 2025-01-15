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

      local function omnisharp_entry_maker(entry)
        local filename = vim.fn.fnamemodify(entry.filename or entry.uri, ":.")
        return {
          value = entry,
          display = filename, -- Show only file paths in the results
          ordinal = filename,
          filename = entry.filename or entry.uri,
          lnum = entry.lnum or entry.range.start.line + 1,
          col = entry.col or entry.range.start.character + 1,
        }
      end

      local function custom_implementations()
        local options = require("telescope.themes").get_ivy({
          layout_config = {
            height = 0.7, -- Adjust height for better visibility
            width = 0.95,
            horizontal = {
              preview_width = 0.4, -- Preview width
              results_width = 0.6, -- Results width
            },
          },
          path_display = { "smart" }, -- Shorten paths for better readability
          show_line = false, -- Hide the line content in the results list
          previewer = true, -- Keep the preview window
          sorting_strategy = "descending", -- Sort references by position
          layout_strategy = "horizontal", -- Horizontal layout with results and preview
        })

        -- Add your custom `entry_maker` to the options
        options.entry_maker = omnisharp_entry_maker

        -- Call `telescope_lsp_implementation` with the merged options
        require("omnisharp_extended").telescope_lsp_implementation(options)
      end

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gr", show_references_with_custom_layout, { noremap = true })
      vim.keymap.set("n", "gd", require("omnisharp_extended").telescope_lsp_definition, { noremap = true })
      vim.keymap.set("n", "<leader>D", function() require("omnisharp_extended").telescope_lsp_references() end, { noremap = true })
			vim.keymap.set("n", "gi", custom_implementations, { noremap = true })
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
