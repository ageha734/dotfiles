---@type LazySpec
return {
    -- Claude Code: toggleterm経由でポップアップ起動
    {
        "akinsho/toggleterm.nvim",
        keys = {
            {
                "<Leader>ac",
                function()
                    local Terminal = require("toggleterm.terminal").Terminal
                    local claude = Terminal:new({
                        cmd = "claude",
                        direction = "float",
                        float_opts = { border = "rounded", width = math.floor(vim.o.columns * 0.9), height = math.floor(vim.o.lines * 0.85) },
                        close_on_exit = true,
                    })
                    claude:toggle()
                end,
                desc = "Claude Code",
            },
            {
                "<Leader>ar",
                function()
                    local Terminal = require("toggleterm.terminal").Terminal
                    local redis = Terminal:new({
                        cmd = "redis-cli",
                        direction = "float",
                        float_opts = { border = "rounded", width = math.floor(vim.o.columns * 0.8), height = math.floor(vim.o.lines * 0.7) },
                        close_on_exit = true,
                    })
                    redis:toggle()
                end,
                desc = "Redis CLI",
            },
        },
    },

    -- CodeCompanion: AI補完をnvim内で使う (Claude API直接)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
        keys = {
            { "<Leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat" },
            { "<Leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
            { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to AI chat" },
        },
        opts = {
            strategies = {
                chat = { adapter = "anthropic" },
                inline = { adapter = "anthropic" },
            },
            adapters = {
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        schema = {
                            model = { default = "claude-sonnet-4-20250514" },
                        },
                    })
                end,
            },
            display = {
                chat = {
                    window = {
                        layout = "vertical",
                        width = 0.4,
                    },
                },
            },
        },
    },
}
