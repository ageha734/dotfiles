---@type LazySpec
return {
    -- todo-comments: TODO/FIXME/HACK/NOTE をハイライト + telescope検索
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufReadPost",
        opts = {},
        keys = {
            { "<Leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
        },
    },

    -- trouble.nvim: diagnostics/quickfix をおしゃれに表示
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {},
        keys = {
            { "<Leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<Leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<Leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references" },
        },
    },

    -- which-key: キーバインドをリアルタイムで表示
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
        },
    },

    -- undotree: 変更履歴を視覚的にブラウズ
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = {
            { "<Leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
        },
    },

    -- oil.nvim: ファイルシステムをバッファとして編集
    {
        "stevearc/oil.nvim",
        lazy = false,
        opts = {
            view_options = {
                show_hidden = true,
            },
            float = {
                padding = 4,
                max_width = 100,
                max_height = 40,
                border = "rounded",
            },
        },
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
            { "<Leader>-", "<cmd>Oil --float<cr>", desc = "Open directory (float)" },
        },
    },

    -- render-markdown: markdownをターミナル内でリッチに表示
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = "markdown",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
    },

    -- flash.nvim: 高速カーソルジャンプ (leap代替・より高機能)
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        },
    },
}
