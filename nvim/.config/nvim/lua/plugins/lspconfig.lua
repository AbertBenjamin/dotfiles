return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          check_outdated_packages_on_open = true,
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        }
      })
    end
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
  }
}
