require "lsp.gopls"
require "lsp.luals"
require "lsp.bashls"
require "lsp.dockerls"
require "lsp.jsonls"
require "lsp.yamlls"
require "lsp.ts_ls"
require "lsp.javals"
require "lsp.kotlinls"
require "lsp.nills"

local M = {}

function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Merge Blink cmp capabilities
  capabilities = vim.tbl_deep_extend(
    "force",
    capabilities,
    require("blink.cmp").get_lsp_capabilities({}, false)
  )

  -- Add folding capability
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
    }
  })

  return capabilities
end

return M

