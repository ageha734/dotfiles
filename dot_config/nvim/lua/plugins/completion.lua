---@type LazySpec

return {
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",
        opts = {
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
                ["<C-n>"] = { "select_next", "fallback_to_mappings" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-h>"] = { "hide", "fallback" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                list = { selection = { preselect = false } },
                menu = {
                    border = "rounded",
                    draw = {
                        columns = {
                            {
                                "kind_icon",
                                "label",
                                gap = 1,
                            },
                            {
                                "label_description",
                            },
                        },
                    },
                },
                documentation = {
                    auto_show = true,

                    window = { border = "rounded" },
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            signature = { enabled = true },
        },
        opts_extend = { "sources.default" },
    },
}
