---@type LazySpec
return {
    -- octo.nvim: GitHub Issue/PR をnvim内で操作
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {},
        keys = {
            { "<Leader>gi", "<cmd>Octo issue list<cr>", desc = "GitHub Issues" },
            { "<Leader>gp", "<cmd>Octo pr list<cr>", desc = "GitHub PRs" },
            { "<Leader>gr", "<cmd>Octo review start<cr>", desc = "Start PR review" },
        },
    },

    -- nvim-spectre: プロジェクト全体の検索＆置換
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<Leader>sr", function() require("spectre").open() end, desc = "Search & Replace (Spectre)" },
            { "<Leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Replace current word" },
        },
    },


    -- rest.nvim: HTTPリクエストをnvim内で実行 (.http ファイル)
    {
        "rest-nvim/rest.nvim",
        ft = "http",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<Leader>rr", "<cmd>Rest run<cr>", ft = "http", desc = "Run HTTP request" },
            { "<Leader>rl", "<cmd>Rest run last<cr>", ft = "http", desc = "Re-run last request" },
        },
    },

    -- neotest: テストをnvim内で実行・結果表示
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-python",
        },
        keys = {
            { "<Leader>tn", function() require("neotest").run.run() end, desc = "Run nearest test" },
            { "<Leader>tF", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
            { "<Leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
            { "<Leader>to", function() require("neotest").output_panel.toggle() end, desc = "Test output" },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-go"),
                    require("neotest-python"),
                },
            })
        end,
    },

    -- kulala.nvim 代替として .env 読み込み支援
    {
        "laytan/cloak.nvim",
        event = "BufReadPre",
        opts = {
            patterns = {
                { file_pattern = { ".env*", "*.env" }, cloak_pattern = "=.+", replace = "= ****" },
            },
        },
    },

    -- mini.files: 軽量ファイルマネージャ (oil.nvimと使い分け)
    {
        "echasnovski/mini.files",
        keys = {
            { "<Leader>fm", function() require("mini.files").open(vim.api.nvim_buf_get_name(0)) end, desc = "Mini Files (current)" },
        },
        opts = {
            windows = { preview = true, width_preview = 50 },
        },
    },

    -- zen-mode: 集中モード
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        keys = {
            { "<Leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
        },
        opts = {
            window = { width = 120 },
        },
    },
}
