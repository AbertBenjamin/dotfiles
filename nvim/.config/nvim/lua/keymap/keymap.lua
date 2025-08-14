
local fn = require ("keymap.functions")
local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- general
keymap('n', "n", 'nzz', opts)
keymap('n', '<esc><esc>', ':nohls<CR>', opts)
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>a', ':BlameToggle<CR>', opts)
keymap("n", "<C-n>", ":Neotree toggle<CR>", opts)
keymap("n", "<leader>t", ":silent !tmux split-window -h<CR>", opts)


-- directory
keymap('n', '<C-n>', ':NvimTreeFindFileToggle<CR>', { silent = true })

-- buffers 
keymap('n', "<leader>n", ":bnext<CR>", opts)
keymap('n', "<leader>p", ":bprev<CR>", opts)

-- movement
keymap('n', '<C-d>', '<C-d>zz', opts)
keymap('n', '<C-u>', '<C-u>zz', opts)

-- clipboard 
keymap({'n', 'v'}, '<leader>y', '"+y', opts)
keymap({'n', 'v'}, '<leader>d', '"_d', opts)
keymap('x', 'p', [["_dP]], opts)

-- lsp keymap
keymap("n", "K", vim.lsp.buf.hover, {})
keymap("n", "gd", vim.lsp.buf.definition, {})
keymap("n", "gD", vim.lsp.buf.declaration, {})
keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
keymap("n", "gr", vim.lsp.buf.references, {})
keymap("n", "<leader>rn", vim.lsp.buf.rename, {})

-- Diagnostic navigation: jump to next error, or fallback to warning
keymap('n', '<leader>s', function() fn.jump_diag("next") end, { desc = "Next Error/Warning", unpack(opts) })
keymap('n', '<leader>S', function() fn.jump_diag("prev") end, { desc = "Prev Error/Warning", unpack(opts) })

-- Movement with jump position tracking
keymap("n", "j", fn.smart_move("j"), opts)
keymap("n", "k", fn.smart_move("k"), opts)

-- Jump back to last jump-mark
keymap("n", "''", "''", opts)

