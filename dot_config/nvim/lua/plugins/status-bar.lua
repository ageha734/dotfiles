-- 参考: https://github.com/willothy/nvim-config

local separators = {
    left = "▎",
    right = "▏",
}

local groups = {
    bg = "TabLine",
    bg_active = "TabLine",
    bg_fill = "TabLineFill",
    hl_active = "TabLineSel",
}

local Space = {
    text = " ",
    truncation = { priority = 1 },
}

local Devicon = {
    text = function(buffer)
        local mappings = require("cokeline.mappings")
        if mappings.is_picking_focus() or mappings.is_picking_close() then
            return buffer.pick_letter .. " "
        end
        return buffer.devicon.icon
    end,
    fg = function(buffer)
        local mappings = require("cokeline.mappings")
        return (mappings.is_picking_focus() and "DiagnosticWarn")
            or (mappings.is_picking_close() and "DiagnosticError")
            or buffer.devicon.color
    end,
    italic = function(_)
        local mappings = require("cokeline.mappings")
        return mappings.is_picking_focus() or mappings.is_picking_close()
    end,
    bold = function(_)
        local mappings = require("cokeline.mappings")
        return mappings.is_picking_focus() or mappings.is_picking_close()
    end,
    truncation = { priority = 1 },
}

local UniquePrefix = {
    text = function(buffer)
        return buffer.unique_prefix
    end,
    fg = groups.bg_active,
    truncation = {
        priority = 3,
        direction = "left",
    },
}
local Filename = {
    text = function(buffer)
        return buffer.filename
    end,
    bold = function(buffer)
        return buffer.is_focused
    end,
    underline = function(buffer)
        return buffer.is_hovered and not buffer.is_focused
    end,
    sp = function(buffer)
        --[[ if buffer.is_focused then
          return groups.bg
        else ]]
        if buffer.diagnostics.errors ~= 0 then
            return "DiagnosticError"
        elseif buffer.diagnostics.warnings ~= 0 then
            return "DiagnosticWarn"
        elseif buffer.diagnostics.infos ~= 0 then
            return "DiagnosticInfo"
        else
            return groups.bg
        end
    end,
    fg = function(buffer)
        --[[ if buffer.is_focused then
          return groups.bg
        else ]]
        if buffer.diagnostics.errors ~= 0 then
            return "DiagnosticError"
        elseif buffer.diagnostics.warnings ~= 0 then
            return "DiagnosticWarn"
        elseif buffer.diagnostics.infos ~= 0 then
            return "DiagnosticInfo"
        else
            return buffer.is_focused and groups.bg_active or groups.bg
        end
    end,
    -- bg = groups.bg,
    truncation = {
        priority = 2,
        direction = "right",
    },
}

