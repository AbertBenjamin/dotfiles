return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-context" },
    config = function()
      require("nvim-treesitter").install({
        "lua",
        "kotlin",
        "java",
        "javascript",
        "toml",
        "json",
        "bash",
        "c",
        "dockerfile",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "vim",
        "vimdoc",
        "properties",
        "query",
        "tmux",
        "css",
        "html",
        "sql",
        "markdown",
        "markdown_inline",
        "typescript",
        "xml",
        "go",
        "yaml",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "inner",
      mode = "cursor",
    },
  }
}
