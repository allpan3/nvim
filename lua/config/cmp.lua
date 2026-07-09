-- Coordinates completion helper actions for blink.cmp and native inline completion
local M = {}

local ns = vim.api.nvim_create_namespace 'config.cmp.inline_completion'
local states = {}
local autocmd_group = vim.api.nvim_create_augroup('config-cmp-inline-completion', { clear = false })

-- Clears retained inline completion preview for a buffer
local function clear_preview(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

-- Extracts the insertable text from a native inline completion item
local function item_text(item)
  local insert_text = item.insert_text
  if type(insert_text) == 'string' then
    return insert_text
  end

  if type(insert_text) == 'table' and type(insert_text.value) == 'string' then
    return insert_text.value
  end

  return nil
end

-- Returns the byte offset of the cursor inside the inline insertion text
local function cursor_text_offset(item, cursor)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]
  local range = item.range

  if not range or range.start_row ~= cursor_row then
    return 0
  end

  return math.max(0, cursor_col - range.start_col)
end

-- Clears retained inline completion state and preview for a buffer
local function clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  states[bufnr] = nil
  clear_preview(bufnr)
end

-- Converts a native inline completion range into retained byte and LSP positions
local function range_from_item(item, cursor)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]
  local range = item.range

  if not range then
    return {
      start_row = cursor_row,
      start_col = cursor_col,
      end_row = cursor_row,
      end_col = cursor_col,
      lsp = {
        start = { line = cursor_row, character = cursor_col },
        ['end'] = { line = cursor_row, character = cursor_col },
      },
    }
  end

  local start_row, start_col, end_row, end_col = range:to_extmark()
  local ok, lsp_range = pcall(function()
    return range:to_lsp 'utf-8'
  end)
  if not ok then
    lsp_range = {
      start = { line = start_row, character = start_col },
      ['end'] = { line = end_row, character = end_col },
    }
  end

  if lsp_range['end'].line == cursor_row and lsp_range['end'].character < cursor_col then
    lsp_range['end'].character = cursor_col
    end_col = cursor_col
  end

  return {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
    lsp = lsp_range,
  }
end

-- Moves the cursor to the end of inserted UTF-8 text
local function set_cursor_after_text(range, text)
  local lines = vim.split(text, '\n', { plain = true })
  local last_col = #lines[#lines]

  if #lines == 1 then
    last_col = range.start.character + last_col
  end

  vim.api.nvim_win_set_cursor(0, { range.start.line + #lines, last_col })
end

-- Returns the retained state for the current buffer when the cursor still matches it
local function current_state()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = states[bufnr]
  if not state then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]
  if state.end_row ~= cursor_row or state.end_col ~= cursor_col then
    clear(bufnr)
    return nil
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, state.start_row, state.start_row + 1, false)[1]
  if not line or #line < state.start_col then
    clear(bufnr)
    return nil
  end

  return state
end

-- Executes a completion command after custom inline text insertion
local function exec_item_command(item, bufnr)
  if not item.command or not item.client_id then
    return
  end

  local client = vim.lsp.get_client_by_id(item.client_id)
  if client then
    client:exec_cmd(item.command, { bufnr = bufnr })
  end
end

-- Applies text with the same edit shape used by copilot.lua
local function apply_inline_text(state, text)
  local bufnr = vim.api.nvim_get_current_buf()
  local range = state.lsp

  vim.cmd 'let &undolevels=&undolevels'

  local lines = vim.split(text, '\n', { plain = true })
  local edit_text = text

  if #lines[#lines] == 0 then
    edit_text = edit_text .. '\n'
  end

  vim.lsp.util.apply_text_edits({ { range = range, newText = edit_text } }, bufnr, 'utf-8')
  set_cursor_after_text(range, text)
  exec_item_command(state, bufnr)
end

-- Applies an accepted chunk after keymap evaluation finishes
local function apply_later(state, text, after)
  vim.schedule(function()
    local ok = pcall(function()
      apply_inline_text(state, text)
      after(state, text)
    end)

    if not ok then
      clear()
    end
  end)
end

