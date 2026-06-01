---@type LazySpec

return {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
        -- change colorscheme
        colorscheme = "catppuccin-mocha",
        -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
        highlights = {
            init = { -- this table overrides highlights in all themes
                -- Normal = { bg = "#000000" },
            },
            astrotheme = { -- a table of overrides/changes when applying the astrotheme theme
                -- Normal = { bg = "#000000" },
            },
        },
        -- configure the new folding module
        folding = {
            -- enable the folding module
            enabled = true,
            -- configure which folding methods to use
            methods = {
                treesitter = true, -- use treesitter based folding
                indent = true,     -- use indent based folding as fallback
                lsp = true,        -- use lsp folding (Neovim v0.11+ only)
            },
        },
        -- configure status providers and components
        status = {
            providers = {
                lsp_client_names = {
                    mappings = {
                        -- display `lua_ls` as just `LUA` in the statusline
                        lua_ls = "LUA",
                        -- display `tsserver` as just `TS` in the statusline
                        tsserver = "TS",
                        -- display `gopls` as just `GO` in the statusline
                        gopls = "GO",
                        -- display `rust_analyzer` as just `RS` in the statusline
                        rust_analyzer = "RS",
                    },
                },
            },
        },
        -- Icons can be configured throughout the interface
        icons = {
            -- configure the loading of the lsp in the status line
            LSPLoading1 = "⠋",
            LSPLoading2 = "⠙",
            LSPLoading3 = "⠹",
            LSPLoading4 = "⠸",
            LSPLoading5 = "⠼",
            LSPLoading6 = "⠴",
            LSPLoading7 = "⠦",
            LSPLoading8 = "⠧",
            LSPLoading9 = "⠇",
            LSPLoading10 = "⠏",
        },
    },
}
