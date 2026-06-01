---@type LazySpec

return {
    { "danilamihailov/beacon.nvim" },
    {
        "sphamba/smear-cursor.nvim",
        opts = {},
    },
    {
        "rachartier/tiny-glimmer.nvim",
        config = function()
            require("tiny-glimmer").setup({
                enabled = true,
            })
        end,
    },
}
