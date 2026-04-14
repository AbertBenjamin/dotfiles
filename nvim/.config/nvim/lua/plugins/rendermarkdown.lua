vim.pack.add({
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})


require("render-markdown").setup({
  code = {
    background = "none",
  },
  heading = {
    backgrounds = {},
  },
})
