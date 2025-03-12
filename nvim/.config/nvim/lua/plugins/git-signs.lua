return {
  "lewis6991/gitsigns.nvim",
  config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup()

    vim.keymap.set("n", "g;", "g;:Gitsigns preview_hunk<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "g,", "g,:Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

    -- Undo the shown hunk (reset changes)
    vim.keymap.set("n", "<leader>gu", function()
      gitsigns.reset_hunk()
    end, { noremap = true, silent = true, desc = "Undo Git Hunk" })
  end

}
