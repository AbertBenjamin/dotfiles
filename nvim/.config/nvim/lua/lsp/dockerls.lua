vim.lsp.config["dockerls"] = {
  cmd = {
    "docker-langserver",
    "docker-compose-langserver"
  },
  filetypes = { "docker" }
}
