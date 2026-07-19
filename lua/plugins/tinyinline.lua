-- ~/.config/nvim/lua/plugins/tinyinline.lua

-- disable built-in diagnostic
vim.diagnostic.config({ virtual_text = false })

-- Safely load
local status_ok, tinyinline = pcall(require, "tiny-inline-diagnostic")
if not status_ok then
    return
end

tinyinline.setup({
    preset = "ghost",
    options = {
        enable_on_insert = true,
        show_all_diags_on_cursorline = true,
    }
})
