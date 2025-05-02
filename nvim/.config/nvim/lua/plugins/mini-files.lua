return {
    'echasnovski/mini.files',
    version = '*',
    config = function()
        require('mini.files').setup({
            options = {
                use_as_default_explorer = true
            },
            windows = {
                preview = true,
                width_preview = 50
            }
        })
        vim.keymap.set(
            "n", "<leader>cd", function()
                require("mini.files").open()
            end
        )
    end
}
