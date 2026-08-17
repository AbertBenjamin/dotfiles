vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.icons",
})

-- ponytail: kt arver MiniIconsBlue -> DiagnosticInfo, som er grønn i darculasolid
require("mini.icons").setup({
  extension = {
    kt  = { glyph = "󱈙", hl = "MiniIconsPurple" },
    kts = { glyph = "󱈙", hl = "MiniIconsPurple" },
  },
})
require("oil").setup({})
