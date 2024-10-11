return {
  'FabijanZulj/blame.nvim',
  config = function()
    require('blame').setup({
      focus_blame = false
    })
  end
}
