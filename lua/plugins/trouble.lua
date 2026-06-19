return {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = vim.g.have_nerd_font and { 'nvim-tree/nvim-web-devicons' } or {},
    opts = {
      keys = {
        -- Inside Trouble: <CR> jumps, o jumps and closes, q closes, ? shows help.
        -- Split jumps match your window mappings where possible.
        ['<leader>\\'] = 'jump_vsplit',
        ['<leader>wv'] = 'jump_vsplit',
        ['<leader>-'] = 'jump_split',
        ['<leader>wb'] = 'jump_split',
      },
    },
    keys = {
      -- Diagnostics / quickfix:
      -- <leader>xx shows all workspace diagnostics.
      -- <leader>xX shows only diagnostics for the current buffer.
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },

      -- Code structure / LSP:
      -- <leader>cs opens document symbols. <leader>cl opens definitions,
      -- references, implementations, type definitions, and declarations.
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cS', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP ref/def (Trouble)' },

      -- To Do:
      { '<leader>xt', '<cmd>Trouble todo toggle filter.buf=0<cr>', desc = 'Todo Buffer (Trouble)' },
      { '<leader>xT', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      { '<leader>xe', '<cmd>Trouble todo toggle filter.buf=0 filter.tag={ERROR,WARN,WARNING}<cr>', desc = 'Error/Warn Buffer (Trouble)' },

      -- Lists:
      -- These show the existing location-list and quickfix-list entries in Trouble.
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },
}
