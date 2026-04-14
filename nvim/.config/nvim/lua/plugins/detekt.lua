vim.pack.add({
  "https://github.com/nielsdekker/detekt.nvim",
})

require("detekt").setup({
  file_pattern = { "*.kt" },
})
