return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    check_ts = true, -- use Tree-sitter checks when available
    disable_filetype = { 'bigfile', 'snacks_picker', 'vim' },
    fast_wrap = {},
  },
  keys = {
    {
      '<leader>up',
      function()
        require('nvim-autopairs').toggle()
      end,
      desc = 'Disable Autopairs',
    },
  },
  config = function(_, opts)
    local autopairs = require 'nvim-autopairs'

    autopairs.setup(opts)
    autopairs.get_rules('`')[1].not_filetypes = { 'verilog', 'systemverilog' }
  end,
}
