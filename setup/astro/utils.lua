local M = {}
-- require "os"
--  e.g. :lua require('user.utils').dump(vim.lsp)
--  or : UU.dump(vim.lsp), we have UU mapped to this (,E evaluates into buffer)
M.dump = function(...)
    local objects = vim.tbl_map(vim.inspect, { ... })
    print(unpack(objects))
    return ...
end

local function visual_selection_range()
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    if csrow < cerow or (csrow == cerow and cscol <= cecol) then
        return csrow - 1, cscol - 1, cerow - 1, cecol
    else
        return cerow - 1, cecol - 1, csrow - 1, cscol
    end
end

function file_exists(name)
    if name ~= nil then
        return
    end
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    end
end

M.write_dom = function()
    -- writing the dom of what is shown in the preview browser:
    -- all set within environ which starts vim:
    -- Not sure what it does again, disabling:
    -- local notif = os.getenv("cmd_notify")
    -- local write = os.getenv("cmd_preview_browser_write_dom")
    -- if file_exists(os.getenv("fn_flag_preview_browser_running")) and write then
    --     os.execute(notif .. " 'writing dom...'")
    --     os.execute(write)
    -- else
    --     os.execute(notif .. " 'not writing dom' 'no preview browser open'")
    -- end
end

--[[ M.autosave = function(arg) ]]
--[[     os.execute("notify-send" .. " 'writing dom...'") ]]
--[[     local get_ls = vim.tbl_filter(function(buf) ]]
--[[         return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") ]]
--[[     end, vim.api.nvim_list_bufs()) ]]
--[[     for i in pairs(get_ls) do ]]
--[[         os.execute("notify-send" .. i[1]) ]]
--[[     end ]]
--[[ end ]]

M.smart_open = function(arg)
    -- gf opens anything openable. Calls a python app, which writes back if vim should open it
    -- we have a vmap of ,g to this with arg "visualsel" -> get that selection from the buffer:
    local line = vim.api.nvim_get_current_line()
    if arg == 'visualsel' then
        local csrow, cscol, cerow, cecol = visual_selection_range()
        local l = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), csrow, csrow + 1, true)
        arg = l[1]
        arg = arg:sub(cscol, cecol)
    end
    local fn = '/tmp/smartopen'
    local fd = io.open(fn, 'w')
    io.output(fd)
    io.write(':-:word:-:')
    io.write(arg)
    io.write(':-:fn:-:')
    io.write(vim.fn.expand('%:p'))
    io.write(':-:line:-:')
    io.write(line)
    io.write(':-:end:-:')
    io.close(fd)
    os.execute('~/.config/nvim/lua/user/smart_vi_open.py')

    -- local pth = arg --:gsub('"', "")
    -- pth = pth:gsub("'", "")
    -- pth = string.gsub(pth, "'", "")
    fd = io.open(fn, 'r')
    if fd ~= nil then
        io.input(fd)
        local s = io.read()
        io.close(fd)
        if s ~= nil then
            fd = io.open(s, 'r')
            -- if its a file: edit it
            -- else its a vim command
            if fd ~= nil then
                io.close(fd)
                vim.cmd('edit ' .. s)
            else
                vim.cmd(s)
            end
        end
    end
    return ''
end

M.merge = function(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

M._if = function(bool, a, b)
    if bool then
        return a
    else
        return b
    end
end

M.map = function(modes, key, result, options)
    options = M.merge({
        noremap = true,
        silent = false,
        expr = false,
        nowait = false,
    }, options or {})
    local buffer = options.buffer
    options.buffer = nil

    if type(modes) ~= 'table' then
        modes = { modes }
    end

    for i = 1, #modes do
        if buffer then
            vim.api.nvim_buf_set_keymap(0, modes[i], key, result, options)
        else
            vim.api.nvim_set_keymap(modes[i], key, result, options)
        end
    end
end

function _G.copy(obj, seen)
    if type(obj) ~= 'table' then
        return obj
    end
    if seen and seen[obj] then
        return seen[obj]
    end
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in next, obj do
        res[copy(k, s)] = copy(v, s)
    end
    return setmetatable(res, getmetatable(obj))
end

function _G.P(...)
    local objects = vim.tbl_map(vim.inspect, { ... })
    print(unpack(objects))
end

function _G.R(package)
    package.loaded[package] = nil
    return require(package)
end

function _G.T()
    print(require('nvim-treesitter.ts_utils').get_node_at_cursor():type())
end

M.ansi_codes = {
    _clear = '[0m',
    _red = '[0;31m',
    _green = '[0;32m',
    _yellow = '[0;33m',
    _blue = '[0;34m',
    _magenta = '[0;35m',
    _cyan = '[0;36m',
    _grey = '[0;90m',
    _dark_grey = '[0;97m',
    _white = '[0;98m',
    red = function(self, string)
        return self._red .. string .. self._clear
    end,
    green = function(self, string)
        return self._green .. string .. self._clear
    end,
    yellow = function(self, string)
        return self._yellow .. string .. self._clear
    end,
    blue = function(self, string)
        return self._blue .. string .. self._clear
    end,
    magent = function(self, string)
        return self._magenta .. string .. self._clear
    end,
    cyan = function(self, string)
        return self._cyan .. string .. self._clear
    end,
    grey = function(self, string)
        return self._grey .. string .. self._clear
    end,
    dark_grey = function(self, string)
        return self._dark_grey .. string .. self._clear
    end,
    white = function(self, string)
        return self._white .. string .. self._clear
    end,
}

M.shorten_string = function(string, length)
    if #string < length then
        return string
    end
    local start = string:sub(1, (length / 2) - 2)
    local _end = string:sub(#string - (length / 2) + 1, #string)
    return start .. '...' .. _end
end

M.wrap_lines = function(input, width)
    local output = {}
    for _, line in ipairs(input) do
        line = line:gsub('\r', '')
        while #line > width + 2 do
            local trimmed_line = string.sub(line, 1, width)
            local index = trimmed_line:reverse():find(' ')
            if index == nil or index > #trimmed_line / 2 then
                break
            end
            table.insert(output, string.sub(line, 1, width - index))
            line = vim.o.showbreak .. string.sub(line, width - index + 2, #line)
        end
        table.insert(output, line)
    end

    return output
end

M.toggle_diag_displ = function()
    local c = vim.diagnostic.config
    if c()['virtual_text'] then
        --say CursorHold,CursorHoldI * to get it while typing
        vim.cmd([[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]])
    else
        vim.cmd([[autocmd CursorHold * autocmd!]])
    end
    c({ virtual_text = not c()['virtual_text'], update_in_insert = false })
end
return M
