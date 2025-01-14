return {
	--"nvim-tree/nvim-tree.lua",
	--config = function()
		--require("nvim-tree").setup({
     -- view = {
      --  width = 500,
      --},
			--update_focused_file = {
			--	enable = true,
			--},
		--})

		--vim.api.nvim_set_keymap("n", "<M-b>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
	--end,
  "echasnovski/mini.files",
  version = false,
  config = function()
    require("mini.files").setup()

    vim.api.nvim_set_keymap("n", "<M-b>", ":lua MiniFiles.open()<CR>", { noremap = true, silent = true })
  end,
}
