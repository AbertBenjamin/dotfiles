vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/A7Lavinraj/fyler.nvim",
})

require("fyler").setup({
  views = {
    finder = {
      close_on_select = false,
      confirm_simple = false,
      default_explorer = true,
      delete_to_trash = true,
      columns = {
        git = {
          enabled = true,
          symbols = {
            added = "+",
            modified = "*",
            deleted = "-",
            renamed = ">",
            untracked = "??",
            copied = "=",
            conflict = "UU",
            ignored = "",
          },
        },
      },
      follow_current_file = true,
    },
  },
})
