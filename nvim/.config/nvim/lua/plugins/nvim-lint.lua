vim.pack.add({
  "https://github.com/mfussenegger/nvim-lint",
})

local lint = require("lint")
if lint.linters.detekt then
  lint.linters.detekt.args = {
    "--config", "config/detekt/detekt.yml",
    "--input",
  }
  lint.linters_by_ft = {
    kotlin = { "detekt" },
  }
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
