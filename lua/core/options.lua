local opt = vim.opt

-- line number
opt.relativenumber = true
opt.number = true

-- indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- wrap
opt.wrap = false

-- mouse
opt.mouse:append("a")

-- system clipboard
opt.clipboard:append("unnamedplus") -- dependencies: wayland-'wl-clipboard'; x11-'xclip'; tip: installing both clipboard may cause 'vim.health' error

-- new windows
opt.splitright = true
opt.splitbelow = true

-- searching
opt.ignorecase = true
opt.smartcase = true

-- appearance
opt.termguicolors = true
opt.signcolumn = "yes"
