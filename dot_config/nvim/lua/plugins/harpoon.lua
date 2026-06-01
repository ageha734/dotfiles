---@type LazySpec

return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            { "AstroNvim/astroui", opts = { icons = { Harpoon = "󱡀" } } },
            {
                "AstroNvim/astrocore",
                opts = function(_, opts)
                    local maps = opts.mappings
                    local prefix = "<Leader>"

                    maps.n[prefix .. "a"] = {
                        function() require("harpoon"):list():add() end,
                        desc =
                        "Add file to harpoon"
                    }
                    maps.n[prefix .. "k"] = {
                        function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
                        desc = "Toggle quick menu",
                    }
                    maps.n["<C-p>"] = { function() require("harpoon"):list():prev() end, desc = "Goto previous mark" }
                    maps.n["<C-n>"] = { function() require("harpoon"):list():next() end, desc = "Goto next mark" }
                    maps.n[prefix .. "m"] = { "<Cmd>Telescope harpoon marks<CR>", desc = "Show marks in Telescope" }
                    maps.n[prefix .. "1"] = {
                        function()
                            require("harpoon"):list():select(1)
                        end,
                        desc = "Goto Harpoon mark 1",
                    }
                    maps.n[prefix .. "2"] = {
                        function()
                            require("harpoon"):list():select(2)
                        end,
                        desc = "Goto Harpoon mark 2",
                    }
                    maps.n[prefix .. "3"] = {
                        function()
                            require("harpoon"):list():select(3)
                        end,
                        desc = "Goto Harpoon mark 3",
                    }
                    maps.n[prefix .. "4"] = {
                        function()
                            require("harpoon"):list():select(4)
                        end,
                        desc = "Goto Harpoon mark 4",
                    }
                    maps.n[prefix .. "5"] = {
                        function()
                            require("harpoon"):list():select(5)
                        end,
                        desc = "Goto Harpoon mark 5",
                    }
                end,
            },
        },
    },
    {
        "catppuccin/nvim",
        optional = true,
        ---@type CatppuccinOptions
        opts = { integrations = { harpoon = true } },
    },
}
