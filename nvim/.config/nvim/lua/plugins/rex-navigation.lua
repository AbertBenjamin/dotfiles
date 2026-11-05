-- ctrl+h/j/k/l moves between nvim windows, and hands focus to the neighbouring
-- Rex pane at the edge. Rex sends these keys to nvim when it's in the
-- foreground (smart_focus in rex/init.lua).

local rex_bin = vim.fn.exepath("rex")
if rex_bin == "" then
  rex_bin = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
end
vim.g.rex_bin = rex_bin

local rex_dirs = { h = "left", j = "down", k = "up", l = "right" }

-- wincmd also enters non-focusable windows (diffbandit gutters/number panes),
-- so skip past them and hand over to Rex if no focusable window is found
local function navigate(dir)
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
    if vim.env.REX_SESSION and vim.fn.executable(rex_bin) == 1 then
      vim.system({
        rex_bin, "api", "call", "-s", vim.env.REX_SESSION, "session.focus_direction",
        vim.json.encode({ direction = rex_dirs[dir], wrap = false }),
      })
    end
  end
end

vim.keymap.set('n', "<C-h>", navigate("h"))
vim.keymap.set('n', "<C-j>", navigate("j"))
vim.keymap.set('n', "<C-k>", navigate("k"))
vim.keymap.set('n', "<C-l>", navigate("l"))
vim.keymap.set('n', "<C-\\>", "<C-w>p")
