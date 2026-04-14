vim.pack.add({
  "https://github.com/nvim-mini/mini.files",
})

require('mini.files').setup({
  options = {
    use_as_default_explorer = false,
  },
  windows = {
    preview = true,
    width_preview = 50,
  },
})

vim.keymap.set("n", "<leader>cd", function()
  require("mini.files").open()
end)
