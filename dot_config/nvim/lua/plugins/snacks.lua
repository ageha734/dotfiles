---@type LazySpec

return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            preset = {
                keys = {
                    { icon = " ", key = ".", desc = "This Session", action = ":lua require('resession').load(vim.fn.getcwd(), { dir = 'dirsession' })" },
                    { icon = " ", key = "l", desc = "Last Session", action = ":lua require('resession').load \"Last Session\"" },
                    { icon = " ", key = "f", desc = "Find Session", action = ":lua require('resession').load()" },
                    { icon = " ", key = "w", desc = "Find Word",    action = ":lua Snacks.dashboard.pick('live_grep')" },
                    { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
                },
                header = table.concat({
                    "            *@@@@@@@@@@%%%###***-",
                    "           .@@@@@@@@@@@@@@@@@@%-",
                    "           *@@@@@@@@@@@@@@@@*:",
                    "   ___    :@@@@@@@@@@@@@@@*:____  _____ ",
                    "  |_ _|   #@@@@@@@@@@@@@+. |___ \\|___ / ",
                    "   | | | :@@@@@@@@@@@@+._ \\  __) | |_ \\ ",
                    "   | | |_#@@@@@@@@@%=| | | |/ __/ ___) |",
                    "  |___\\__@@@@@@@@%=_||_| |_|_____|____/ ",
                    "      |_%@@@@@@%-",
                    "       =@@@@@#-",
                    "       %@@@#:",
                    "      =@@*:",
                    "      .@*.",
                    "      ..",
                }, "\n"),
            },
            sections = {
                { section = "header" },
                { section = "keys",   gap = 1, padding = 1 },
                { section = "startup" },
            },
        },
        -- Configure other snacks modules that replace previous plugins
        picker = {
            -- telescope.nvim replacement configuration
            initial_mode = "normal",
        },

        notify = {
            -- nvim-notify replacement configuration
        },

        indent = {
            -- indent-blankline.nvim replacement configuration
        },

        bufdelete = {
            -- mini.bufremove replacement configuration
        },
    },
}
