vim.pack.add({
  "https://github.com/rafamadriz/friendly-snippets",
  -- release tag so the prebuilt fuzzy matcher binary is downloaded
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
  },
  completion = {
    menu = { border = "none" },
    list = { selection = { preselect = false, auto_insert = true } },
    documentation = { auto_show = true, window = { border = "none" } },
  },
  signature = { enabled = true, window = { border = "none" } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
