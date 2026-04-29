vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/esmuellert/codediff.nvim",
})

require("codediff").setup({
  explorer = {
    view_mode = "tree",
    focus_on_select = true,
  },
  keymaps = {
    view = {
      quit = false,
    },
  },
})
