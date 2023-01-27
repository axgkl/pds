local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local M = { selected = {} } -- keeps all TAB selected items

local on_TAB = function()
  local fn = action_state.get_selected_entry().path
  if fn == nil then
    return -- not a file
  end
  if M.selected[fn] == nil then
    M.selected[fn] = 1
  else
    M.selected[fn] = nil
  end
end

local mm = {
  ["<CR>"] = function(pb)
    actions.select_default(pb)
    -- if we have additional files selected by TAB, lets open them as well:
    for fn, v in pairs(M.selected) do
      if v == 1 then
        vim.cmd(string.format("%s %s", "edit", fn))
      end
    end
    M.selected = {}
  end,
  ["<Tab>"] = function(pb)
    on_TAB()
    actions.toggle_selection(pb)
    actions.move_selection_worse(pb)
  end,
  ["<S-Tab>"] = function(pb)
    on_TAB()
    actions.toggle_selection(pb)
    actions.move_selection_better(pb)
  end,
}

return {
  defaults = {
    mappings = {
      i = mm,
      n = mm,
    },
  },
}



