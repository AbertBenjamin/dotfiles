vim.pack.add({
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/antoinemadec/FixCursorHold.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/codymikol/neotest-kotlin",
  "https://github.com/rcasia/neotest-java",
  "https://github.com/marilari88/neotest-vitest",
  "https://github.com/mfussenegger/nvim-jdtls",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
})

require("neotest").setup({
  adapters = {
    require("neotest-java"),
    require("neotest-kotlin"),
    require("neotest-vitest"),
  },
})
