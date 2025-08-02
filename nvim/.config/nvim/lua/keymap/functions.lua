
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

return M
