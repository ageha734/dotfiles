---@type LazySpec

return {
    "folke/drop.nvim",
    event = "VeryLazy",
    config = function()
        require("drop").setup {
            theme = "stars",
            max = 10,
        }
    end,
}