local function create_popup()
    local Popup = require("nui.popup")

    return Popup({
        enter = false,
        focusable = false,
        border = {
            style = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
        position = {
            row = 1,
            col = 0,
        },
        relative = "editor",
        size = {
            width = 20,
            height = 1,
        },
    })
end

local Diagnostics
Diagnostics = {
    text = function(buffer)
        return (buffer.diagnostics.errors ~= 0 and " " .. buffer.diagnostics.errors .. " ")
            or (buffer.diagnostics.warnings ~= 0 and " " .. buffer.diagnostics.warnings .. " ")
            or ""
    end,
    fg = function(buffer)
        return (buffer.diagnostics.errors ~= 0 and "DiagnosticError")
            or (buffer.diagnostics.warnings ~= 0 and "DiagnosticWarn")
            or nil
    end,
    bg = function(buffer)
        return buffer.is_focused and groups.bg_active or groups.bg
    end,
    truncation = { priority = 1 },
    on_click = function(_id, _clicks, _button, _modifiers, buffer)
        local trouble = require("trouble")
        if buffer.is_focused then
            trouble.toggle()
        elseif trouble.is_open() then
            if vim.bo.filetype == "trouble" then
                buffer:focus()
                trouble.close()
            else
                buffer:focus()
            end
        else
            buffer:focus()
            trouble.open()
        end
    end,
    on_mouse_enter = function(buffer, mouse_col)
        local text = {}
        local width = 0
        if buffer.diagnostics.errors > 0 then
            table.insert(text, {
                " " .. buffer.diagnostics.errors .. " ",
                "DiagnosticSignError",
            })
            width = width + #tostring(buffer.diagnostics.errors) + 3
        end
        if buffer.diagnostics.warnings > 0 then
            table.insert(text, {
                " " .. buffer.diagnostics.warnings .. " ",
                "DiagnosticSignWarn",
            })
            width = width + #tostring(buffer.diagnostics.warnings) + 3
        end
        if buffer.diagnostics.infos > 0 then
            table.insert(text, {
                " " .. buffer.diagnostics.infos .. " ",
                "DiagnosticSignInfo",
            })
            width = width + #tostring(buffer.diagnostics.infos) + 3
        end
        if buffer.diagnostics.hints > 0 then
            table.insert(text, {
                "󱐌 " .. buffer.diagnostics.hints .. " ",
                "DiagnosticSignpint",
            })
            width = width + #tostring(buffer.diagnostics.hints) + 3
        end
        Diagnostics.popup = Diagnostics.popup or create_popup()
        Diagnostics.popup.win_config.width = width - 1
        Diagnostics.popup.win_config.col = mouse_col - 1
        Diagnostics.popup:mount()
        if not Diagnostics.popup.bufnr then
            return
        end
        vim.api.nvim_buf_set_extmark(Diagnostics.popup.bufnr, ns, 0, 0, {
            id = 1,
            virt_text = text,
            virt_text_pos = "overlay",
        })
    end,
    on_mouse_leave = function()
        if Diagnostics.popup then
            Diagnostics.popup:unmount()
        end
    end,
}

local CloseOrUnsaved = {
    text = function(buffer)
        if buffer.is_hovered then
            return buffer.is_modified and "  " or "󰅙 "
        else
            return buffer.is_modified and "  " or "󰅖 "
        end
    end,
    fg = groups.bg,
    bold = true,
    truncation = { priority = 1 },
    on_click = function(_, _, _, _, buffer)
        buffer:delete()
    end,
}

local Padding = {
    text = function(cx)
        return cx.is_first and " " or ""
    end,
    highlight = "TabLineFill",
}

return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    always_show_tabline = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 100,
                        tabline = 100,
                        winbar = 100,
                    },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_winbar = {},
                extensions = {},
            })
        end,
    },
    {
        {
            "willothy/nvim-cokeline",
            dependencies = {
                "nvim-lua/plenary.nvim", -- Required for v0.4.0+
                "nvim-tree/nvim-web-devicons", -- If you want devicons
                "stevearc/resession.nvim", -- Optional, for persistent history
            },
            config = function()
                vim.keymap.set("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true })
                vim.keymap.set("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })

                require("cokeline").setup({
                    show_if_buffers_are_at_least = 0,
                    buffers = {
                        focus_on_delete = "next",
                        new_buffers_position = "last",
                        delete_on_right_click = false,
                    },
                    fill_hl = "TabLineFill",
                    pick = {
                        use_filename = false,
                    },
                    components = {
                        {
                            text = function(buffer)
                                return (not buffer.is_focused) and (buffer.index == 1) and " " or ""
                            end,
                        },
                        {
                            text = function(buffer)
                                return buffer.is_focused and "" or ""
                            end,
                            fg = function(buffer)
                                return buffer.is_focused and "Directory" or "#2b3243" -- TODO: use hlgroup
                            end,
                            bg = function(buffer)
                                return buffer.is_focused and groups.bg_active or groups.bg
                            end,
                        },
                        Space,
                        Devicon,
                        UniquePrefix,
                        Filename,
                        Space,
                        Diagnostics,
                        CloseOrUnsaved,
                        -- Space,
                        {
                            text = function(buffer)
                                return buffer.is_focused and "" or ""
                            end,
                            fg = function(buffer)
                                return buffer.is_focused and "Directory" or "#2b3243" -- TODO: use hlgroup
                            end,
                            bg = function(buffer)
                                return buffer.is_focused and groups.bg_active or groups.bg
                            end,
                        },
                    },
                    rhs = false,
                    mappings = {
                        disable_mouse = false,
                    },
                    tabs = {
                        placement = "right",
                    },
                })
            end,
        },
    },
}
