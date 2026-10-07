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

for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "DetektNvim" })) do
  vim.api.nvim_del_autocmd(au.id)
  vim.api.nvim_create_autocmd(au.event, {
    group = "DetektNvim",
    pattern = au.pattern,
    callback = function(args)
      if is_difftool(args.file) or is_difftool(vim.api.nvim_buf_get_name(0)) then
        return
      end
      return au.callback(args)
    end,
  })
end
