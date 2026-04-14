vim.pack.add({
  "https://github.com/vim-scripts/dbext.vim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/kndndrj/nvim-dbee",
})

-- Build hook: install dbee binary on install/update
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-dbee' and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      require("dbee").install()
    end
  end,
})

pcall(require("dbee").setup)
