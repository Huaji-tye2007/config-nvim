-- ~/.config/nvim/lua/plugins/dap.lua

-- Safely load
local status_ok, dap = pcall(require, "dap")
if not status_ok then
    return
end

-- local status_ok, dapui = pcall(require, "dapui")
-- if not status_ok then
--     return
-- end
--
-- dap.listeners.before.attach.dapui_config = function()
--     dapui.open()
-- end
-- dap.listeners.before.launch.dapui_config = function()
--     dapui.open()
-- end
-- dap.listeners.before.event_terminated.dapui_config = function()
--     dapui.close()
-- end
-- dap.listeners.before.event_exited.dapui_config = function()
--     dapui.close()
-- end

-- gdb's own native DAP server (verified against its actual source in
-- /usr/share/gdb/python/gdb/dap/launch.py) never sends a `runInTerminal`
-- reverse request, so dap-view's built-in integrated-terminal handling (which
-- only reacts to that request) never fires for it - the debuggee's stdin/
-- stdout would otherwise go nowhere usable. Worked around with gdb's own
-- `--tty=DEVICE` flag (a plain gdb feature, unrelated to DAP) pointed at a
-- toggleterm split's pty, so scanf/cin-style programs still work.
local dap_io_term = nil

local function dap_io_pty()
    -- Torn down and recreated on every call (not just clearing the buffer):
    -- this terminal's "job" is `sleep infinity`, not a shell, so there's
    -- nothing present to interpret a `clear`-style command - the previous
    -- run's output would just keep accumulating with no way to wipe it
    -- in place. A fresh Terminal (same id/position, genuinely new pty) is
    -- what actually gives each debug session (same file, different file,
    -- or a rerun) a clean slate - each already gets its own gdb process,
    -- only the I/O terminal was being reused stale.
    if dap_io_term then
        dap_io_term:shutdown()
    end
    local Terminal = require('toggleterm.terminal').Terminal
    dap_io_term = Terminal:new({
        -- Fixed id so it's always the same instance - <leader>di below
        -- targets it directly instead of colliding with your regular
        -- <C-\> terminals (which default to id 1, a different instance).
        id = 95,
        -- No shell here: a shell would sit on this pty as its own
        -- foreground job, so its prompt gets interleaved with the
        -- debuggee's actual output, and it never "exits" on its own
        -- (hence seemingly stuck open). This idles without reading or
        -- printing anything, so only the debuggee's real I/O shows.
        cmd = 'exec sleep infinity',
        direction = 'horizontal',
        close_on_exit = false,
        hidden = true,
        display_name = 'DAP program I/O',
    })
    dap_io_term:open()
    return vim.api.nvim_get_chan_info(dap_io_term.job_id).pty
end

-- With libc6-dbg installed, glibc has debug *symbols* but not its actual
-- *source* - stepping past your own main() into __libc_start_call_main/exit
-- internals makes gdb try to open source files that were never on disk
-- (confirmed: "[Errno 2] No such file or directory: '.../libc_start_call_main.h'"),
-- and nvim-dap's jump-to-frame then crashes trying to place the cursor on a
-- line number that doesn't exist in the empty fallback buffer it opened
-- ("Invalid cursor line: out of range"), which was taking dap-view's UI down
-- with it. `skip` only intercepts stepping INTO a call to a matched
-- function - confirmed with a plain (non-DAP) gdb repro that it does NOT
-- intercept main() returning into its (skip-listed) caller, which is exactly
-- what stepping off the end of main does, so this alone doesn't fully fix
-- it. Still worth keeping for the case of actually stepping into a libc call
-- from your own code (e.g. F11 into printf).
local gdb_startup_args = {}
for _, pattern in ipairs({ '^__libc_', '^__run_', '^__GI_', '^_dl_', '^_IO_' }) do
    table.insert(gdb_startup_args, '--eval-command')
    table.insert(gdb_startup_args, "skip -rfunction '" .. pattern .. "'")
end

