---@type LazySpec

return {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
        local status = require "astroui.status"

        opts.statusline = { -- statusline
            hl = { fg = "fg", bg = "bg" },
            status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
            status.component.git_branch(),
            status.component.file_info(),
            status.component.git_diff(),
            status.component.diagnostics(),
            status.component.fill(),
            status.component.cmd_info(),
            status.component.fill(),
            status.component.lsp(),
            status.component.treesitter(),
            status.component.nav(),
            -- Create a custom component to display the time
            status.component.builder {
                {
                    provider = function()
                        local time = os.date "%H:%M" -- show hour and minute in 24 hour format
                        ---@cast time string
                        return status.utils.stylize(time, {
                            padding = { right = 1, left = 1 }, -- pad the right side so it's not cramped
                        })
                    end,
                },
                update = { -- update should happen when the mode has changed as well as when the time has changed
                    "User", -- We can use the User autocmd event space to tell the component when to update
                    "ModeChanged",
                    callback = vim.schedule_wrap(function(_, args)
                        if -- update on user UpdateTime event and mode change
                            (args.event == "User" and args.match == "UpdateTime")
                            or (args.event == "ModeChanged" and args.match:match ".*:.*")
                        then
                            vim.cmd.redrawstatus() -- redraw on update
                        end
                    end),
                },
                hl = status.hl.get_attributes "mode",                  -- highlight based on mode attributes
                surround = { separator = "right", color = status.hl.mode_bg }, -- background highlight based on mode
            },
        }

        local path_func = status.provider.filename { modify = ":.:h", fallback = "" }

        opts.winbar = { -- create custom winbar
            -- store the current buffer number
            init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
            fallthrough = false, -- pick the correct winbar based on condition
            -- inactive winbar
            {
                condition = function() return not status.condition.is_active() end,
                -- show the path to the file relative to the working directory
                status.component.separated_path { path_func = path_func },
                -- add the file name and icon
                status.component.file_info {
                    file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
                    filename = {},
                    filetype = false,
                    file_modified = false,
                    file_read_only = false,
                    hl = status.hl.get_attributes("winbarnc", true),
                    surround = false,
                    update = "BufEnter",
                },
            },
            -- active winbar
            {
                -- show the path to the file relative to the working directory
                status.component.separated_path { path_func = path_func },
                -- add the file name and icon
                status.component.file_info { -- add file_info to breadcrumbs
                    file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
                    filename = {},
                    filetype = false,
                    file_modified = false,
                    file_read_only = false,
                    hl = status.hl.get_attributes("winbar", true),
                    surround = false,
                    update = "BufEnter",
                },
                -- show the breadcrumbs
                status.component.breadcrumbs {
                    icon = { hl = true },
                    hl = status.hl.get_attributes("winbar", true),
                    prefix = true,
                    padding = { left = 0 },
                },
            },
        }

        -- Now that we have the component, we need a timer to emit the User UpdateTime event
        vim.uv.new_timer():start(           -- timer for updating the time
            (60 - tonumber(os.date "%S")) * 1000, -- offset timer based on current seconds past the minute
            60000,                          -- update every 60 seconds
            vim.schedule_wrap(function()
                vim.api.nvim_exec_autocmds( -- emit our new User event
                    "User",
                    { pattern = "UpdateTime", modeline = false }
                )
            end)
        )
    end,
}
