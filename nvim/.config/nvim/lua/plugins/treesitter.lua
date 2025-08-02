return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-context" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        trim_scope = "inner",
        mode = "cursor",
      })

      local config = require("nvim-treesitter.configs")
      config.setup({
        ensure_installed = {
          "lua",
          "javascript",
          "kotlin",
          "java",
          "javascript",
          "toml",
          "json",
          "bash",
          "css",
          "html",
          "sql",
          "markdown",
          "typescript",
          "xml",
          "go",
          "yaml",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
