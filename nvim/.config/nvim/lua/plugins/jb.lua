return 
-- {
--         "nickkadutskyi/jb.nvim",
--         lazy = false,
--         priority = 1000,
--         opts = {},
--         config = function()
--             require("jb").setup({
--                 transparent = true
--             })
--             vim.cmd("colorscheme jb")
--         end,
--     },
    {
        "xiantang/darcula-dark.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("darcula").setup({
                transparent = true,
            })
            vim.cmd.colorscheme("darcula-dark")
        end,
    }
