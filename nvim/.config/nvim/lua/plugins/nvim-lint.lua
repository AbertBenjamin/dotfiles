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

-- Only run linters that are actually installed
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    local linters = lint._resolve_linter_by_ft(vim.bo.filetype)
    linters = vim.tbl_filter(function(name)
      local l = lint.linters[name]
      local cmd = type(l) == "table" and l.cmd or nil
      return cmd and vim.fn.executable(cmd) == 1
    end, linters)
    lint.try_lint(linters)
  end,
})
