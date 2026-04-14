vim.pack.add({
  "https://github.com/nielsdekker/detekt.nvim",
})

require("detekt").setup({
  config_names = { "detekt-config.yml" },
  file_pattern = { "*.kt" },
})
