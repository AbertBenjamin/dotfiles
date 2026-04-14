vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
})

require("nvim-treesitter").install({
  "lua", "kotlin", "java", "javascript", "toml", "json", "bash", "c",
  "dockerfile", "gitattributes", "gitcommit", "gitignore", "vim", "vimdoc",
  "properties", "query", "tmux", "css", "html", "sql", "markdown",
  "markdown_inline", "typescript", "xml", "go", "yaml",
})

-- Enable treesitter highlighting for all buffers with a parser
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.bo.syntax = ""
    end
  end,
})

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  trim_scope = "inner",
  mode = "cursor",
})
