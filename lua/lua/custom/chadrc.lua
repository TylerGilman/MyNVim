---@type ChadrcConfig
local M = {}
M.ui = { tabufline = {
  enabled= false
},
  theme = 'gruvbox'}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
return M