-- Advances retained state after accepting a partial chunk
local function update_state_after_accept(state, accepted_text)
  if #accepted_text >= #state.text then
    clear()
    return
  end

  local lines = vim.split(accepted_text, '\n', { plain = true })
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]

  if #lines > 1 then
    for _ = 1, #lines - 1 do
      local newline = state.text:find('\n', 1, true)
      if not newline then
        clear()
        return
      end

      state.text = state.text:sub(newline + 1)
    end

    state.start_row = cursor_row
    state.start_col = 0
  end

  state.end_row = cursor_row
  state.end_col = cursor_col
  state.lsp.start.line = state.start_row
  state.lsp.start.character = state.start_col
  state.lsp['end'].line = state.end_row
  state.lsp['end'].character = state.end_col

  if #state.text <= math.max(0, state.end_col - state.start_col) then
    clear()
    return
  end

  clear_preview()
end

-- Creates retained state from a native inline completion item
local function state_from_item(item, text, cursor)
  local range = range_from_item(item, cursor)

  return {
    text = text,
    start_row = range.start_row,
    start_col = range.start_col,
    end_row = range.end_row,
    end_col = range.end_col,
    lsp = range.lsp,
    command = item.command,
    client_id = item.client_id,
  }
end

-- Accepts text from retained state and refreshes the local ghost text
local function accept_state(state, modifier)
  local offset = math.max(0, state.end_col - state.start_col)
  if #state.text <= offset then
    clear()
    return false
  end

  local partial = modifier(state.text, offset)
  if not partial or partial == '' or #partial <= offset then
    partial = state.text
  end

  apply_later(state, partial, update_state_after_accept)
  return true
end

-- Accepts native inline text after a Copilot-style text modifier narrows it
local function accept_partial(modifier)
  local state = current_state()
  if state then
    return accept_state(state, modifier)
  end

  if not (vim.lsp.inline_completion and vim.lsp.inline_completion.get) then
    return false
  end

  local accept_cursor = vim.api.nvim_win_get_cursor(0)
  return vim.lsp.inline_completion.get {
    on_accept = function(item)
      local text = item_text(item)
      if not text or text == '' then
        return item
      end

      local offset = cursor_text_offset(item, accept_cursor)
      local partial = modifier(text, offset)
      if not partial or partial == '' or #partial <= offset then
        return item
      end

      local retained = state_from_item(item, text, accept_cursor)
      states[vim.api.nvim_get_current_buf()] = retained
      local ok = pcall(function()
        apply_inline_text(retained, partial)
        update_state_after_accept(retained, partial)
      end)

      if not ok then
        clear()
      end

      return nil
    end,
  }
end

-- Returns the Copilot-style next word slice from inline text
local function partial_word(text, offset)
  local _, char_idx = text:find('%s*%p*[^%s%p]*%s*', offset + 1)
  if char_idx then
    return text:sub(1, char_idx)
  end

  return nil
end

-- Returns the Copilot-style current line slice from inline text
local function partial_line(text, offset)
  local next_char = text:sub(offset + 1, offset + 1)
  local _, char_idx = text:find(next_char == '\n' and '\n%s*[^\n]*\n%s*' or '\n%s*', offset)
  if char_idx then
    return text:sub(1, char_idx)
  end

  return nil
end

-- Accepts the complete active inline completion
function M.accept_full()
  local state = current_state()
  if state then
    apply_later(state, state.text, function()
      clear()
    end)
    return true
  end

  if vim.lsp.inline_completion and vim.lsp.inline_completion.get then
    return vim.lsp.inline_completion.get()
  end

  return false
end

-- Accepts the current line from inline ghost text
function M.accept_line()
  return accept_partial(partial_line)
end

-- Accepts the next word from inline ghost text
function M.accept_word()
  return accept_partial(partial_word)
end

-- Sets up buffer-local cleanup for retained inline completion state
function M.setup_inline_completion(bufnr)
  vim.api.nvim_clear_autocmds { group = autocmd_group, buffer = bufnr }
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufLeave', 'BufUnload' }, {
    buffer = bufnr,
    group = autocmd_group,
    callback = function(event)
      clear(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd('InsertCharPre', {
    buffer = bufnr,
    group = autocmd_group,
    callback = function(event)
      clear(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd('CursorMovedI', {
    buffer = bufnr,
    group = autocmd_group,
    callback = function(event)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) and states[event.buf] then
          current_state()
        end
      end)
    end,
  })
end

-- Clears retained inline completion state for a buffer
function M.clear(bufnr)
  clear(bufnr)
end

return M
