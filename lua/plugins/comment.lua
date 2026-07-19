-- ~/.config/nvim/lua/plugins/comment.lua

-- Safely load
local status_ok, comment = pcall(require, "Comment")
if not status_ok then
    return
end

comment.setup()
