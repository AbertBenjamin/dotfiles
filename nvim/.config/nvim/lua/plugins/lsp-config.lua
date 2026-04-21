vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/kyazdani42/nvim-web-devicons" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

-- mason
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

-- mason-tool-installer
require("mason-tool-installer").setup({
  ensure_installed = {
    "jdtls",
    "bash-language-server",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "eslint-lsp",
    "json-lsp",
    "lemminx",
    "typescript-language-server",
    "yaml-language-server",
    "gopls",
    "lua-language-server",
    "kotlin-lsp"
  },
})

-- built-in completion
vim.opt.completeopt = 'menuone,noselect'
vim.opt.pumheight = 10
vim.opt.pumwidth = 20

vim.keymap.set('i', '<Right>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  else
    return '<C-x><C-o>'
  end
end, { expr = true })

-- Disable line numbers in LSP hover/signature floating windows
vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
    end
  end,
})

vim.lsp.enable({
  "jdtls",
  "bashls",
  "docker_compose_language_service",
  "dockerls",
  "eslint",
  "jsonls",
  "lemminx",
  "ts_ls",
  "yamlls",
  "gopls",
  "lua_ls",
})

-- trouble
require("trouble").setup({
  auto_open = false,
  auto_close = true,
  use_diagnostic_signs = true,
})
