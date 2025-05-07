return {
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    ensure_installed = { "ktlint" },
  },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<Right>"] = { "show", "fallback" },
        -- { function(cmp) cmp.show({ providers = { 'lsp', 'path', 'buffer' } }) end }
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
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "java_language_server",
          "bashls",
          "docker_compose_language_service",
          "dockerls",
          "eslint",
          "jsonls",
          "kotlin_language_server",
          "lemminx",
          "lua_ls",
          "ts_ls",
          "yamlls",
          "gopls",
          "nil_ls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      servers = {
        java_language_server = {},
        bashls = {},
        docker_compose_language_service = {},
        dockerls = {},
        eslint = {},
        jsonls = {},
        kotlin_language_server = {},
        lemminx = {},
        lua_ls = {},
        ts_ls = {},
        yamlls = {},
        gopls = {},
        nil_ls = {},
      }
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end


      local opts = { silent = true }
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
    end
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
