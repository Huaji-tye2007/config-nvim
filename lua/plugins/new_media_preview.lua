-- ~/.config/nvim/lua/utils/new_media_preview.lua

local M = {}

M.config = {
    filetypes = { "png", "jpg", "jpeg", "gif", "webp", "mp4", "webm", "pdf", "epub" },
    find_cmd = "fd"
}

M.current_image = nil

local function clear_image()
    if M.current_image then
        M.current_image:clear()
        M.current_image = nil
    end
end

function M.media_files(opts)
    -- 只有在按下快捷键时，才去检查和加载 telescope 依赖
    local has_telescope, telescope = pcall(require, "telescope")
    if not has_telescope then
        vim.notify("telescope.nvim is not loaded!", vim.log.levels.ERROR)
        return
    end

    local has_image, image_api = pcall(require, "image")
    if not has_image then
        vim.notify("3rd/image.nvim is not loaded!", vim.log.levels.ERROR)
        return
    end

    -- 加载所需组件
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local finders = require('telescope.finders')
    local pickers = require('telescope.pickers')
    local previewers = require('telescope.previewers')
    local conf = require('telescope.config').values

    local tmp_dir = "/tmp/vimg"
    vim.fn.mkdir(tmp_dir, "p")

    -- 绘制函数
    -- local function draw_image(filepath, bufnr, winid)
    --     if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then return end
    --     M.current_image = image_api.from_file(filepath, {
    --         window = winid,
    --         buffer = bufnr,
    --         with_virtual_padding = true,
    --     })
    --     if M.current_image then
    --         M.current_image:render()
    --     end
    -- end
    local function draw_image(filepath, bufnr, winid)
        -- 延迟 50 毫秒，等 Telescope 的浮动窗口完全排版完毕
        vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then return end

            M.current_image = image_api.from_file(filepath, {
                window = winid,
                buffer = bufnr,
                with_virtual_padding = true,
            })

            if M.current_image then
                M.current_image:render()
            end
        end, 50)
    end

    -- 预览器逻辑
    local media_preview = previewers.new_buffer_previewer({
        title = "Media Preview",
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry, status)
            local bufnr = self.state.bufnr
            local winid = self.state.winid
            local filepath = vim.fn.expand(entry.value)

            clear_image()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

            local ext = filepath:match("^.+%.(.+)$")
            ext = ext and ext:lower() or ""

            if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or ext == "webp" then
                draw_image(filepath, bufnr, winid)
            elseif ext == "pdf" or ext == "epub" then
                local filename = vim.fn.fnamemodify(filepath, ":t")
                local target_png = tmp_dir .. "/" .. filename .. ".png"

                if vim.fn.filereadable(target_png) == 1 then
                    draw_image(target_png, bufnr, winid)
                else
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Generating High-Res PDF Preview..." })
                    vim.fn.jobstart({ "pdftoppm", "-png", "-singlefile", filepath, tmp_dir .. "/" .. filename }, {
                        on_exit = function(_, code)
                            if code == 0 and vim.api.nvim_buf_is_valid(bufnr) then
                                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
                                draw_image(target_png, bufnr, winid)
                            end
                        end
                    })
                end
            elseif ext == "mp4" or ext == "webm" or ext == "mkv" or ext == "avi" then
                local filename = vim.fn.fnamemodify(filepath, ":t")
                local target_png = tmp_dir .. "/" .. filename .. ".png"

                if vim.fn.filereadable(target_png) == 1 then
                    draw_image(target_png, bufnr, winid)
                else
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Generating Video Thumbnail..." })
                    vim.fn.jobstart({ "ffmpegthumbnailer", "-i", filepath, "-o", target_png, "-s", "0", "-q", "10" }, {
                        on_exit = function(_, code)
                            if code == 0 and vim.api.nvim_buf_is_valid(bufnr) then
                                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
                                draw_image(target_png, bufnr, winid)
                            end
                        end
                    })
                end
            else
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "No preview available for " .. ext })
            end
        end,
        teardown = function(self)
            clear_image()
        end
    })

    -- 查找命令设置
    local filetypes = M.config.filetypes
    local find_cmd = M.config.find_cmd
    local find_commands = {
        find = { 'find', '.', '-iregex', [[.*\.\(]] .. table.concat(filetypes, "\\|") .. [[\)$]] },
        fd = { 'fd', '--type', 'f', '--regex', [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]], '.' },
        fdfind = { 'fdfind', '--type', 'f', '--regex', [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]], '.' },
        rg = { 'rg', '--files', '--glob', [[*.{]] .. table.concat(filetypes, ",") .. [[}]], '.' },
    }

    if not vim.fn.executable(find_cmd) then
        vim.notify("You don't have " .. find_cmd .. "! Install it first.", vim.log.levels.ERROR)
        return
    end

    opts = opts or {}
    opts.attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
            local entry = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if entry and entry[1] then
                local filename = entry[1]
                vim.fn.setreg(vim.v.register, filename)
                vim.notify("The image path has been copied: " .. filename)
            end
        end)
        return true
    end
    opts.path_display = { "shorten" }

    -- 启动 Telescope 选择器
    local picker = pickers.new(opts, {
        prompt_title = 'Media Files',
        finder = finders.new_oneshot_job(
            find_commands[find_cmd],
            opts
        ),
        previewer = media_preview,
        sorter = conf.file_sorter(opts),
    })

    picker:find()
end

return M
