vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- TODO: move this out
-- Utility function to get a pid of a process defined by a grep
vim.g.get_pid = function(pattern)
	local handle = io.popen("ps aux | grep " .. pattern .. " | awk '{print $2}' | head -n 1")
	local result = handle:read("*a")
	handle:close()

	return result
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")
