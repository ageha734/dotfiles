---@type LazySpec

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = {
        "TSUpdate",
        "TSEnable",
        "TSToggle",
        "TSDisable",
        "TSInstall",
        "TSBufEnable",
        "TSBufToggle",
        "TSEditQuery",
        "TSUninstall",
        "TSBufDisable",
        "TSConfigInfo",
        "TSModuleInfo",
        "TSUpdateSync",
        "TSInstallInfo",
        "TSInstallSync",
        "TSInstallFromGrammar",
    },
    main = "nvim-treesitter.configs",

    opts = function(_, opts)
        -- add more things to the ensure_installed table protecting against community packs modifying it
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
            "lua",
            "vim",
            'toml',
            "typescript",
            "rust",
            "html",
            "go",
            "gomod",
            "gosum",
            "gowork",
            "bibtex",
            "c",
            "cpp",
            "java",
            "json",
            "latex",
            "markdown",
            "vimdoc",
            "zig",
        })

        -- NOTE:
        -- The highlight in command window broken.
        -- See: https://github.com/neovim/neovim/issues/26346
        opts.highlight = {
            enable = true,
        }

        -- Enable this for fixing indentation at some language.
        -- reference: https://zenn.dev/uga_rosa/articles/9eb5063f8f9b75
        opts.indent = {
            enable = true,
        }
    end,
}
