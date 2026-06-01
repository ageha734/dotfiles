---@type LazySpec

return {
    "vyfor/cord.nvim",
    build = "./build",
    event = "VeryLazy",
    opts = {
        editor = {
            client = "astronvim",
            tooltip = "Better than VSCode",
        },
        buttons = {
            { label = "My Github", url = "https://github.com/iyxan23" },
        },
    },
}
