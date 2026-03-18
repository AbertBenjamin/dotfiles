return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      kotlin = { "ktlint" },
      lua = { "stylua" },
      -- add others as needed
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,  -- falls back to LSP formatting if no formatter found
    },
  },
}
