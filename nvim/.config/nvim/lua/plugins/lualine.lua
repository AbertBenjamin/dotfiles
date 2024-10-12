return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("lualine").setup({
      -- options = {
      --   theme = 'm/.config/nvim/lua/plugins/lualine.lua
      --   base16'
      -- }
    })
  end,
}
