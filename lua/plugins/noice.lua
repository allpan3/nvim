return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = {
      notify = {
        enabled = true,
        view = 'notify',
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      bottom_search = true,
      presets = {
        command_palette = {
          views = {
            cmdline_popup = {
              position = {
                row = '30%',
                col = '50%',
              },
            },
            cmdline_popupmenu = {
              position = {
                row = '55%',
                col = '50%',
              },
            },
          },
        },
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      -- { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { '<leader>nl', function() require('noice').cmd 'last' end, desc = 'Noice Last Message' },
      { '<leader>nh', function() require('noice').cmd 'history' end, desc = 'Noice History' },
      { '<leader>na', function() require('noice').cmd 'all' end, desc = 'Noice All' },
      { '<leader>nd', function() require('noice').cmd 'dismiss' end, desc = 'Dismiss All' },
      { '<leader>sn', function() require('noice').cmd 'pick' end, desc = 'Noice Picker' },
      -- { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      -- { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
  },
}
