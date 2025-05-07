return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        always_divide_middle = false,
        always_show_tabline = false
      }
    })
  end,
}
