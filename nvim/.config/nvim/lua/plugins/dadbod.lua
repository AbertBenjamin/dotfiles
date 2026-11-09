vim.pack.add({
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
})

if vim.fn.executable("sqlcl") == 1 then
  vim.g.dbext_default_ORA_bin = "sqlcl"
  local sqlpath = vim.fn.stdpath("config") .. "/sqlcl"
  vim.env.SQLPATH = vim.env.SQLPATH and (sqlpath .. ":" .. vim.env.SQLPATH) or sqlpath
end

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1

-- Keep query buffers between sessions, and don't run the whole buffer on :w
vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/db_ui/queries"
vim.g.db_ui_execute_on_save = 0

-- Run the statement under the cursor: the block of lines around it,
-- delimited by blank lines. Goes through dadbod-ui so bind params still work.
local function run_statement()
  local is_blank = function(l) return vim.fn.getline(l):match("^%s*$") ~= nil end
  local cur = vim.fn.line(".")
  if is_blank(cur) then return end
  local first, last = cur, cur
  while first > 1 and not is_blank(first - 1) do first = first - 1 end
  while last < vim.fn.line("$") and not is_blank(last + 1) do last = last + 1 end

  local view = vim.fn.winsaveview()
  vim.cmd("normal! " .. first .. "GV" .. last .. "G\27")
  vim.fn.winrestview(view)
  vim.api.nvim_feedkeys(vim.keycode("gv<Plug>(DBUI_ExecuteQuery)"), "m", false)
end

local function map_run(buf)
  vim.keymap.set("n", "<leader>e", run_statement, { buffer = buf, desc = "Run statement under cursor" })
  vim.keymap.set("v", "<leader>e", "<Plug>(DBUI_ExecuteQuery)", { buffer = buf, desc = "Run selection" })
end

-- Only in dadbod-ui query buffers. dadbod-ui may set dbui_db_key_name after
-- the filetype, so check again on the next tick.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) and vim.b[ev.buf].dbui_db_key_name then
        map_run(ev.buf)
      end
    end)
  end,
})
