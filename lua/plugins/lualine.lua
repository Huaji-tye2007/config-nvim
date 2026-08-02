-- ~/.config/nvim/lua/plugins/lualine.lua

-- Safely load
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

lualine.setup({
    options = {
        theme = 'tokyonight',
        globalstatus = true,
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },

    tabline = {
        lualine_a = {
            {
                'buffers',
                mode = 2,
                icons_enabled = true,
                symbols = {
                    modified = '●',
                    alternate_file = '',
                    directory = '',
                },
                show_filename_only = true,
                hide_filename_extension = false,
                show_modified_status = true,
                max_length = vim.o.columns * 2 / 3,
            }
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' }
    },
})

vim.g.lualineAdd = function(whichBar, whichSection, component, where)
    vim.defer_fn(function() -- deferred so other plugins do not load lualine too early
        if not (status_ok and lualine) then return end
        local componentObj = type(component) == "table" and component or { component }
        local sectionConfig = lualine.get_config()[whichBar][whichSection] or {}
        local pos = where == "before" and 1 or #sectionConfig + 1
        table.insert(sectionConfig, pos, componentObj)
        lualine.setup { [whichBar] = { [whichSection] = sectionConfig } }
    end, 1000)
end
