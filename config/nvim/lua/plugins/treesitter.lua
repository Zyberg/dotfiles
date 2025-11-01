return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "lua", "c_sharp", "haskell" },
      highlight = {
        enable = true,
        custom_captures = {
          ["hex_first"] = "TSHexDeviceId",
          ["hex_last"] = "TSHexIndex",
        },
      },
      indent = { enable = true },
    })
  end
}
