return {
  "mfussenegger/nvim-lint",
  event = "BufReadPre",
  config = function()
    local lint = require("lint")
    local detekt = lint.linters.detekt
    detekt.args = {
      "--config", "config/detekt/detekt.yml",
      "--input"
    }

    lint.linters_by_ft = {
      kotlin = { "detekt" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
