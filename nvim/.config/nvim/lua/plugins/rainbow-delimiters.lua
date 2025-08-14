return {
  {
    "hiphish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = "rainbow-delimiters.strategy.global",
          vim = "rainbow-delimiters.strategy.local"
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks"
        },
        highlight = {
          "RainBowDelimiterYellow",
          "RainBowDelimiterGreen",
          "RainBowDelimiterBlue",
          "RainBowDelimiterViolet",
          "RainBowDelimiterYellow",
          "RainBowDelimiterGreen",
          "RainBowDelimiterBlue",
          "RainBowDelimiterViolet",
        }
      }
    end
  }
}

