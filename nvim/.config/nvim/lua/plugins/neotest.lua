return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "codymikol/neotest-kotlin",
    "rcasia/neotest-java",
    "marilari88/neotest-vitest"
  },
  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "mfussenegger/nvim-dap", -- for the debugger
      "rcarriga/nvim-dap-ui", -- recommended
      "theHamsta/nvim-dap-virtual-text", -- recommended
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-java")({
          -- config here
        }),
        require("neotest-kotlin")({

        }),
        require("neotest-vitest")({

        }),
      },
    })
  end
}

