return {
	"nvim-tree/nvim-tree.lua",
	config = function()
		require("nvim-tree").setup({
			update_focused_file = {
				enable = true,
			},
		})

		vim.api.nvim_set_keymap("n", "<M-b>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
	end,
}
