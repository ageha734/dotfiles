---@type LazySpec

return {
    "stevearc/conform.nvim",
    config = function()
        -- define vim command FormatEnable
        vim.cmd([[
      command! FormatOnSaveEnable lua require('conform').enable()
    ]])
        -- define vim command FormatDisable
        vim.cmd([[
      command! FormatOnSaveDisable lua require('conform').disable()
    ]])

        require("conform").setup({
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                lua = { "stylua" },
                go = { "goimports", "gofmt" },
                rust = { "rustfmt", lsp_format = "fallback" },
            },
        })
    end,
}
