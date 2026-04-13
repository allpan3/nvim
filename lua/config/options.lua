-- Options

-- Set <space> as the leader key
-- See `:help mapleader`
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- For more options, you can see `:help option-list`

-- line numbers
-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
-- vim.o.relativenumber = true
vim.opt.numberwidth = 4 -- minimal number of columns to use for the line number {default 4}

-- tabs & indentation
vim.opt.shiftwidth = 4 -- number of spaces inserted for each indentation
vim.opt.autoindent = true -- copy indent from current line when starting a new one

-- editing
vim.opt.conceallevel = 2 -- so that `` is visible in markdown files
-- vim.opt.swapfile = false -- creates a swapfile
vim.o.expandtab = true

-- mouse
-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

vim.o.whichwrap = '<,>,[,]'

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  -- only set clipboard if not in ssh, to make sure the OSC 52
  -- integration works automatically. Requires Neovim >= 0.10.0
  vim.o.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus' -- Sync with system clipboard
end)

-- Enable break indent
vim.o.breakindent = true

-- vim.opt.fillchars = {
--   foldopen = '',
--   foldclose = '',
--   fold = ' ',
--   foldsep = ' ',
--   diff = '╱',
--   eob = ' ',
-- }

-- Line wrap by default
vim.o.wrap = false

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
-- Without the :1 the signcolumn width would somehow keep changing
vim.o.signcolumn = 'yes:1'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 4

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Turn off key code timeout since we never type escape sequences manually
-- This fixes the ESC delay issue. This may also affect some other default key codes,
-- but I haven't used any of those so far.
-- Note: do not turn off ttimeout altogether. Some escape sequences are being typed at
-- neovim startup by some plugins, which is also affectd by ttimeout. But setting len to 0 works so far.
-- vim.o.ttimeoutlen = 0

