return {
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
		ensure_installed = { "ktlint" },
	},
	-- {
	--   'nvim-java/nvim-java',
	--   dependencies = { "williamboman/mason.nvim" },
	--   config = function()
	--     require("java").setup({})
	--   end
	-- },
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"java_language_server",
					"bashls",
					"docker_compose_language_service",
					"dockerls",
					"eslint",
					"jsonls",
					"kotlin_language_server",
					"lemminx",
					"lua_ls",
					"ts_ls",
					"yamlls",
					"gopls",
					"nil_ls",
					"stylua",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			local opts = { silent = true }
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})

			lspconfig.stylua.setup({ capabilities = capabilities })
			lspconfig.nil_ls.setup({ capabilities = capabilities })
			lspconfig.gopls.setup({ capabilities = capabilities })
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			lspconfig.java_language_server.setup({
				jdk = { auto_install = false },
			})
			lspconfig.kotlin_language_server.setup({
				capabilities = capabilities,
				-- on_attach = on_attach,
				settings = {
					kotlin = {
						codegen = { enabled = true },
						compiler = { jvm = { target = "21" } },
						completion = { snippets = { enabled = true }, smart = true },
						diagnostics = { enabled = true, level = "Hint", debounceTime = 250 },
						indexing = { enabled = true },
					},
				},
				root_dir = function(fname)
					return lspconfig.util.root_pattern(".git", ".idea", "pom.xml")(fname) or vim.fn.getcwd()
				end,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			-- lspconfig.eslint.setup({
			--   capabilities = capabilities,
			--   on_attach = on_attach
			--
			-- })
			lspconfig.bashls.setup({ capabilities = capabilities, on_attach = on_attach })
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.formatting.ktlint,
					null_ls.builtins.formatting.google_java_format,
					require("none-ls.diagnostics.eslint"),
				},
			})
			vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completion source
			"hrsh7th/cmp-buffer", -- Buffer completion source
			"hrsh7th/cmp-path", -- File path completion
			"hrsh7th/cmp-cmdline", -- Command line completions
			"hrsh7th/vim-vsnip", -- Snippet engine
			"hrsh7th/cmp-vsnip", -- Snippet completion source
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body) -- Use vsnip as snippet engine
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<Right>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept current completion
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						-- Ensure LSP and buffer sources appear before others
						function(entry1, entry2)
							local order = { nvim_lsp = 1, buffer = 2, path = 3 }
							local source1 = entry1.source.name
							local source2 = entry2.source.name
							if order[source1] and order[source2] then
								return order[source1] < order[source2]
							end
						end,
					},
				},

				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 }, -- LSP source
					{ name = "vsnip", priority = 750 }, -- Snippet source
					{ name = "buffer", priority = 500 }, -- Buffer source
					{ name = "path", priority = 250 }, -- Path source
				}),
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							vsnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				performance = {
					debounce = 100,
				},
			})
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				hint_enable = true, -- Enable virtual text hints like in IntelliJ
				hint_prefix = "🐍 ", -- Optional: Custom hint icon
				handler_opts = {
					border = "rounded", -- Rounded border for the popup
				},
				floating_window = true, -- Show signatures in a floating window
				floating_window_above_cur_line = true, -- Align the floating window above the current line
			})
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				auto_open = false, -- Do not auto-open trouble when errors are detected
				auto_close = true, -- Auto-close when the trouble list is empty
				use_diagnostic_signs = true, -- Use LSP diagnostic signs
			})
		end,
	},
}
