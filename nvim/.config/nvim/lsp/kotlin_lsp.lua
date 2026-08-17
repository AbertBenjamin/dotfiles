-- ponytail: mason's "kotlin-lsp" package installs the binary as `intellij-server`
return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/intellij-server", "--stdio" },
  filetypes = { "kotlin" },
  root_markers = {
    "settings.gradle.kts",
    "settings.gradle",
    "build.gradle.kts",
    "build.gradle",
    "pom.xml",
    "gradlew",
    "mvnw",
    ".git",
  },
}
