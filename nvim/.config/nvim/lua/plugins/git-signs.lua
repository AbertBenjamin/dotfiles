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
