-- ~/.config/nvim/lua/plugins/popup.lua

local status_ok, popup = pcall(require, "popup")
if not status_ok then
    return
end

popup.setup()
