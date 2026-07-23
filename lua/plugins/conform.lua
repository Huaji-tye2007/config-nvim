-- ~/.config/nvim/lua/plugins/conform.lua

-- Safely load
local status_ok, conform = pcall(require, "conform")
if not status_ok then
    return
end

conform.setup({
    formatters_by_ft = {
        -- lua = { "stylua" },
        -- python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        -- cpp = { "clang-format" },
        -- c = { "clang-format" },
    },

    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})
