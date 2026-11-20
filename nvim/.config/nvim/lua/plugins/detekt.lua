vim.pack.add({
  "https://github.com/nielsdekker/detekt.nvim",
})

-- detekt.nvim calls vim.notify from vim.system callbacks (fast event context)
local notify = vim.notify
vim.notify = function(...)
  if vim.in_fast_event() then
    local args = { ... }
    vim.schedule(function() notify(unpack(args)) end)
  else
    notify(...)
  end
end

require("detekt").setup({
  file_pattern = { "*.kt" },
})

-- Skip detekt for git difftool temp files (no detekt.yml there)
local function is_difftool(name)
  return name:find("/git%-difftool%.") ~= nil
end

local function has_config(name)
  return vim.fs.find({ "detekt.yaml", "detekt.yml" }, {
    upward = true,
    type = "file",
    path = vim.fs.dirname(name),
  })[1] ~= nil
end

-- detekt.nvim lints the current buffer, but BufAdd fires for the added buffer
-- before it becomes current (e.g. when fff opens a file), so run it in the
-- buffer from the event. Skip files with no detekt config above them, such as
-- untracked detekt.yml missing from a fresh worktree outside ~/github.
for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "DetektNvim" })) do
  vim.api.nvim_del_autocmd(au.id)
  vim.api.nvim_create_autocmd(au.event, {
    group = "DetektNvim",
    pattern = au.pattern,
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name == "" or is_difftool(name) or not has_config(name) then
        return
      end
      return vim.api.nvim_buf_call(args.buf, function() return au.callback(args) end)
    end,
  })
end
