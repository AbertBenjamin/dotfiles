
local M = {}

function M.jump_diag(direction)
  local go = direction == "next" and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local ok = go({ severity = vim.diagnostic.severity.ERROR })
  if not ok then
    go({ severity = vim.diagnostic.severity.WARN })
  end
  vim.cmd("normal! zz")
end

function M.smart_move(key)
  return function()
    if vim.v.count > 0 then
      vim.cmd("mark '")
    end
    vim.cmd("normal! " .. vim.v.count1 .. key)
  end
end

local function jump(item)
  vim.cmd("normal! m'")
  local buf = item.bufnr or vim.fn.bufadd(item.filename)
  vim.bo[buf].buflisted = true
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
  vim.cmd("normal! zz")
end

-- Floating list at the cursor, styled like the completion menu (Pmenu)
local function menu(items, on_choice)
  local rows, width = {}, 1
  for _, item in ipairs(items) do
    local text = vim.trim(item.text or "")
    local loc = string.format("%s:%d", vim.fn.fnamemodify(item.filename, ":~:."), item.lnum)
    table.insert(rows, { text = text, loc = loc })
    width = math.max(width, vim.fn.strdisplaywidth(text) + vim.fn.strdisplaywidth(loc) + 4)
  end
  width = math.min(width, math.floor(vim.o.columns * 0.8))

  local lines = {}
  for i, row in ipairs(rows) do
    local loc_w = vim.fn.strdisplaywidth(row.loc)
    local text = vim.fn.strcharpart(row.text, 0, math.max(width - loc_w - 4, 1))
    local pad = width - 2 - vim.fn.strdisplaywidth(text) - loc_w
    lines[i] = " " .. text .. string.rep(" ", math.max(pad, 1)) .. row.loc .. " "
    rows[i].loc_col = #lines[i] - #row.loc - 1
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace("lsp_pick")
  for i, row in ipairs(rows) do
    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, row.loc_col, { end_col = row.loc_col + #row.loc, hl_group = "PmenuExtra" })
  end
  vim.bo[buf].modifiable = false

  local height = math.min(#items, 15)
  local below = vim.o.lines - vim.fn.screenrow() - 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = below >= height and 1 or -height,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "none",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = "Normal:Pmenu,CursorLine:PmenuSel"

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  local function choose()
    local item = items[vim.api.nvim_win_get_cursor(win)[1]]
    close()
    on_choice(item)
  end
  local o = { buffer = buf, nowait = true, silent = true }
  for _, key in ipairs({ "<CR>", "<Tab>", "o" }) do vim.keymap.set("n", key, choose, o) end
  for _, key in ipairs({ "<Esc>", "q", "<C-c>" }) do vim.keymap.set("n", key, close, o) end
  vim.keymap.set("n", "<C-n>", "j", o)
  vim.keymap.set("n", "<C-p>", "k", o)
  vim.keymap.set("n", "<S-Tab>", "k", o)
  vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
end

-- True if every item is the symbol under the cursor itself
local function at_cursor(items)
  local file = vim.api.nvim_buf_get_name(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum, col = pos[1], pos[2] + 1
  for _, item in ipairs(items) do
    local end_lnum, end_col = item.end_lnum or item.lnum, item.end_col or item.col
    local inside = vim.fs.normalize(item.filename) == vim.fs.normalize(file)
      and (lnum > item.lnum or (lnum == item.lnum and col >= item.col))
      and (lnum < end_lnum or (lnum == end_lnum and col <= end_col))
    if not inside then return false end
  end
  return true
end

local function references(opts)
  vim.lsp.buf.references({ includeDeclaration = false }, opts)
end
M.references = references

-- LSP locations (definition, references, ...) in a completion-style menu instead
-- of the quickfix list. A single result jumps straight there. Going to the
-- definition while already on it shows its usages, as in IntelliJ.
function M.lsp_pick(fn, usages_on_self)
  local pick
  pick = function(f, self_check)
    f({
      on_list = function(list)
        local items = list.items
        if self_check and #items > 0 and at_cursor(items) then
          return pick(references, false)
        end
        if #items == 0 then
          vim.notify("Ingen treff", vim.log.levels.INFO)
        elseif #items == 1 then
          jump(items[1])
        else
          menu(items, jump)
        end
      end,
    })
  end
  return function() pick(fn, usages_on_self) end
end

return M
