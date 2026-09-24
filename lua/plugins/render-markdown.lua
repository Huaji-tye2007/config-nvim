-- ~/.config/nvim/lua/plugins/render-markdown.lua

local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
    return
end

render_markdown.setup({
    -- Math formulas are rendered by nabla.nvim instead (see plugins.nabla),
    -- so the built-in latex converter is turned off to avoid double rendering.
    latex = {
        enabled = false,
    },
})
