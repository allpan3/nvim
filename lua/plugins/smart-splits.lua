return {
  {
    'mrjones2014/smart-splits.nvim',
    opts = {
      default_amount = 3,
      cursor_follows_swapped_bufs = true,
    },
    keys = {
      {
        '<leader>wh',
        function()
          require('smart-splits').resize_left()
        end,
        desc = 'Resize Window Left',
      },
      {
        '<leader>wj',
        function()
          require('smart-splits').resize_down()
        end,
        desc = 'Resize Window Down',
      },
      {
        '<leader>wk',
        function()
          require('smart-splits').resize_up()
        end,
        desc = 'Resize Window Up',
      },
      {
        '<leader>wl',
        function()
          require('smart-splits').resize_right()
        end,
        desc = 'Resize Window Right',
      },

      {
        '<leader>vh',
        function()
          require('smart-splits').swap_buf_left()
        end,
        desc = 'Swap Buffer Left',
      },
      {
        '<leader>vj',
        function()
          require('smart-splits').swap_buf_down()
        end,
        desc = 'Swap Buffer Down',
      },
      {
        '<leader>vk',
        function()
          require('smart-splits').swap_buf_up()
        end,
        desc = 'Swap Buffer Up',
      },
      {
        '<leader>vl',
        function()
          require('smart-splits').swap_buf_right()
        end,
        desc = 'Swap Buffer Right',
      },
    },
  },
}
