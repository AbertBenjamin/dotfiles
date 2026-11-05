vim.pack.add({
  "https://github.com/alexghergh/nvim-tmux-navigation",
})

local nvim_tmux_nav = require('nvim-tmux-navigation')
nvim_tmux_nav.setup {
  disable_when_zoomed = true,
}

-- wincmd also enters non-focusable windows (diffbandit gutters/number panes),
-- so skip past them and hand over to Rex/tmux if no focusable window is found
local rex_dirs = { h = "left", j = "down", k = "up", l = "right" }

local function navigate(dir, tmux_dir)
  return function()
    local start = vim.api.nvim_get_current_win()
    local prev = start
    while true do
      vim.cmd("wincmd " .. dir)
      local cur = vim.api.nvim_get_current_win()
      if cur == prev then break end
      if vim.api.nvim_win_get_config(cur).focusable ~= false then return end
      prev = cur
    end
    vim.api.nvim_set_current_win(start)
    if vim.env.REX_SESSION and vim.fn.executable("rex") == 1 then
      vim.system({
        "rex", "api", "call", "-s", vim.env.REX_SESSION, "session.focus_direction",
        vim.json.encode({ direction = rex_dirs[dir], wrap = false }),
      })
    elseif vim.env.TMUX and vim.fn.trim(vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'")) ~= "1" then
      vim.fn.system("tmux select-pane -" .. tmux_dir)
    end
  end
end

vim.keymap.set('n', "<C-h>", navigate("h", "L"))
vim.keymap.set('n', "<C-j>", navigate("j", "D"))
vim.keymap.set('n', "<C-k>", navigate("k", "U"))
vim.keymap.set('n', "<C-l>", navigate("l", "R"))
vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
