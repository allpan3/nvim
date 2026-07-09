-- Loads the Neovim configuration modules in startup order
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
require('config.highlights').setup_diff_windows()
