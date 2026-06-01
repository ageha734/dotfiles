---@type LazySpec

return {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    config = {
        filter = {
            fzf = {
                extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
            },
        },
    },
}