dap.adapters.gdb = function(callback)
    local ok, pty = pcall(dap_io_pty)
    local args = { '--interpreter=dap', '--eval-command', 'set print pretty on' }
    vim.list_extend(args, gdb_startup_args)
    if ok and pty and pty ~= '' then
        table.insert(args, '--tty=' .. pty)
    else
        vim.notify('DAP: could not set up an I/O terminal, program stdin/stdout will be unavailable', vim.log.levels.WARN)
    end
    callback({ type = 'executable', command = 'gdb', args = args })
end

-- The actual fix for stepping off the end of main: nvim-dap's own built-in
-- Session:event_stopped is what synchronously calls jump_to_frame (crashing
-- when the frame's source doesn't exist on disk) - confirmed from
-- dap/session.lua's handle_body dispatch order that this runs BEFORE any
-- dap.listeners.after.event_stopped callback gets a chance to react, so
-- reacting *after* the fact (an earlier version of this fix) is always too
-- late to stop the crash from flashing up. Wrapping event_stopped itself
-- lets us check the frame's source *before* the built-in handler ever calls
-- jump_to_frame, and skip straight to it unchanged for every normal case.
do
    local dap_session = require('dap.session')
    local original_event_stopped = dap_session.event_stopped
    dap_session.event_stopped = function(self, stopped)
        if stopped.reason ~= 'step' then
            return original_event_stopped(self, stopped)
        end
        self:request('stackTrace', { threadId = stopped.threadId, startFrame = 0, levels = 1 }, function(err, resp)
            local frame = not err and resp and resp.stackFrames and resp.stackFrames[1]
            local path = frame and frame.source and frame.source.path
            if path and vim.fn.filereadable(path) == 0 then
                vim.schedule(function()
                    vim.notify(
                        'DAP: stepped past your own code into ' .. path .. ' (no source on disk) - running to completion',
                        vim.log.levels.INFO)
                    dap.continue()
                end)
            else
                original_event_stopped(self, stopped)
            end
        end)
    end
end

-- Captured by the <F5> keymap before dap.continue() does anything, since by
-- the time a config's `program` function actually runs, opening the toggleterm
-- I/O split above may have already changed the current buffer/window.
local dap_source_buf = nil

-- C's stdio only auto-flushes stdout on '\n' (line buffering, since the
-- debuggee's stdout is a real tty) or at normal process exit - printf calls
-- with no trailing newline (or std::cout without endl/flush) just sit in
-- glibc's internal buffer and never reach the terminal while single-stepping,
-- confirmed empirically (a no-newline printf stayed invisible through several
-- step_overs and even `terminate`, since gdb's terminate is a hard `kill`
-- that skips flush-on-exit entirely). This forces stdout fully unbuffered via
-- coreutils' stdbuf preload shim, so every write shows up immediately.
local unbuffered_stdio_env = {
    LD_PRELOAD = '/usr/libexec/coreutils/libstdbuf.so',
    _STDBUF_O = '0',
}

