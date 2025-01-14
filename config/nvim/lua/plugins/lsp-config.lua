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
      vim.keymap.set("n", "gr", function() require("omnisharp_extended").telescope_lsp_references(require("telescope.themes").get_ivy({ excludeDefinition = true })) end, { noremap = true })
			vim.keymap.set("n", "gd", require("omnisharp_extended").telescope_lsp_definition, { noremap = true })
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
