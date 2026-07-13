-- Provides shared highlight helpers for completion, mini.diff, and native diff windows
local M = {}

local diff_window_groups = {
  DiffAdd = 'ConfigDiffAdd',
  DiffChange = 'ConfigDiffChange',
  DiffDelete = 'ConfigDiffDelete',
  DiffText = 'ConfigDiffText',
}

local directional_diff_window_groups = {
  current = diff_window_groups,
  reference = {
    DiffAdd = 'ConfigDiffDelete',
    DiffChange = 'ConfigDiffReferenceChange',
    DiffDelete = 'ConfigDiffReferenceAddGap',
    DiffText = 'ConfigDiffReferenceText',
  },
}

local diff_role_var = 'config_diff_role'

-- Returns the readable ghost text color for the active background mode
local function completion_ghost_text_fg()
  return vim.o.background == 'light' and '#aab1bc' or '#575a60'
end

-- Applies the shared completion ghost text style to related groups
local function set_completion_ghost_text(groups)
  local opts = {
    fg = completion_ghost_text_fg(),
    bg = 'NONE',
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Returns the shared diff palette used by mini.diff and native diff windows
function M.diff_palette()
  local normal_fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg or (vim.o.background == 'light' and 0x24292f or 0xd0d0d0)
  normal_fg = string.format('#%06x', normal_fg)

  if vim.o.background == 'light' then
    return {
      add_bg = '#d8f5e4',
      change_buf_bg = '#bff0d2',
      change_buf_fg = '#07543e',
      change_ref_bg = '#ffd8e1',
      change_ref_fg = '#812033',
      context_buf_bg = '#eefaf3',
      context_ref_bg = '#fff1f4',
      context_ref_fg = normal_fg,
      delete_bg = '#ffe1e8',
      delete_fg = '#8a2738',
    }
  end

  return {
    add_bg = '#18372c',
    change_buf_bg = '#146044',
    change_buf_fg = '#d7ffe9',
    change_ref_bg = '#6b2a3a',
    change_ref_fg = '#ffe0e8',
    context_buf_bg = '#17251f',
    context_ref_bg = '#271e25',
    context_ref_fg = normal_fg,
    delete_bg = '#3d2029',
    delete_fg = '#ffd4df',
  }
end

-- Removes native diff highlight remaps from one winhighlight value
local function without_diff_window_highlights(value)
  local entries = {}

  for _, entry in ipairs(vim.split(value or '', ',', { plain = true, trimempty = true })) do
    local source = entry:match '^([^:]+):'
    if source ~= nil and diff_window_groups[source] == nil then
      table.insert(entries, entry)
    end
  end

  return table.concat(entries, ',')
end

-- Adds native diff highlight remaps to one winhighlight value
local function with_diff_window_highlights(value, groups)
  local entries = { without_diff_window_highlights(value) }

  for source, target in pairs(groups) do
    table.insert(entries, source .. ':' .. target)
  end

  return table.concat(vim.tbl_filter(function(entry)
    return entry ~= ''
  end, entries), ',')
end

-- Returns the explicit role assigned by the managed file comparison
local function explicit_diff_role(win)
  local ok, role = pcall(vim.api.nvim_win_get_var, win, diff_role_var)
  if ok and directional_diff_window_groups[role] ~= nil then
    return role
  end
end

-- Infers current and reference roles for a two-way Gitsigns diff
local function gitsigns_diff_role(win)
  local tab = vim.api.nvim_win_get_tabpage(win)
  local reference_win = nil

  for _, peer in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.wo[peer].diff then
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(peer))
      if vim.startswith(name, 'gitsigns://') then
        if reference_win ~= nil then
          return
        end
        reference_win = peer
      end
    end
  end

  if reference_win == nil then
    return
  end

  return win == reference_win and 'reference' or 'current'
end

-- Returns a directional role only for managed two-way comparisons
local function diff_role(win)
  return explicit_diff_role(win) or gitsigns_diff_role(win)
end

-- Applies or removes local diff highlights for one window
local function refresh_diff_window(win)
  if vim.wo[win].diff then
    local groups = directional_diff_window_groups[diff_role(win)] or diff_window_groups
    vim.wo[win].winhighlight = with_diff_window_highlights(vim.wo[win].winhighlight, groups)
  else
    pcall(vim.api.nvim_win_del_var, win, diff_role_var)
    vim.wo[win].winhighlight = without_diff_window_highlights(vim.wo[win].winhighlight)
  end
end

-- Refreshes all visible native diff windows
function M.refresh_diff_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      refresh_diff_window(win)
    end
  end
end

-- Applies the shared palette to mini.diff's overlay groups
function M.set_mini_diff_overlay()
  local palette = M.diff_palette()

  vim.api.nvim_set_hl(0, 'MiniDiffOverAdd', { bg = palette.add_bg })
  vim.api.nvim_set_hl(0, 'MiniDiffOverChange', { fg = palette.change_ref_fg, bg = palette.change_ref_bg, bold = true })
  vim.api.nvim_set_hl(0, 'MiniDiffOverChangeBuf', { fg = palette.change_buf_fg, bg = palette.change_buf_bg, bold = true })
  vim.api.nvim_set_hl(0, 'MiniDiffOverContext', { fg = palette.context_ref_fg, bg = palette.context_ref_bg })
  vim.api.nvim_set_hl(0, 'MiniDiffOverContextBuf', { bg = palette.context_buf_bg })
  vim.api.nvim_set_hl(0, 'MiniDiffOverDelete', { fg = palette.delete_fg, bg = palette.delete_bg })
end

-- Applies the shared palette to private native diff window groups
function M.set_diff_windows()
  local palette = M.diff_palette()

  vim.api.nvim_set_hl(0, 'ConfigDiffAdd', { bg = palette.add_bg })
  vim.api.nvim_set_hl(0, 'ConfigDiffChange', { bg = palette.context_buf_bg })
  vim.api.nvim_set_hl(0, 'ConfigDiffText', { fg = palette.change_buf_fg, bg = palette.change_buf_bg, bold = true })
  vim.api.nvim_set_hl(0, 'ConfigDiffDelete', { fg = palette.delete_fg, bg = palette.delete_bg })
  vim.api.nvim_set_hl(0, 'ConfigDiffReferenceChange', { fg = palette.context_ref_fg, bg = palette.context_ref_bg })
  vim.api.nvim_set_hl(0, 'ConfigDiffReferenceText', { fg = palette.change_ref_fg, bg = palette.change_ref_bg, bold = true })
  vim.api.nvim_set_hl(0, 'ConfigDiffReferenceAddGap', { fg = palette.change_buf_fg, bg = palette.add_bg })
end

-- Keeps native diff windows readable without changing global Diff groups
function M.setup_diff_windows()
  local group = vim.api.nvim_create_augroup('native-diff-window-highlights', { clear = true })

  -- Rebuilds diff groups and reapplies them to visible diff windows
  local function refresh()
    M.set_diff_windows()
    vim.schedule(M.refresh_diff_windows)
  end

  refresh()
  vim.api.nvim_create_autocmd({ 'ColorScheme', 'DiffUpdated', 'WinEnter' }, {
    desc = 'Keep native diff windows aligned with mini.diff',
    group = group,
    callback = refresh,
  })
end

-- Applies LSP inline completion ghost text highlights
function M.set_lsp_inline_completion()
  set_completion_ghost_text { 'ComplHint', 'ComplHintMore' }
end

-- Applies blink completion ghost text highlights
function M.set_blink_ghost_text()
  set_completion_ghost_text { 'BlinkCmpGhostText' }
end

return M
