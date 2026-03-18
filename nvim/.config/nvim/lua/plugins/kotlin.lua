return {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
        "mason-org/mason.nvim",
        "neovim/nvim-lspconfig",
        "folke/trouble.nvim",
    },
    config = function()
        require("kotlin").setup {
            root_markers = {
                "gradlew",
                ".git",
                "mvnw",
                "settings.gradle",
            },

            -- Optional: Java Runtime to run the kotlin-lsp server itself
            -- NOT REQUIRED when using Mason (kotlin-lsp v261+ includes bundled JRE)
            -- Priority: 1. jre_path, 2. Bundled JRE (Mason), 3. System java
            --
            -- Use this if you want to run kotlin-lsp with a specific Java version
            -- Must point to JAVA_HOME (directory containing bin/java)
            -- Examples:
            --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home"
            --   Linux:   "/usr/lib/jvm/java-21-openjdk"
            --   Windows: "C:\\Program Files\\Java\\jdk-21"
            --   Env var: os.getenv("JAVA_HOME") or os.getenv("JDK21")
            jre_path = os.getenv("HOME") .. "/.sdkman/candidates/java/current",  -- SDKMAN current Java

            -- Optional: JDK for symbol resolution (analyzing your Kotlin code)
            -- This is the JDK that your project code will be analyzed against
            -- Different from jre_path (which runs the server)
            -- Required for: Analyzing JDK APIs, standard library symbols, platform types
            --
            -- Usually should match your project's target JDK version
            -- Examples:
            --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
            --   Linux:   "/usr/lib/jvm/java-17-openjdk"
            --   Windows: "C:\\Program Files\\Java\\jdk-17"
            --   SDKMAN:  os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.8-tem"
            jdk_for_symbol_resolution = os.getenv("HOME") .. "/.sdkman/candidates/java/current",  -- SDKMAN current Java

            -- Optional: Specify additional JVM arguments for the kotlin-lsp server
            jvm_args = {
                "-Xmx4g",
            },

            inlay_hints = {
                enabled = true,
                parameters = true,
                parameters_compiled = true,
                parameters_excluded = false,
                types_property = true,
                types_variable = true,
                function_return = true,
                function_parameter = true,
                lambda_return = true,
                lambda_receivers_parameters = true,
                value_ranges = true,
                kotlin_time = true,
            },
        }
    end,
}