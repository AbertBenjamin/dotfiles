local fn = require("keymap.functions")
local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- general
keymap('n', "n", 'nzz', opts)
keymap('n', '<esc><esc>', ':nohls<CR>', opts)
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>q', ':qa!<CR>', opts)
keymap('n', '<leader>a', ':BlameToggle<CR>', opts)
-- keymap("n", "<C-n>", ":Neotree toggle<CR>", opts)
keymap("n", "<C-n>", function()
  require("fyler").toggle({ kind = "split_left_most" })
end, opts)
keymap("n", "<leader>t", ":silent !tmux split-window -h<CR>", opts)

-- buffers
keymap('n', "<leader>n", ":bnext<CR>", opts)
keymap('n', "<leader>p", ":bprev<CR>", opts)

-- movement
keymap('n', '<C-d>', '<C-d>zz', opts)
keymap('n', '<C-u>', '<C-u>zz', opts)

-- clipboard
keymap({ 'n', 'v' }, '<leader>y', '"+y', opts)
keymap({ 'n', 'v' }, '<leader>d', '"_d', opts)
keymap('x', 'p', [["_dP]], opts)

-- lsp keymap
-- Hover sized to the whole editor instead of the current split
local open_preview = vim.lsp.util.open_floating_preview
local big_hover = false

vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
  local buf, win = open_preview(contents, syntax, opts)
  if not big_hover or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_win() == win then
    return buf, win
  end
  big_hover = false

  local wpos = vim.fn.win_screenpos(0)
  local pos = { row = wpos[1] + vim.fn.winline() - 1, col = wpos[2] + vim.fn.wincol() - 1 }
  local width = 0
  for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.max(1, math.min(width, math.floor(vim.o.columns * 0.8)))
  vim.api.nvim_win_set_config(win, { width = width })

  local above, below = pos.row - 3, vim.o.lines - pos.row - 4
  local room = math.max(1, math.min(math.max(above, below), math.floor(vim.o.lines * 0.8)))
  local height = math.min(vim.api.nvim_win_text_height(win, {}).all, room)
  local row = below >= above and pos.row or pos.row - height - 3
  local col = math.max(0, math.min(pos.col - 1, vim.o.columns - width - 2))
  vim.api.nvim_win_set_config(win, { relative = "editor", row = row, col = col, width = width, height = height })
  return buf, win
end

local function hover()
  big_hover = true
  vim.lsp.buf.hover()
  vim.defer_fn(function() big_hover = false end, 3000)
end

-- K: show the diagnostic under the cursor first; K again shows LSP hover
local diag_win
keymap("n", "K", function()
  if diag_win and vim.api.nvim_win_is_valid(diag_win) then
    vim.api.nvim_win_close(diag_win, true)
    diag_win = nil
    return hover()
  end
  local _, win = vim.diagnostic.open_float({ scope = "cursor" })
  if win then
    diag_win = win
  else
    hover()
  end
end, {})
keymap("n", "gd", vim.lsp.buf.definition, {})
keymap("n", "gD", vim.lsp.buf.declaration, {})
keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "grr", vim.lsp.buf.references, opts)
keymap("n", "<leader>rn", vim.lsp.buf.rename, {})

keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action)
keymap("n", "<leader>cf", vim.lsp.buf.format)

-- Diagnostic navigation: jump to next error, or fallback to warning
keymap('n', '<leader>s', function() fn.jump_diag("next") end, { desc = "Next Error/Warning", unpack(opts) })
keymap('n', '<leader>S', function() fn.jump_diag("prev") end, { desc = "Prev Error/Warning", unpack(opts) })

-- Movement with jump position tracking
keymap("n", "j", fn.smart_move("j"), opts)
keymap("n", "k", fn.smart_move("k"), opts)

-- Jump back to last jump-mark
keymap("n", "''", "''", opts)

-- fff
keymap("n", "<leader>ff", function() require('fff').find_files() end, { desc = 'FFFind files' })
keymap("n", "<leader>fg", function() require('fff').live_grep() end, opts)
