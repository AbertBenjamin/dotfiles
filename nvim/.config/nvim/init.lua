require "vimrc"
vim = vim

vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set(
  'n', "<leader>s",
  function()
    if not vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) then
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
    end
  end, { desc = "Jump to next error" })

vim.keymap.set(
  'n', "<leader>S",
  function()
    if not vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) then
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
    end
end, { desc = "Jump to previous error" })

-- Create a new augroup named "highlight_yank"
local highlight_yank_group = vim.api.nvim_create_augroup("highlight_yank", { clear = true })

-- Create an autocmd for TextYankPost event
vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_yank_group,
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
    pattern = "*",
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}

require("lazy").setup("plugins", opts)

require("oil").setup({
  keymaps = {
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  }
})
