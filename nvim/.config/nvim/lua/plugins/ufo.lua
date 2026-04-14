-- Built-in treesitter folding (no plugin needed in 0.12)
vim.o.foldcolumn = '1'
vim.o.foldlevel = 50
vim.o.foldlevelstart = 50
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
