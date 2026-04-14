vim.pack.add({
  "https://github.com/hiphish/rainbow-delimiters.nvim",
})

vim.g.rainbow_delimiters = {
  strategy = {
    [""] = "rainbow-delimiters.strategy.global",
    vim = "rainbow-delimiters.strategy.local",
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
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
  },
}
