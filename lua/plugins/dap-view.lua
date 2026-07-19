-- ~/.config/nvim/lua/plugins/dap-view.lua

local status, dapview = pcall(require, "dap-view")
if not status then
    return
end

dapview.setup({
    winbar = {
        controls = {
            enabled = true,
            buttons = { "play", "step_into", "step_over", "step_out", "term_restart", "fun" },
            custom_buttons = {
                fun = {
                    render = function()
                        return "🎉"
                    end,
                    action = function()
                        vim.print("🎊")
                    end,
                },
                -- Stop | Restart
                -- Double click, middle click or click with a modifier disconnect instead of stopping
                term_restart = {
                    render = function(session)
                        local group = session and "ControlTerminate" or "ControlRunLast"
                        local icon = session and "" or ""
                        return "%#NvimDapView" .. group .. "#" .. icon .. "%*"
                    end,
                    action = function(clicks, button, modifiers)
                        local dap = require("dap")
                        local alt = clicks > 1 or button ~= "l" or modifiers:gsub(" ", "") ~= ""
                        if not dap.session() then
                            dap.run_last()
                        elseif alt then
                            dap.disconnect()
                        else
                            dap.terminate()
                        end
                    end,
                },
            },
        },
    },
})
