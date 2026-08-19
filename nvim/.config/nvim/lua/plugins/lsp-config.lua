vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
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
vim.opt.completeopt = 'menuone,noselect,fuzzy'
vim.opt.pumheight = 10
vim.opt.pumwidth = 20

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Auto-completion
    vim.lsp.completion.enable(true, args.data.client_id, buf, { autotrigger = true })

    -- 2. Tab/S-Tab for completion navigation
    vim.keymap.set('i', '<Tab>', function()
      if vim.fn.pumvisible() == 1 then return '<C-n>' else return '<Tab>' end
    end, { buffer = buf, expr = true })
    vim.keymap.set('i', '<S-Tab>', function()
      if vim.fn.pumvisible() == 1 then return '<C-p>' else return '<S-Tab>' end
    end, { buffer = buf, expr = true })

    -- 3. Signature help while typing function arguments
    if client and client:supports_method("textDocument/signatureHelp") then
      vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = buf })
    end

    -- 4. Highlight references under cursor
    if client and client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("LspHighlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

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
  "kotlin_lsp",
})
