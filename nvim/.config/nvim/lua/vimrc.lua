vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"

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

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

local opts = { noremap = true, silent = true }
vim.keymap.set('n', "n", 'nzz', opts)
vim.keymap.set('n', '<leader>a', ':BlameToggle<CR>', opts)

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    float = {
        -- border = "rounded",
        source = "always",
    },
})

local servers = {
  "luals",
  "gopls",
}

vim.lsp.enable("luals")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("dockerls")
vim.lsp.enable("json-lsp")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("nil_ls")
vim.lsp.enable("kotlinls")
vim.lsp.enable("javals")



