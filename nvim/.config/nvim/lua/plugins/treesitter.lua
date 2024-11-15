return {
  {
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()

    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "lua", "javascript", "kotlin", "java", "javascript", "toml",
        "json", "bash", "css", "html", "sql", "markdown", "typescript", "xml" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true }
    })
    end
  }
}
