---@type LazySpec

return {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
        -- Configure core features of AstroNvim
        features = {
            autopairs = true,                                             -- enable autopairs at start
            cmp = true,                                                   -- enable completion at start
            diagnostics = { virtual_text = true, virtual_lines = false }, -- new format for diagnostics configuration
            notifications = true,                                         -- enable notifications at start
        },
        -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
        diagnostics = {
            virtual_text = true,
            underline = true,
        },
        -- vim options can be configured here
        options = {
            opt = { -- vim.opt.<key>
                relativenumber = true,
                number = true,
                spell = false,
                signcolumn = "yes",
                wrap = false,
                showtabline = 0,
                scrolloff = 3,
            },

            g = {
                neovide_transparency = 0.8,
                vimtex_view_method = "zathura",
            },
        },
        -- Mappings can be configured through AstroCore as well.
        -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
        mappings = {
            -- first key is the mode
            n = {
                -- second key is the lefthand side of the map
                -- navigate buffer tabs with `H` and `L`
                -- L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
                -- H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

                -- mappings seen under group name "Buffer"
                -- ["<Leader>bD"] = {
                --   function()
                --     require("astroui.status.heirline").buffer_picker(
                --       function(bufnr) require("astrocore.buffer").close(bufnr) end
                --     )
                --   end,
                --   desc = "Pick to close",
                -- },
                -- tables with just a `desc` key will be registered with which-key if it's installed
                -- this is useful for naming menus
                -- ["<Leader>b"] = { desc = "Buffers" },
                -- quick save
                -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
                --
                -- replaced by the awesome leap.nvim plugin
                -- ["<Leader><Leader>w"] = {
                --   function() vim.cmd.HopWord() end,
                --   desc = "Hop Words",
                -- },
                -- ["<Leader>k"] = {
                --   function() vim.cmd.HopLine() end,
                --   desc = "Hop Lines",
                -- },
                ["<S-J>"] = {
                    "O<esc>o",
                },

                ["<Leader>fW"] = {
                    function()
                        require("telescope.builtin").live_grep {
                            grep_open_files = true,
                        }
                    end,
                    desc = "Live-grep words in open buffers",
                },

                ["<S-L>"] = { "$" },
                ["<S-H>"] = { "^" },

                ["<Leader>j"] = {
                    "<cmd>HopLineStart<cr>",
                    desc = "Hop start lines",
                },
                ["<Leader>J"] = {
                    "<cmd>HopLine<cr>",
                    desc = "Hop lines",
                },

                ["<Leader>c"] = {
                    function()
                        local bufs = vim.fn.getbufinfo { buflisted = 1 }
                        require("astrocore.buffer").close(vim.api.nvim_get_current_buf())
                        if require("astrocore").is_available "snacks.nvim" and not bufs[2] then
                            require(
                                "snacks.dashboard").open()
                        end
                    end,
                    desc = "Close buffer",
                },
                ["<Leader>bc"] = {
                    function()
                        require("astroui.status.heirline").buffer_picker(function(bufnr)
                            local bufs = vim.fn.getbufinfo { buflisted = 1 }
                            require("astrocore.buffer").close(bufnr)
                            if require("astrocore").is_available "snacks.nvim" and not bufs[2] then
                                require(
                                    "snacks.dashboard").open()
                            end
                        end)
                    end,
                    desc = "Close buffer from tabline",
                },
                ["<Leader>bC"] = {
                    function()
                        for _, bufnr in ipairs(vim.t.bufs) do
                            -- check if it's a buffer that doesn't have a window open
                            if vim.fn.empty(vim.fn.win_findbuf(bufnr)) == 1 then require("astrocore.buffer").close(bufnr) end
                        end
                    end,
                    desc = "Close all inactive buffers",
                },
                ["<Leader>bd"] = nil,

                ["<Leader>bz"] = {
                    desc = "Weird stuff",
                },

                ["<Leader>bzr"] = {
                    "<cmd>CellularAutomaton make_it_rain<cr>",
                    desc = "Make it rain!",
                },
                ["<Leader>bzg"] = {
                    "<cmd>CellularAutomaton game_of_life<cr>",
                    desc = "Game of life",
                },
                ["<Leader>bzs"] = {
                    "<cmd>CellularAutomaton scramble<cr>",
                    desc = "Scramble",
                },

                ["<Leader>tf"] = {
                    "<cmd>ToggleTerm 1 direction=float name=first<cr>",
                    desc = "ToggleTerm first terminal float",
                },
                ["<Leader>th"] = {
                    "<cmd>ToggleTerm 1 size=10 direction=horizontal name=first<cr>",
                    desc = "ToggleTerm first terminal horizontal split",
                },
                ["<Leader>tv"] = {
                    "<cmd>ToggleTerm 1 size=80 direction=vertical name=first<cr>",
                    desc = "ToggleTerm first terminal vertical split",
                },

                ["<Leader>t2f"] = {
                    "<cmd>ToggleTerm 2 direction=float name=second<cr>",
                    desc = "ToggleTerm second terminal float",
                },
                ["<Leader>t2h"] = {
                    "<cmd>ToggleTerm 2 size=10 direction=horizontal name=second<cr>",
                    desc = "ToggleTerm second terminal horizontal split",
                },
                ["<Leader>t2v"] = {
                    "<cmd>ToggleTerm 2 size=80 direction=vertical name=second<cr>",
                    desc = "ToggleTerm second terminal vertical split",
                },

                ["<Leader>t3f"] = {
                    "<cmd>ToggleTerm 3 direction=float name=third<cr>",
                    desc = "ToggleTerm third terminal float",
                },
                ["<Leader>t3h"] = {
                    "<cmd>ToggleTerm 3 size=10 direction=horizontal name=third<cr>",
                    desc = "ToggleTerm third terminal horizontal split",
                },
                ["<Leader>t3v"] = {
                    "<cmd>ToggleTerm 3 size=80 direction=vertical name=third<cr>",
                    desc = "ToggleTerm third terminal vertical split",
                },

                ["<Leader>fo"] = {
                    function() require("telescope.builtin").oldfiles { cwd_only = true } end,
                    desc = "Find history (cwd only)",
                },
                ["<Leader>fi"] = {
                    function() require("telescope.builtin").oldfiles() end,
                    desc = "Find history (everywhere)",
                },

                ["<Leader>bt"] = {
                    "<cmd>if winnr('$') != 1 <Bar> tab split <Bar> endif<CR>",
                    desc = "Something like a fullscreen mode",
                },

                ["<C-c>"] = { "xi<Enter><Esc>" },
            },
            t = {
                -- setting a mapping to false will disable it
                -- ["<esc>"] = false,
            },
            v = {
                -- ["<Leader><Leader>w"] = {
                --   function() require('hop').hint_words { extend_visual = true } end,
                --   desc = "Hop Words",
                -- },
                -- ["<Leader>k"] = {
                --   function() require("hop").hint_lines { extend_visual = true } end,
                --   desc = "Hop Lines",
                -- },
                ["<Leader>j"] = {
                    "<cmd>HopLineStart<cr>",
                    desc = "Hop start lines",
                },
                ["<Leader>J"] = {
                    "<cmd>HopLine<cr>",
                    desc = "Hop lines",
                },

                ["<S-L>"] = { "$" },
                ["<S-H>"] = { "^" },
            },
            i = {
                ["<C-e>"] = { "<esc><C-e>a", desc = "Go down one line" },
                ["<C-y>"] = { "<esc><C-y>a", desc = "Go up one line" },
                ["<C-d>"] = { "<esc><C-d>a", desc = "Go down half a screen" },
                ["<C-u>"] = { "<esc><C-u>a", desc = "Go up half a screen" },

                ["<C-h>"] = { "<Left>" },
                ["<C-j>"] = { "<Down>" },
                ["<C-k>"] = { "<Up>" },
                ["<C-l>"] = { "<Right>" },

                ["<C-b>"] = {
                    "<C-o>~<Left>",
                    desc = "Flip the next character's case without leaving insert mode",
                },
            },
        },
    },
}
