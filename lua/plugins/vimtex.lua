-- ~/.config/nvim/lua/plugins/vimtex.lua

-- Kept as a fallback for the raw `:VimtexView` command (SyncTeX forward/
-- inverse search), but never triggered automatically (see
-- vimtex_view_automatic below) since day-to-day preview goes through
-- <leader>vv instead.
vim.g.vimtex_view_method = 'zathura'

-- Don't auto-open the viewer after the first successful compile; only
-- <leader>vv (or manual `:VimtexView`) should open a viewer.
vim.g.vimtex_view_automatic = 0

-- Only pop up the quickfix window for actual errors, not for warnings like
-- fontspec's harmless "does not contain requested Script CJK" noise on every
-- ctex/fandol compile.
vim.g.vimtex_quickfix_open_on_warning = 0

-- Neovim's builtin terminal (libvterm, which toggleterm also runs on) does
-- not pass through the Kitty graphics protocol, so `tdf` renders nothing
-- inside a toggleterm split. Instead, ask the real kitty instance (remote
-- control; see kitty.conf's `allow_remote_control`) to open a genuine kitty
-- window running tdf, which does support the graphics protocol.
local pdf_kitty_window_id = nil

---@param callback fun(pdf: string)
local function with_pdf_path(callback)
    local tex_main = vim.b.vimtex and vim.b.vimtex.tex
    if not tex_main or tex_main == '' then
        vim.notify('vimtex: no active LaTeX project in this buffer', vim.log.levels.WARN)
        return
    end

    local pdf = vim.fn.fnamemodify(tex_main, ':r') .. '.pdf'
    if vim.fn.filereadable(pdf) == 0 then
        vim.notify('vimtex: PDF not found yet, compile first (<leader>vc): ' .. pdf, vim.log.levels.WARN)
        return
    end

    callback(pdf)
end

local function open_pdf_preview()
    -- vim.fn.system() gives the child no controlling tty, so `kitty @` can't
    -- auto-detect its parent instance; requires kitty's `listen_on` socket
    -- (see ~/.config/kitty/kitty.conf) and $KITTY_LISTEN_ON passed explicitly.
    local kitty_addr = os.getenv('KITTY_LISTEN_ON')
    if not kitty_addr then
        vim.notify(
            'vimtex: $KITTY_LISTEN_ON is not set - restart kitty so its listen_on socket takes effect',
            vim.log.levels.ERROR)
        return
    end

    with_pdf_path(function(pdf)
        if pdf_kitty_window_id then
            vim.fn.system({ 'kitty', '@', '--to', kitty_addr, 'focus-window', '--match', 'id:' .. pdf_kitty_window_id })
            if vim.v.shell_error == 0 then
                return
            end
            pdf_kitty_window_id = nil
        end

        local out = vim.fn.system({
            'kitty', '@', '--to', kitty_addr, 'launch', '--type=window', '--title=tdf-preview',
            'tdf', '--reload-delay', '200', pdf,
        })
        if vim.v.shell_error ~= 0 then
            vim.notify('vimtex: failed to launch tdf via kitty remote control: ' .. out, vim.log.levels.ERROR)
            return
        end
        pdf_kitty_window_id = vim.trim(out)
    end)
end

-- texlab (LSP) already provides completion for \ref/\cite/\label etc, so
-- vimtex's own omnifunc-based completion is turned off to avoid duplicates.
vim.g.vimtex_complete_enabled = 0

-- ctex/CJK documents need fandol fonts, which only work through xelatex, not
-- the default pdflatex. '_' is the fallback engine when no `%!TEX program`
-- magic comment is present in the file; override it per-file with e.g.
-- `%!TEX program = pdflatex` if a document doesn't use ctex.
vim.g.vimtex_compiler_latexmk_engines = {
    ['_'] = '-xelatex',
}

-- vimtex's own default mappings live under <localleader> (still '\' since
-- maplocalleader is unset), which is why <leader>-based muscle memory
-- doesn't reach them. Mappings below replace them under <leader>v instead.
vim.g.vimtex_mappings_enabled = 0

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'tex',
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set('n', '<leader>vc', '<cmd>VimtexCompile<CR>',
            vim.tbl_extend('force', opts, { desc = 'Vimtex: (toggle) compile' }))
        vim.keymap.set('n', '<leader>vv', open_pdf_preview,
            vim.tbl_extend('force', opts, { desc = 'Vimtex: open/focus PDF preview (tdf)' }))
        vim.keymap.set('n', '<leader>vs', '<cmd>VimtexStop<CR>',
            vim.tbl_extend('force', opts, { desc = 'Vimtex: stop compilation' }))
        -- :VimtexClean alone restarts continuous compilation right after
        -- cleaning (documented behavior, meant to preserve a live preview),
        -- which regenerates the aux files it just removed. Stop first so the
        -- clean actually sticks; <leader>vc restarts compilation when wanted.
        vim.keymap.set('n', '<leader>vk', '<cmd>VimtexStop<CR><cmd>VimtexClean<CR>',
            vim.tbl_extend('force', opts, { desc = 'Vimtex: stop + clean aux files' }))
        vim.keymap.set('n', '<leader>vt', '<cmd>VimtexTocToggle<CR>',
            vim.tbl_extend('force', opts, { desc = 'Vimtex: toggle table of contents' }))
        vim.keymap.set('n', '<leader>ve', '<cmd>VimtexErrors<CR>',
            vim.tbl_extend('force', opts, { desc = 'Vimtex: show compile errors' }))
    end,
})
