-- Session management. This saves your session in the background,
-- keeping track of open buffers, window arrangement, and more.
-- You can restore sessions when returning through the dashboard.
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  init = function()
    local is_sidekick_cli = function(buf, win)
      if vim.bo[buf].filetype == 'sidekick_terminal' or vim.b[buf].sidekick_cli ~= nil then
        return true
      end

      return win ~= nil and vim.w[win].sidekick_cli ~= nil
    end

    local remove_sidekick_cli = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if is_sidekick_cli(buf, win) then
          if #vim.api.nvim_list_wins() == 1 then
            vim.api.nvim_win_call(win, function()
              vim.cmd.enew()
            end)
          else
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and is_sidekick_cli(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
    end

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('PersistenceSidekick', { clear = true }),
      pattern = 'PersistenceSavePre',
      callback = remove_sidekick_cli,
    })
  end,
  opts = {},
  -- stylua: ignore
  keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
