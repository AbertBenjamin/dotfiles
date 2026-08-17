vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/A7Lavinraj/fyler.nvim",
})

require("fyler").setup({
  kind = "split_left_most",
  integrations = { icon = "mini_icons" },
  ui = {
    indent_guides = true,
    hidden_items = { switches = {} },
  },
  extensions = {
    git = { enabled = true },
    trash = { enabled = true },
  },
})