dap.configurations.c = {
    {
        -- For loose single-file C/C++ (no Makefile/CMake project): compiles
        -- whatever buffer is current with debug symbols and launches that,
        -- no separate build step needed. For Makefile/CMake projects, build
        -- yourself as usual and pick "Launch (existing executable)" instead.
        name = "Launch (compile current file)",
        type = "gdb",
        request = "launch",
        program = function()
            local buf = dap_source_buf or vim.api.nvim_get_current_buf()
            local ft = vim.bo[buf].filetype
            if ft ~= 'c' and ft ~= 'cpp' then
                error('DAP: buffer filetype is "' .. ft .. '", not c/cpp - compile-current-file only supports those')
            end
            local compiler = ft == 'cpp' and 'g++' or 'gcc'
            local src = vim.api.nvim_buf_get_name(buf)
            local out = vim.fn.tempname()
            local result = vim.fn.system({ compiler, '-g', '-O0', '-Wall', '-o', out, src })
            if vim.v.shell_error ~= 0 then
                vim.notify(compiler .. ' failed:\n' .. result, vim.log.levels.ERROR)
                error('DAP: compile failed')
            end
            return out
        end,
        args = {}, -- provide arguments if needed
        env = unbuffered_stdio_env,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
    {
        name = "Launch (existing executable)",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        args = {}, -- provide arguments if needed
        env = unbuffered_stdio_env,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
    {
        name = "Select and attach to process",
        type = "gdb",
        request = "attach",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        pid = function()
            local name = vim.fn.input('Executable name (filter): ')
            return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = '${workspaceFolder}'
    },
    {
        name = 'Attach to gdbserver :1234',
        type = 'gdb',
        request = 'attach',
        target = 'localhost:1234',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}'
    }
}

dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c

-- Execution control: VSCode-style function keys.
-- This terminal doesn't send real modifier-augmented codes for shifted F-keys
-- - it uses the classic xterm/rxvt convention of Shift+F<n> -> F<n+12>,
-- Ctrl+Shift+F<n> -> F<n+36>, confirmed empirically via i_CTRL-V for both
-- <S-F5> (arrived as <F17>) and <C-S-F5> (arrived as <F41>). <S-F11> is
-- remapped the same way (predicted <F23>, not yet independently confirmed).
vim.keymap.set('n', '<F5>', function()
    dap_source_buf = vim.api.nvim_get_current_buf()
    dap.continue()
end, { desc = 'DAP: Continue/Start' })
vim.keymap.set('n', '<F17>', dap.terminate, { desc = 'DAP: Stop (Shift+F5)' })
vim.keymap.set('n', '<F41>', function() dap.restart() end, { desc = 'DAP: Restart (Ctrl+Shift+F5)' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step into' })
vim.keymap.set('n', '<F23>', dap.step_out, { desc = 'DAP: Step out (Shift+F11)' })

-- Neovim only auto-binds K to LSP hover if K is still unmapped by the time an
-- LSP client attaches (see :h lsp-defaults); claiming it here up front means
-- that auto-bind never fires, so the LSP fallback below is handled by hand.
vim.keymap.set('n', 'K', function()
    if dap.session() then
        require('dap-view').hover(nil, false)
    else
        vim.lsp.buf.hover()
    end
end, { desc = 'Hover: DAP variable value (in session) / LSP docs' })

-- Breakpoints & watches: <leader>d namespace.
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Toggle breakpoint' })
vim.keymap.set('x', '<leader>db', function()
    -- '</'> only get finalized once visual mode is actually left; while the
    -- mapping's own callback is still running, we're technically still "in"
    -- the visual selection, so leave it first before reading the marks.
    vim.cmd('normal! ' .. vim.api.nvim_replace_termcodes('<Esc>', true, true, true))
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    for line = start_line, end_line do
        vim.api.nvim_win_set_cursor(0, { line, 0 })
        dap.set_breakpoint()
    end
    vim.notify(string.format('DAP: set breakpoints on lines %d-%d', start_line, end_line))
end, { desc = 'DAP: Set breakpoint on every line in selection' })
vim.keymap.set('n', '<leader>dB', function()
    local cond = vim.fn.input('Breakpoint condition: ')
    if cond ~= '' then
        dap.set_breakpoint(cond)
    end
end, { desc = 'DAP: Conditional breakpoint' })
vim.keymap.set('n', '<leader>dl', function()
    local msg = vim.fn.input('Log message: ')
    if msg ~= '' then
        dap.set_breakpoint(nil, nil, msg)
    end
end, { desc = 'DAP: Log point' })
vim.keymap.set('n', '<leader>dw', function()
    local expr = vim.fn.input('Watch expression: ', vim.fn.expand('<cexpr>'))
    if expr ~= '' then
        require('dap-view').add_expr(expr)
    end
end, { desc = 'DAP: Add watch expression' })
vim.keymap.set('n', '<leader>du', function() require('dap-view').toggle() end, { desc = 'DAP: Toggle UI' })
vim.keymap.set('n', '<leader>di', function()
    if dap_io_term then
        dap_io_term:toggle()
    else
        vim.notify('DAP: no program I/O terminal yet - starts with the first debug session', vim.log.levels.WARN)
    end
end, { desc = 'DAP: Toggle program I/O terminal' })
