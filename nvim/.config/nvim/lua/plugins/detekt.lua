return {
  "nielsdekker/detekt.nvim",
  config = function()
    require("detekt").setup({
      config_names = { "detekt-config.yml" },
      file_pattern = { "*.kt" },
    })
  end
}
