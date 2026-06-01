---@type LazySpec

vim.opt.conceallevel = 1

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    event = {
        "BufReadPre ~/Workspace/obsidian/**/*.md",
        "BufReadPre ~/Workspace/obsidian/**/*.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config.ClientOpts
    opts = {
        workspaces = {
            {
                name = "works",
                path = "~/Workspace/obsidian/works/",
            },
        },
        mappings = {
            ["gd"] = {
                action = function()
                    if require("obsidian").util.cursor_on_markdown_link() then
                        return "<cmd>ObsidianFollowLink<CR>"
                    else
                        return "gd"
                    end
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
        },
        completion = {
            nvim_cmp = false,
        },
        picker = {
            name = "telescope.nvim",
            note_mappings = {
                new = "<C-x>",
                insert_link = "<C-l>",
            },
            tag_mappings = {
                tag_note = "<C-x>",
                insert_tag = "<C-l>",
            },
        },
    },
}
