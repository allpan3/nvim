local M = {}

local function completion_ghost_text_fg()
  return vim.o.background == 'light' and '#aab1bc' or '#575a60'
end

local function set_completion_ghost_text(groups)
  local opts = {
    fg = completion_ghost_text_fg(),
    bg = 'NONE',
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

function M.set_lsp_inline_completion()
  set_completion_ghost_text { 'ComplHint', 'ComplHintMore' }
end

function M.set_blink_ghost_text()
  set_completion_ghost_text { 'BlinkCmpGhostText' }
end

return M
