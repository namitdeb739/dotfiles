-- init.lua — entry point
-- Loads options and keymaps first, then bootstraps lazy.nvim and plugins.

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.prose")
require("config.lazy")
