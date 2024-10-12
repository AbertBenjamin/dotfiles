return {
  "rebelot/kanagawa.nvim",
  config = function()
    require('kanagawa').load("wave")
    require('kanagawa').setup({
      transparent = true,
      globalStatus = false
    })
  end
}

