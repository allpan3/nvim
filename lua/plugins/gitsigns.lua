-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      local set_gitsigns_hl = function()
        local palette = { add = '#42be65', change = '#78a9ff', staged_add = '#2d8549', staged_change = '#5577b3' }
        if vim.o.background == 'light' then
          palette = { add = '#137333', change = '#0969da', staged_add = '#6a8f72', staged_change = '#5f7fab' }
        end

        for _, group in ipairs { 'GitSignsAdd', 'GitSignsAddNr', 'GitSignsAddCul' } do
          vim.api.nvim_set_hl(0, group, { fg = palette.add })
        end

        for _, group in ipairs { 'GitSignsChange', 'GitSignsChangeNr', 'GitSignsChangeCul' } do
          vim.api.nvim_set_hl(0, group, { fg = palette.change })
        end

        for _, group in ipairs { 'GitSignsStagedAdd', 'GitSignsStagedAddNr', 'GitSignsStagedAddCul' } do
          vim.api.nvim_set_hl(0, group, { fg = palette.staged_add })
        end

        for _, group in ipairs { 'GitSignsStagedChange', 'GitSignsStagedChangeNr', 'GitSignsStagedChangeCul' } do
          vim.api.nvim_set_hl(0, group, { fg = palette.staged_change })
        end
      end

      set_gitsigns_hl()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('GitSignsThemeHighlights', { clear = true }),
        callback = set_gitsigns_hl,
      })
    end,
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      signs_staged = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },

      -- Enable this to override mini.diff's number, which doesn't have staged info
      numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
      -- signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`

      -- With this enabled, staged changes will be shown in darker color
      -- Select line and <leader>ga to stage partial hunks. Partial hunks cannot be unstaged (undo) by staging again.
      -- signs_staged_enable = false,

      max_file_length = 10000,
      attach_to_untracked = true,
      current_line_blame_opts = {
        -- ignore_whitespace = true,
        delay = 500,
      },
      preview_config = {
        border = 'rounded',
      },

      on_attach = function(buffer)
        if require('config.bigfile').is_big(buffer) then
          return false
        end

        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']h', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, 'Next Hunk')
        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[h', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, 'Prev Hunk')
        map('n', ']H', function()
          gs.nav_hunk 'last'
        end, 'Last Hunk')
        map('n', '[H', function()
          gs.nav_hunk 'first'
        end, 'First Hunk')
        map('n', '<leader>ga', gs.stage_hunk, 'Stage Hunk')
        map('v', '<leader>ga', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Stage hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset Hunk')
        -- unstaging a range currently doesn't work
        map('v', '<leader>gr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Reset hunk')
        map('n', '<leader>gA', gs.stage_buffer, 'Stage Buffer')
        map('n', '<leader>gR', gs.reset_buffer, 'Reset Buffer')
        map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo Stage Hunk') -- this is not unstage, it only undo the last call of stage_hunk
        map('n', '<leader>gU', gs.reset_buffer_index, 'Unstage Buffer')
        -- inline doesn't allow cursor movement
        map('n', '<leader>gp', gs.preview_hunk_inline, 'Preview Hunk Inline')
        -- map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        -- enter key chord twices to switch focus to the blame window, or do <leader>ww
        -- shows only the previous commit
        map('n', '<leader>gb', function()
          gs.blame_line { full = true }
        end, 'Blame Line')
        map('n', '<leader>gB', function()
          gs.blame()
        end, 'Blame Buffer')
        map('n', '<leader>gd', gs.diffthis, 'Diff against Index')
        map('n', '<leader>gD', function()
          gs.diffthis '~'
        end, 'Diff against Last Commit')
        map('n', '<leader>gq', gs.setqflist, 'Diff List Buffer')
        map('n', '<leader>gQ', function()
          gs.setqflist 'all'
        end, 'Diff List Repo')
        map('n', '<leader>ugb', gs.toggle_current_line_blame, 'Toggle Blame Inline')
        map('n', '<leader>ugd', gs.toggle_deleted, 'Toggle Diff')
        map('n', '<leader>ugw', gs.toggle_word_diff, 'Toggle Word Diff')
        map('n', '<leader>ugl', gs.toggle_linehl, 'Toggle Line Highlight')
        map('n', '<leader>ugn', gs.toggle_numhl, 'Toggle Number Highlight') -- this is currently controlled by mini.diff so not working
        map('n', '<leader>ugs', gs.toggle_signs, 'Toggle Signcolumn')
        -- text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Hunk')
      end,
    },
  },
}
