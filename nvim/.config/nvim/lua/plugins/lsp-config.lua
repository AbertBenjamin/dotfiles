return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<Right>"] = { "show", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      appearance = {
        nerd_font_variant = 'mono'
      },
      completion = {
        documentation = { auto_show = false },
        ghost_text = { enabled = true }
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'omni' },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Pass blink.cmp capabilities to every LSP server (Neovim 0.11+ native API)
      vim.lsp.config('*', {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- lua_ls: add Neovim-specific settings so "vim" global is recognised
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      require("mason-lspconfig").setup({
        ensure_installed = {
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
          "lua_ls"
        },
        -- kotlin_lsp is managed entirely by kotlin.nvim – skip auto-enable here
        automatic_enable = {
          exclude = { "kotlin_lsp" },
        },
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.ktlint,
          null_ls.builtins.formatting.google_java_format,
          require("none-ls.diagnostics.eslint"),
        },
      })
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup({
        bind = true,
        hint_enable = true, -- Enable virtual text hints like in IntelliJ
        hint_prefix = "🐍 ", -- Optional: Custom hint icon
        handler_opts = {
          border = "rounded", -- Rounded border for the popup
        },
        floating_window = true, -- Show signatures in a floating window
        floating_window_above_cur_line = true, -- Align the floating window above the current line
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        auto_open = false,   -- Do not auto-open trouble when errors are detected
        auto_close = true,   -- Auto-close when the trouble list is empty
        use_diagnostic_signs = true, -- Use LSP diagnostic signs
      })
    end,
  },
}

