---@type LazySpec

return {
    "mfussenegger/nvim-dap",
    config = function()
        local dap = require "dap"

        -- configure delve dap (golang's dap)
        dap.adapters.delve = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.exepath "dlv",
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }

        -- configure delve dap to specify build flags, which are
        -- the build tags that are specifically used
        dap.configurations.go = {
            {
                type = "delve",
                name = "Delve: Debug",
                request = "launch",
                program = "${workspaceFolder}",
            },
            {
                type = "delve",
                name = "Delve: Debug test with tags",
                request = "launch",
                mode = "test",
                program = "${file}",
                buildFlags = { "-tags=test,integration" },
            },
            {
                type = "delve",
                name = "Delve: Debug test (go.mod) with tags",
                request = "launch",
                mode = "test",
                program = "./${relativeFileDirname}",
                buildFlags = { "-tags=test,integration" },
            },
        }
    end,
}
