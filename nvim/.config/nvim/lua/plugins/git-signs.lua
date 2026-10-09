vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup()

vim.keymap.set("n", "gp", "<cmd>Gitsigns preview_hunk<CR>", { noremap = true, silent = true, desc = "Preview git hunk" })

vim.keymap.set("n", "g;", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    require("gitsigns").next_hunk()
  end)
  return "<Ignore>"
end, { expr = true, silent = true, desc = "Next git hunk" })

vim.keymap.set("n", "g,", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    require("gitsigns").prev_hunk()
  end)
  return "<Ignore>"
end, { expr = true, silent = true, desc = "Previous git hunk" })

-- Review av agent-endringer: staged = gjennomgått, unstaged = nytt fra agenten
local gs = require("gitsigns")
vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk (godkjenn)" })
vim.keymap.set("v", "<leader>hs", function()
  gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage valgte linjer" })
vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk (avvis)" })
vim.keymap.set("v", "<leader>hr", function()
  gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset valgte linjer" })
vim.keymap.set("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
vim.keymap.set("n", "<leader>hq", function() gs.setqflist("all") end, { desc = "Alle hunks i quickfix" })
