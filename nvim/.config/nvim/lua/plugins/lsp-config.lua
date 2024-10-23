return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "java_language_server",
          "jdtls",
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
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.kotlin_language_server.setup({
        capabilities = capabilities,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim"
    },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          require("none-ls.diagnostics.eslint")
        },
      })
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completion source
      "hrsh7th/cmp-buffer",   -- Buffer completion source
      "hrsh7th/cmp-path",     -- File path completion
      "hrsh7th/cmp-cmdline",  -- Command line completions
      "hrsh7th/vim-vsnip",    -- Snippet engine
      "hrsh7th/cmp-vsnip"     -- Snippet completion source
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- Use vsnip as snippet engine
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept current completion
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP source
          { name = "vsnip" },     -- Snippet source
          { name = "buffer" },    -- Buffer source
          { name = "path" },      -- Path source
        }),
        completion = {
          autocomplete = false
        },
        performance = {
          debounce = 100,
        }
      })
    end
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup({
        bind = true,
        hint_enable = true,  -- Enable virtual text hints like in IntelliJ
        hint_prefix = "🐍 ",  -- Optional: Custom hint icon
        handler_opts = {
          border = "rounded", -- Rounded border for the popup
        },
        floating_window = true, -- Show signatures in a floating window
        floating_window_above_cur_line = true,  -- Align the floating window above the current line
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        auto_open = false,       -- Do not auto-open trouble when errors are detected
        auto_close = true,       -- Auto-close when the trouble list is empty
        use_diagnostic_signs = true -- Use LSP diagnostic signs
      })
    end,
  }


}
