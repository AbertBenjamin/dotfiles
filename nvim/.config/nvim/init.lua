require "vimrc"
require "keymap.keymap"
require "plugins.darculasolid"
require "plugins.autopairs"
require "plugins.blame"
require "plugins.codediff"
require "plugins.comfylinenumbers"
require "plugins.conform"
require "plugins.copilot"
-- require "plugins.detekt"  -- needs detekt.yml in project root
require "plugins.fff"
require "plugins.flash"
require "plugins.fyler"
require "plugins.git-signs"
require "plugins.kotlin"
require "plugins.lensline"
require "plugins.lsp-config"
require "plugins.mini"
require "plugins.mini-files"
require "plugins.mini-statusline"
require "plugins.neotest"
require "plugins.nio"
require "plugins.nvim-colorizer"
require "plugins.nvim-dbee"
require "plugins.nvim-lint"
require "plugins.nvim-tmux-navigation"
require "plugins.nvimnumbertoggle"
require "plugins.oil"
require "plugins.plenary"
require "plugins.rainbow-delimiters"
require "plugins.rendermarkdown"

require "plugins.surround"
require "plugins.treesitter"
require "plugins.ufo"
require "plugins.undotree"

-- Set colorscheme after all plugins are loaded
vim.cmd.colorscheme("darculasolid")

-- Match FloatBorder background to Normal so floating window borders don't have mismatched colors
local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_hl.fg or normal_hl.fg, bg = normal_hl.bg })

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

-- close qf-list when pressing enter on an entry
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
  end
})
