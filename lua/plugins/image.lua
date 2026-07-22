-- ~/.config/nvim/lua/plugins/image.lua

local ok, image = pcall(require, "image")
if not ok then
    return
end

image.setup({
    debug        = {
        file_path = "/tmp/image.nvim.log",
        format = "compact",
        enabled = true,
        level = "debug",
    },
    backend      = "kitty",
    processor    = "magick_cli",
    kitty_method = "normal",
    integrations = {
        telescope = {
            enabled = false,
        },
        markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            only_render_image_at_cursor_mode = "popup",
            floating_windows = false,
            filetypes = { "markdown", "vimwiki" },
        },
    }
})

image.enable()
