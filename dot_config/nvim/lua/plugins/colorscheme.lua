---@type LazySpec

return {
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = true,
            })
            vim.cmd("colorscheme tokyonight")
        end,
    },
}
