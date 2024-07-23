vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'

vim.opt.swapfile = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.updatetime = 50
vim.opt.clipboard = unnamedplus
vim.g.qs_higlight_on_keys = {'f','F','t','T'}

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

local opts = { noremap = true, silent = true }
vim.keymap.set('i', '{', '{}<Esc>ha', opts)
vim.keymap.set('i', '[', '[]<Esc>ha', opts)
vim.keymap.set('i', '(', '()<Esc>ha', opts)
vim.keymap.set('i', '"', '""<Esc>ha', opts)
vim.keymap.set('i', "'", "''<Esc>ha", opts)
vim.keymap.set('i', "`", "``<Esc>ha", opts)
vim.keymap.set('n', "n", 'nzz', opts)

