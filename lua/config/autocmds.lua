-- Autocmds

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

local bigfile = require('config.bigfile')

vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Prepare large files before reading them',
  group = vim.api.nvim_create_augroup('bigfile-read-pre', { clear = true }),
  callback = function(event)
    bigfile.prepare_buffer(event.buf, event.file)
  end,
})

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  desc = 'Enable swapfiles for normal file buffers',
  group = vim.api.nvim_create_augroup('normal-file-swap', { clear = true }),
  callback = function(event)
    bigfile.enable_swapfile_if_safe(event.buf)
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  desc = 'Use lean window/global options for large files',
  group = vim.api.nvim_create_augroup('bigfile-enter', { clear = true }),
  callback = function(event)
    if bigfile.is_big(event.buf) then
      bigfile.disable_buffer_features(event.buf)
      bigfile.enter_buffer(event.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('BufLeave', {
  desc = 'Restore options after leaving huge files',
  group = vim.api.nvim_create_augroup('bigfile-leave', { clear = true }),
  callback = function(event)
    bigfile.leave_buffer(event.buf)
  end,
})

-- Checks whether file buffers changed outside Neovim
local function check_external_file_changes(buf)
  if vim.fn.getcmdwintype() ~= '' then
    return
  end

  if buf then
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' or vim.api.nvim_buf_get_name(buf) == '' then
      return
    end

    vim.cmd('checktime ' .. buf)
    return
  end

  vim.cmd.checktime()
end

vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Check all buffers for external file changes',
  group = vim.api.nvim_create_augroup('autoread-checktime', { clear = true }),
  callback = function()
    check_external_file_changes()
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Check current buffer for external file changes',
  group = vim.api.nvim_create_augroup('autoread-current-buffer', { clear = true }),
  callback = function(event)
    check_external_file_changes(event.buf)
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Disable automatic comment wrapping and insertion of comment characters
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable automatic comment wrapping',
  group = vim.api.nvim_create_augroup('disable-comment-wrap', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Rebalance windows after terminal resize',
  group = vim.api.nvim_create_augroup('resize-splits', { clear = true }),
  callback = function()
    vim.schedule(function()
      vim.cmd.wincmd '='
    end)
  end,
})

-- Runs a Zellij command when this Neovim instance is inside Zellij
local function zellij(args)
  if not vim.env.ZELLIJ or vim.fn.executable('zellij') == 0 then
    return
  end

  vim.fn.jobstart(vim.list_extend({ 'zellij' }, args), { detach = true })
end

-- Moves inside Neovim first, then falls through to Zellij at the edge
local function move_pane(direction, zellij_action)
  local vim_key = ({ left = 'h', down = 'j', up = 'k', right = 'l' })[direction]

  return function()
    local before = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. vim_key)

    if vim.api.nvim_get_current_win() == before then
      zellij({ 'action', zellij_action, direction })
    end
  end
end

vim.api.nvim_create_user_command('ZellijNavigateLeft', move_pane('left', 'move-focus-or-tab'), {})
vim.api.nvim_create_user_command('ZellijNavigateDown', move_pane('down', 'move-focus'), {})
vim.api.nvim_create_user_command('ZellijNavigateUp', move_pane('up', 'move-focus'), {})
vim.api.nvim_create_user_command('ZellijNavigateRight', move_pane('right', 'move-focus-or-tab'), {})
