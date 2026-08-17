vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/A7Lavinraj/fyler.nvim",
})

require("fyler").setup({
  -- IntelliJ-aktig: fast venstre sidebar med ikoner og innrykkslinjer
  kind = "split_left_most",
  integrations = { icon = "mini_icons" },
  ui = { indent_guides = true },
  extensions = {
    git = { enabled = true },
    trash = { enabled = true },
  },
})
