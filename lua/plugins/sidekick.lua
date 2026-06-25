-- Configures Sidekick.nvim integration and keymaps
-- Applies the shared diff palette to Sidekick next-edit suggestion groups
local function set_nes_highlights()
  local palette = require('config.highlights').diff_palette()

  vim.api.nvim_set_hl(0, 'SidekickDiffContext', { bg = palette.context_buf_bg })
  vim.api.nvim_set_hl(0, 'SidekickDiffAdd', { fg = palette.change_buf_fg, bg = palette.change_buf_bg, bold = true })
  vim.api.nvim_set_hl(0, 'SidekickDiffDelete', { fg = palette.delete_fg, bg = palette.delete_bg })
end

-- Keeps Sidekick next-edit suggestion highlights readable after setup
local function setup_nes_highlights()
  set_nes_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Keep Sidekick NES highlights aligned with diff palette',
    group = vim.api.nvim_create_augroup('sidekick-nes-highlights', { clear = true }),
    callback = function()
      vim.schedule(set_nes_highlights)
    end,
  })
end

return {
  {
    'folke/sidekick.nvim',
    event = 'VeryLazy',
    cmd = 'Sidekick',
    opts = {
      cli = {
        mux = {
          backend = 'zellij',
          -- disable the mux integration if we're running inside zellij, since it causes issues with the CLI
          enabled = vim.env.ZELLIJ == nil,
        },
      },
    },
    -- Sets up Sidekick and its next-edit suggestion highlights
    config = function(_, opts)
      require('sidekick').setup(opts)
      setup_nes_highlights()
    end,
    keys = {
      {
        '<tab>',
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>' -- fallback to normal tab
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
      {
        '<C-.>',
        function()
          require('sidekick.cli').focus()
        end,
        mode = { 'n', 't', 'i', 'x' },
        desc = 'Sidekick Focus',
      },
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle CLI',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        desc = 'Sidekick Select CLI',
      },
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Sidekick Detach CLI',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Send This',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Sidekick Send File',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = 'x',
        desc = 'Sidekick Send Selection',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
      {
        '<leader>ac',
        function()
          require('sidekick.cli').toggle { name = 'codex', focus = true }
        end,
        desc = 'Sidekick Toggle Codex',
      },
    },
  },
}
