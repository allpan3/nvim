local M = {}

M.size = 1.5 * 1024 * 1024
M.huge_size = 100 * 1024 * 1024

local saved_global_options = nil

local function file_size(path)
  if not path or path == '' then
    return -1
  end

  local ok, size = pcall(vim.fn.getfsize, path)
  return ok and size or -1
end

function M.is_big(buf)
  buf = buf or 0

  if vim.b[buf].bigfile or vim.bo[buf].filetype == 'bigfile' then
    return true
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return false
  end

  return file_size(name) > M.size
end

function M.is_huge(buf)
  buf = buf or 0

  if vim.b[buf].hugefile then
    return true
  end

  local name = vim.api.nvim_buf_get_name(buf)
  return file_size(name) > M.huge_size
end

function M.mark(buf)
  buf = buf or 0
  vim.b[buf].bigfile = true
end

function M.prepare_buffer(buf, path)
  buf = buf or 0
  path = path or vim.api.nvim_buf_get_name(buf)

  local size = file_size(path)
  if size <= M.size then
    return false
  end

  M.mark(buf)
  vim.b[buf].hugefile = size > M.huge_size

  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false
  vim.bo[buf].synmaxcol = 256

  if vim.b[buf].hugefile then
    vim.bo[buf].bufhidden = 'unload'
  end

  return true
end

function M.enable_swapfile_if_safe(buf)
  buf = buf or 0

  if vim.bo[buf].buftype ~= '' or M.is_big(buf) then
    return false
  end

  vim.bo[buf].swapfile = true
  return true
end

function M.disable_buffer_features(buf)
  buf = buf or 0
  M.mark(buf)

  vim.b[buf].completion = false
  vim.b[buf].minianimate_disable = true
  vim.b[buf].minidiff_disable = true
  vim.b[buf].minihipatterns_disable = true

  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false
  vim.bo[buf].synmaxcol = 256
  vim.bo[buf].syntax = 'OFF'

  vim.diagnostic.enable(false, { bufnr = buf })

  if vim.fn.exists(':NoMatchParen') ~= 0 then
    pcall(vim.cmd, 'NoMatchParen')
  end

  if vim.treesitter.stop then
    pcall(vim.treesitter.stop, buf)
  end

  local function detach_lsp()
    if vim.api.nvim_buf_is_valid(buf) and vim.lsp.get_clients then
      for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
        pcall(vim.lsp.buf_detach_client, buf, client.id)
      end
    end
  end

  detach_lsp()
  vim.schedule(detach_lsp)
end

function M.enter_buffer(buf)
  buf = buf or 0

  if not M.is_big(buf) then
    return
  end

  vim.wo.cursorline = false
  vim.wo.foldmethod = 'manual'
  vim.wo.list = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = 'no'
  vim.wo.statuscolumn = ''
  vim.wo.wrap = false
  vim.wo.conceallevel = 0

  if M.is_huge(buf) then
    if not saved_global_options then
      saved_global_options = {
        incsearch = vim.o.incsearch,
        lazyredraw = vim.o.lazyredraw,
        redrawtime = vim.o.redrawtime,
        wrapscan = vim.o.wrapscan,
      }
    end

    vim.o.incsearch = false
    vim.o.lazyredraw = true
    vim.o.redrawtime = 200
    vim.o.wrapscan = false
  end
end

function M.leave_buffer(buf)
  buf = buf or 0

  if not M.is_huge(buf) or not saved_global_options then
    return
  end

  for option, value in pairs(saved_global_options) do
    vim.o[option] = value
  end
  saved_global_options = nil
end

return M
