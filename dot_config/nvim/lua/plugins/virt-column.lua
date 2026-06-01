---@type LazySpec

return {
    "lukas-reineke/virt-column.nvim",
    event = "BufEnter",
    config = function()
        vim.cmd "set colorcolumn=80"
        require("virt-column").setup()
    end,
}
