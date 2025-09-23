vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.winborder = "rounded"
vim.opt.equalalways = true

vim.opt.splitright = true

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

vim.opt.swapfile = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.updatetime = 50
vim.opt.clipboard = 'unnamedplus'
vim.opt.showmode = false

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " " }

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
    },
})

vim.lsp.enable('java_language_server')
vim.lsp.enable('bashls')
vim.lsp.enable('docker_compose_language_service')
vim.lsp.enable('dockerls')
vim.lsp.enable('eslint')
vim.lsp.enable('jsonls')
vim.lsp.enable('lemminx')
vim.lsp.enable('ts_ls')
vim.lsp.enable('yamlls')
vim.lsp.enable('gopls')
-- vim.lsp.enable('luals')



