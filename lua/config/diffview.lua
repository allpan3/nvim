-- Provides a file comparison workflow built on native Neovim diff mode
local M = {}

local active_session = nil

local diff_role_var = 'config_diff_role'

-- Reports a diffview problem without interrupting normal editing
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.WARN, { title = 'Diffview' })
end

-- Counts regular windows in the current tab
local function normal_window_count()
  local count = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      count = count + 1
    end
  end
  return count
end

-- Assigns one side of a managed diff its directional highlight role
local function set_diff_role(win, role)
  vim.api.nvim_win_set_var(win, diff_role_var, role)
end

-- Removes a managed diff role from a window if it still exists
local function clear_diff_role(win)
  if vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_del_var, win, diff_role_var)
  end
end

-- Finds a two-way Gitsigns diff in the current tab
local function gitsigns_session()
  local current_win = nil
  local reference_win = nil

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.wo[win].diff then
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if vim.startswith(name, 'gitsigns://') then
        if reference_win ~= nil then
          return
        end
        reference_win = win
      elseif current_win == nil then
        current_win = win
      end
    end
  end

  if current_win ~= nil and reference_win ~= nil then
    return { current_win = current_win, reference_win = reference_win }
  end
end

-- Validates that both sides of the current session still exist
local function valid_session(session)
  if session == nil or not vim.api.nvim_buf_is_valid(session.left_buf) or not vim.api.nvim_buf_is_valid(session.right_buf) then
    notify('One side of the diffview session is no longer available')
    return false
  end

  return true
end

-- Returns the opposite buffer for a native two-way diff session
local function other_buf(session)
  if not valid_session(session) then
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf == session.left_buf then
    return session.right_buf
  elseif current_buf == session.right_buf then
    return session.left_buf
  else
    notify('Current buffer is not part of the diffview session')
    return
  end
end

-- Runs a native diff command against the other side of the session
local function run_diff_action(session, command)
  local target_buf = other_buf(session)
  if target_buf == nil then
    return
  end

  local ok, err = pcall(vim.cmd, command .. ' ' .. target_buf)
  if not ok then
    notify(err, vim.log.levels.ERROR)
  end
end

-- Builds local mapping options for diffview buffers
local function keymap_opts(desc)
  return { buffer = true, desc = desc, silent = true }
end

-- Adds merge-oriented local mappings to both buffers in a session
local function set_buffer_keymaps(session)
  for _, buf in ipairs { session.left_buf, session.right_buf } do
    vim.api.nvim_buf_call(buf, function()
      vim.keymap.set('n', 'do', function()
        run_diff_action(session, 'diffget')
      end, keymap_opts('Get Hunk from Other'))
      vim.keymap.set('n', 'dp', function()
        run_diff_action(session, 'diffput')
      end, keymap_opts('Put Hunk to Other'))
    end)
  end
end

-- Removes diffview mappings from a buffer if it is still loaded
local function clear_buffer_keymaps(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  for _, lhs in ipairs { 'do', 'dp' } do
    pcall(vim.api.nvim_buf_del_keymap, buf, 'n', lhs)
  end
end

-- Opens the current file in a vertical native diff against another file
local function open_against_file(right_path)
  local left_path = vim.api.nvim_buf_get_name(0)
  if left_path == '' then
    notify('Current buffer has no file path')
    return
  end

  local left_win = vim.api.nvim_get_current_win()
  local left_buf = vim.api.nvim_get_current_buf()

  left_path = vim.fs.normalize(left_path)
  right_path = vim.fs.normalize(right_path)
  if left_path == right_path then
    notify('Cannot diff a file against itself')
    return
  end

  vim.cmd('vertical diffsplit ' .. vim.fn.fnameescape(right_path))

  active_session = {
    left_buf = left_buf,
    left_win = left_win,
    right_buf = vim.api.nvim_get_current_buf(),
    right_win = vim.api.nvim_get_current_win(),
  }
  set_diff_role(active_session.left_win, 'current')
  set_diff_role(active_session.right_win, 'reference')
  set_buffer_keymaps(active_session)
  require('config.highlights').refresh_diff_windows()
end

-- Opens the selected picker item as the right side of a diffview
local function confirm_selection(left_win, picker, item)
  item = item or picker:current()
  local right_path = item and Snacks.picker.util.path(item)
  picker:close()
  if right_path == nil then
    notify('No file selected')
    return
  end

  if not vim.api.nvim_win_is_valid(left_win) then
    notify('The original diffview window is no longer available')
    return
  end

  vim.api.nvim_set_current_win(left_win)
  open_against_file(right_path)
end

-- Picks a project file to diff against the current buffer
function M.open()
  if active_session ~= nil or gitsigns_session() ~= nil then
    M.close()
  end

  local left_path = vim.api.nvim_buf_get_name(0)
  if left_path == '' then
    notify('Current buffer has no file path')
    return
  end

  local left_win = vim.api.nvim_get_current_win()
  Snacks.picker.files {
    hidden = true,
    actions = {
      confirm = function(picker, item)
        confirm_selection(left_win, picker, item)
      end,
    },
  }
end

-- Clears the active diffview session and closes the comparison window
function M.close()
  local git_session = active_session == nil and gitsigns_session() or nil
  vim.cmd 'diffoff!'

  local session = active_session
  active_session = nil
  if session == nil then
    if git_session ~= nil then
      if vim.api.nvim_win_is_valid(git_session.reference_win) and normal_window_count() > 1 then
        pcall(vim.api.nvim_set_current_win, git_session.reference_win)
        pcall(vim.cmd.close)
      end

      if vim.api.nvim_win_is_valid(git_session.current_win) then
        pcall(vim.api.nvim_set_current_win, git_session.current_win)
      end
    end
    return
  end

  clear_diff_role(session.left_win)
  clear_diff_role(session.right_win)
  clear_buffer_keymaps(session.left_buf)
  clear_buffer_keymaps(session.right_buf)

  if vim.api.nvim_win_is_valid(session.right_win) and normal_window_count() > 1 then
    pcall(vim.api.nvim_set_current_win, session.right_win)
    pcall(vim.cmd.close)
  end

  if vim.api.nvim_win_is_valid(session.left_win) then
    pcall(vim.api.nvim_set_current_win, session.left_win)
  end
end

return M
