return {
  "A7Lavinraj/fyler.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  branch = "stable",

  config = function()
    local fyler = require("fyler")
    fyler.setup({
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
                ignored = ""
              }
            }
          },
          follow_current_file = true
        }
      }
    })
  end
}
