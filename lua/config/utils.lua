-- Provides shared utility helpers
local M = {}

local saved_cwd

-- Normalizes paths for stable cwd/root comparisons
local function normalize(path)
  local normalized = vim.fn.fnamemodify(path, ':p'):gsub('/$', '')
  return vim.fs.normalize(normalized)
end

-- Returns the current tab-local working directory
function M.cwd()
  return normalize(vim.fn.getcwd())
end

-- Returns the Git root containing path, or nil outside Git
function M.git_root(path)
  return vim.fs.root(normalize(path or M.cwd()), '.git')
end

-- Returns the session root as Git root when available, otherwise cwd
function M.session_root(path)
  local cwd = normalize(path or M.cwd())
  return normalize(M.git_root(cwd) or cwd)
end

-- Returns the current buffer directory, falling back to cwd for unnamed buffers
function M.buffer_dir(buf)
  local path = vim.api.nvim_buf_get_name(buf or 0)
  return path == '' and M.cwd() or normalize(vim.fn.fnamemodify(path, ':p:h'))
end

-- Returns the cwd that should be restored when toggling away from root
function M.true_cwd()
  local cwd = M.cwd()
  if cwd ~= M.session_root(cwd) then
    saved_cwd = cwd
    return cwd
  end

  return saved_cwd and vim.uv.fs_stat(saved_cwd) and saved_cwd or cwd
end

-- Toggles the current cwd between the remembered true cwd and session root
function M.toggle_cwd_root()
  local cwd = M.cwd()
  local root = M.session_root(cwd)
  local target = root

  if cwd == root then
    target = M.true_cwd()
  else
    saved_cwd = cwd
  end

  vim.cmd.cd(vim.fn.fnameescape(target))
  vim.notify('cwd: ' .. vim.fn.fnamemodify(target, ':~'), vim.log.levels.INFO)
end

return M
