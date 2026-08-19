local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/intellij-server"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local cache_dir = vim.fn.expand("~/.cache/kotlin-lsp-workspaces/" .. project_name)

-- Decompiler for jar:// and jrt:// URIs (go-to-definition into compiled classes)
local function decompile(uri)
  local clients = vim.lsp.get_clients({ name = "kotlin_lsp" })
  if #clients == 0 then return end

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].modifiable = true
  vim.bo[buf].swapfile = false
  vim.bo[buf].buftype = "nofile"

  local done = false
  clients[1]:request("workspace/executeCommand", {
    command = "decompile",
    arguments = { uri },
  }, function(err, result)
    if err or not result then return end
    local normalized = string.gsub(result.code, "\r\n", "\n")
    local lines = vim.split(normalized, "\n", { plain = true })
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      if result.language then
        vim.bo[buf].filetype = result.language:lower()
      end
      vim.bo[buf].modifiable = false
      done = true
    end)
  end, buf)

  vim.wait(5000, function() return done end)
end

local augroup = vim.api.nvim_create_augroup("KotlinDecompile", { clear = true })
for _, protocol in ipairs({ "jar", "jrt" }) do
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = protocol .. "://*",
    group = augroup,
    callback = function()
      decompile(vim.fn.expand("<amatch>"))
    end,
  })
end

return {
  cmd = { mason_bin, "--stdio", "--system-path=" .. cache_dir },
  filetypes = { "kotlin" },
  root_markers = { "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", "pom.xml", "mvnw", "gradlew" },
  settings = {
    ["jetbrains.kotlin.hints.parameters"] = true,
    ["jetbrains.kotlin.hints.parameters.compiled"] = true,
    ["jetbrains.kotlin.hints.parameters.excluded"] = false,
    ["jetbrains.kotlin.hints.settings.types.property"] = true,
    ["jetbrains.kotlin.hints.settings.types.variable"] = true,
    ["jetbrains.kotlin.hints.type.function.return"] = true,
    ["jetbrains.kotlin.hints.type.function.parameter"] = true,
    ["jetbrains.kotlin.hints.settings.lambda.return"] = true,
    ["jetbrains.kotlin.hints.lambda.receivers.parameters"] = true,
    ["jetbrains.kotlin.hints.settings.value.ranges"] = true,
    ["jetbrains.kotlin.hints.value.kotlin.time"] = true,
  },
  init_options = {
    defaultJdk = os.getenv("HOME") .. "/.sdkman/candidates/java/current",
  },
  capabilities = {
    textDocument = {
      inlayHint = {
        dynamicRegistration = true,
      },
    },
  },
  handlers = {
    ["workspace/configuration"] = function(_, params, ctx)
      local result = {}
      local settings = {
        ["jetbrains.kotlin"] = {
          hints = {
            parameters = true,
            ["parameters.compiled"] = true,
            ["parameters.excluded"] = false,
            settings = {
              types = { property = true, variable = true },
              lambda = { ["return"] = true },
              value = { ranges = true },
            },
            type = {
              ["function"] = { ["return"] = true, parameter = true },
            },
            lambda = {
              receivers = { parameters = true },
            },
            value = {
              kotlin = { time = true },
            },
          },
        },
      }
      for _, item in ipairs(params.items or {}) do
        if item.section and settings[item.section] then
          table.insert(result, settings[item.section])
        else
          table.insert(result, vim.NIL)
        end
      end
      return result
    end,
  },
}
