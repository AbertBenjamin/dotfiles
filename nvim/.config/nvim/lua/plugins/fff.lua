vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'fff.nvim' and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      require("fff.download").download_or_build_binary()
    end
  end,
})

vim.pack.add({
  "https://github.com/dmtrKovalenko/fff.nvim",
})

require("fff").setup({
  debug = {
    enabled = false,
    show_scores = false,
  },
  layout = {
    prompt_position = 'top',
  },
})

