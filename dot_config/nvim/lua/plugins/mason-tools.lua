---@type LazySpec

return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
        ensure_installed = {
            -- LSP servers (converted from lua_ls to lua-language-server format)
            "lua-language-server",
            "gopls",
            "rust-analyzer",
            "typescript-language-server",

            -- Formatters/Linters (from mason-null-ls)
            "prettierd",
            "stylua",

            -- DAP configurations (from mason-nvim-dap)
            "delve", -- for Go debugging
        },

        -- Additional mason-tool-installer options
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,  -- 3 second delay
        debounce_hours = 24, -- at most check for outdated packages once a day
    },
}
