-- ~/.config/nvim/lua/plugins/gitsigns.lua

local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    return
end

gitsigns.setup({
    signs_staged_enable = true,
    attach_to_untracked = true,
    -- stylua: ignore
    count_chars = { "", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", ["+"] = "󰿮" },
    signs = {
        delete = { show_count = true },
        topdelete = { show_count = true },
        changedelete = { show_count = true },
    },
    current_line_blame_formatter = "<summary> (<author_time:%R>, <author>))",
    current_line_blame_formatter_nc = "+++ uncommitted",
    current_line_blame_opts = { delay = 500 },
})

-- Using gitsigns's data since lualine's builtin component is updated less
-- frequently and thus often out of sync with gitsigns in the signcolumn.
vim.g.lualineAdd("sections", "lualine_y", {
    "diff",
    source = function()
        local gs = vim.b.gitsigns_status_dict
        if not gs then return end
        return { added = gs.added, modified = gs.changed, removed = gs.removed }
    end,
    fmt = function(str) return vim.b.gitsignsPrevChanges and "󰑟 " .. str or str end,
}, "before")
