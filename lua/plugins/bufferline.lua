return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = vim.g.have_nerd_font and { 'nvim-tree/nvim-web-devicons' } or {},
    event = 'VeryLazy',
    opts = function()
      return {
        options = {
          diagnostics = 'nvim_lsp',
          always_show_bufferline = false,
          show_buffer_close_icons = false,
          show_close_icon = false,
          -- mode = "tab", -- this hides buffers from line, only show tabs
          separator_style = 'slant',
          numbers = function(opts)
            return string.format('%s·%s', opts.raise(opts.ordinal), opts.lower(opts.id))
          end,
          indicator = {
            style = 'underline',
          },
          groups = { items = {} },
          offsets = {
            {
              filetype = 'snacks_layout_box',
              separator = true,
            },
            {
              filetype = 'neo-tree',
              text = 'Explorer',
              text_align = 'center',
              separator = true,
            },
            {
              filetype = 'NvimTree',
              text = 'Explorer',
              text_align = 'center',
              separator = true,
            },
          },
          hover = {
            enabled = true,
            delay = 150,
            reveal = { 'close' },
          },
        },
      }
    end,
    config = function(_, opts)
      -- `bufferline.groups` is only available after lazy.nvim puts bufferline
      -- on runtimepath, so keep this require out of the plugin spec table.
      local groups = require 'bufferline.groups'
      opts.options.groups.items = {
        groups.builtin.pinned:with { icon = '' },
      }

      require('bufferline').setup(opts)
    end,
    keys = {
      { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
      { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
      { '<leader>vp', '<cmd>BufferLineMovePrev<cr>', desc = 'Move Buffer Left' },
      { '<leader>vn', '<cmd>BufferLineMoveNext<cr>', desc = 'Move Buffer Right' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin Buffer' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
      { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = 'Pick Buffer to Close' },
      { '<leader>bi', function() Snacks.bufdelete.invisible() end, desc = 'Delete Hidden Buffers' },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close Other Buffers' },
      { '<leader>bs', '<cmd>BufferLinePick<cr>', desc = 'Pick Buffer' },
      { '<leader>be', '<cmd>BufferLineSortByExtension<CR>', desc = 'Sort by Extension' },
      { '<leader>br', '<cmd>BufferLineSortByDirectory<CR>', desc = 'Sort by Directory' },
      { '<leader>bt', '<cmd>BufferLineSortByTabs<CR>', desc = 'Sort by Tab' },
      { '<leader>bb', '<cmd>BufferLinePick<CR>', desc = 'Jump to Buffer' },
      { '<leader>bh', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { '<leader>bl', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '<leader>b1', '<cmd>BufferLineGoToBuffer 1<cr>', desc = 'Buffer 1' },
      { '<leader>b2', '<cmd>BufferLineGoToBuffer 2<cr>', desc = 'Buffer 2' },
      { '<leader>b3', '<cmd>BufferLineGoToBuffer 3<cr>', desc = 'Buffer 3' },
      { '<leader>b4', '<cmd>BufferLineGoToBuffer 4<cr>', desc = 'Buffer 4' },
      { '<leader>b5', '<cmd>BufferLineGoToBuffer 5<cr>', desc = 'Buffer 5' },
      { '<leader>b6', '<cmd>BufferLineGoToBuffer 6<cr>', desc = 'Buffer 6' },
      { '<leader>b7', '<cmd>BufferLineGoToBuffer 7<cr>', desc = 'Buffer 7' },
      { '<leader>b8', '<cmd>BufferLineGoToBuffer 8<cr>', desc = 'Buffer 8' },
      { '<leader>b9', '<cmd>BufferLineGoToBuffer 9<cr>', desc = 'Buffer 9' },
      { '<leader>b$', '<cmd>BufferLineGoToBuffer -1<cr>', desc = 'Last Buffer' },
    },
  },
}
