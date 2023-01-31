local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local mm = {
    ['<CR>'] = function(pb)
        local picker = action_state.get_current_picker(pb)
        local multi = picker:get_multi_selection()
        actions.select_default(pb) -- the normal enter behaviour
        for _, j in pairs(multi) do
            if j.path ~= nil then
                vim.cmd(string.format('%s %s', 'edit', j.path))
            end
        end
    end,
}

return { defaults = { mappings = { i = mm, n = mm } } }
