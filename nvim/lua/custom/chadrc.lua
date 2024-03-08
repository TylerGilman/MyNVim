---@type ChadrcConfig
local M = {}
M.ui = { tabufline = {
  enabled= false
},
  theme = 'catppuccin'}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
return M
