vim.pack.add({
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})


require("render-markdown").setup({
  render_modes = { 'n', 'c', 't' },
  anti_conceal = {
    enabled = false,
  },
  code = {
    background = "none",
  },
  heading = {
    backgrounds = {},
  },
})
