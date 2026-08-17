vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.icons",
})

local mi = require("mini.icons")

local folder = { glyph = "󰉋", hl = "MiniIconsGrey" }
local dirs = {}
for _, name in ipairs(mi.list("directory")) do
  dirs[name] = folder
end

mi.setup({
  directory = dirs,
  default = { directory = folder },
  extension = {
    kt  = { glyph = "󱈙", hl = "MiniIconsPurple" },
    kts = { glyph = "󱈙", hl = "MiniIconsPurple" },
  },
})
require("oil").setup({})
