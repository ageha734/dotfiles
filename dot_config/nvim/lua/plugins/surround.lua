---@type LazySpec

return {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {
        keymaps = {
            insert = false,
            insert_line = false,
            normal = ",",
            normal_cur = false,
            normal_line = false,
            normal_cur_line = false,
            visual = ",",
            visual_line = false,
            delete = "d,",
            change = "c,",
            change_line = false,
        },
        surrounds = {
            -- react fragment
            ["e"] = {
                add = { "<>", "</>" },
                find = function() return require("nvim-surround.config").get_selection { pattern = "<()>.-()</>" } end,
                delete = "^(<>)().-(</>)()$",
                change = {
                    target = "^<>()().-()</>$",
                    replacement = function() return { { "<>" }, { "</>" } } end,
                },
            },

            -- js template literal string escape
            ["j"] = {
                add = { "${", "}" },
                find = "${[%w_]+}",
                delete = "^(%${)().-()(%})$",
                change = {
                    target = "^%${().-()%}$",
                },
            },

            -- thanks: https://github.com/kylechui/nvim-surround/discussions/53#discussioncomment-10070567
            ["t"] = {
                -- add = wrap_with_abbreviation,
                add = function()
                    local input = vim.fn.input "Emmet Abbreviation: "

                    if input then
                        --- hat_tip to https://github.com/b0o/nvim-conf/blob/363e126f6ae3dff5f190680841e790467a00124d/lua/user/util/wrap.lua#L12
                        local bufnr = 0
                        local client = unpack(vim.lsp.get_clients { bufnr = bufnr, name = "emmet_language_server" })
                        if client then
                            local splitter = "BENNYSPECIALSECRETSTRING"
                            local response = client.request_sync("emmet/expandAbbreviation", {
                                abbreviation = input,
                                language = vim.opt.filetype,
                                options = {
                                    text = splitter,
                                },
                            }, 50, bufnr)
                            if response then
                                if response.err then
                                    vim.notify(response.err.message)
                                else
                                    return (vim.split(response.result, splitter))
                                end
                            end
                        end
                    end
                end,
                find = function() return require("nvim-surround.config").get_selection { motion = "at" } end,
                delete = "^(%b<>)().-(%b<>)()$",
                change = {
                    -- TODO: this is cribbed from the original impl
                    -- but doesn't yet actually call emmet
                    target = "^<([^%s<>]*)().-([^/]*)()>$",
                    replacement = function()
                        local input = vim.fn.input "New Emmet Abbreviation: "
                        if input then
                            local element = input:match "^<?([^%s>]*)"
                            local attributes = input:match "^<?[^%s>]*%s+(.-)>?$"

                            local open = attributes and element .. " " .. attributes or element
                            local close = element

                            return { { open }, { close } }
                        end
                    end,
                },
            },
        },
    },
}
