-- ctrl+h/j/k/l moves between nvim windows, and hands focus to the neighbouring
-- Rex pane at the edge. Rex sends these keys to nvim when it's in the
-- foreground (smart_focus in rex/init.lua).

local rex_bin = vim.fn.exepath("rex")
if rex_bin == "" then
  rex_bin = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
end
vim.g.rex_bin = rex_bin

local rex_dirs = { h = "left", j = "down", k = "up", l = "right" }

-- diffbandit reuses the original window as its left header, so it stays
-- focusable even though diffbandit bounces focus out of it
local function is_diffbandit_header(win)
  local ok, state = pcall(require, "diffbandit.state")
  local session = ok and state.sessions[vim.api.nvim_get_current_tabpage()]
  if not session then return false end
  for key, value in pairs(session) do
    if value == win and type(key) == "string" and key:match("header_win$") then return true end
  end
  return false
end

-- Find the nearest focusable window in a direction from its screen position,
-- without entering anything on the way: diffbandit bounces focus to the
-- opposite pane whenever one of its non-focusable helper windows (gutters,
-- overview, headers) is entered, and winnr()/wincmd don't reach past them.
local function neighbor(dir)
  local cur = vim.api.nvim_get_current_win()
  local top, left = unpack(vim.fn.win_screenpos(cur))
  local width, height = vim.api.nvim_win_get_width(cur), vim.api.nvim_win_get_height(cur)
  local row, col = top + vim.fn.winline() - 1, left + vim.fn.wincol() - 1
  local best, best_dist
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if win ~= cur and cfg.relative == "" and cfg.focusable ~= false and not is_diffbandit_header(win) then
      local r, c = unpack(vim.fn.win_screenpos(win))
      local w, h = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
      local dist
      if dir == "h" and c + w <= left and r <= row and row < r + h then
        dist = left - (c + w)
      elseif dir == "l" and c >= left + width and r <= row and row < r + h then
        dist = c - (left + width)
      elseif dir == "k" and r + h <= top and c <= col and col < c + w then
        dist = top - (r + h)
      elseif dir == "j" and r >= top + height and c <= col and col < c + w then
        dist = r - (top + height)
      end
      if dist and (not best_dist or dist < best_dist) then
        best, best_dist = win, dist
      end
    end
  end
  return best
end

-- Hand over to Rex when there is no window in that direction
local function navigate(dir)
  return function()
    local win = neighbor(dir)
    if win then
      vim.api.nvim_set_current_win(win)
      return
    end
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
