return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- calling `setup` is optional for customization
    require("fzf-lua").setup({
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", {}),
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", {})
    })
  end
}
