return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      -- Keep entries ordered by key instead of prioritizing buffer-local mappings
      -- or pushing groups after direct mappings.
      sort = { 'alphanum' },
      -- Space is a built-in normal-mode motion, so which-key's auto triggers
      -- won't create a trigger for it unless it is listed explicitly.
      triggers = {
        { '<auto>', mode = 'nixsotc' },
        { '<leader>', mode = { 'n', 'v' } },
        { 'm', mode = { 'n', 'v' } },
      },
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        rules = vim.g.have_nerd_font and {
          { pattern = 'profiler', icon = ' ', color = false },
          { pattern = 'command', icon = ' ', color = false },
          { pattern = 'keyword', icon = ' ', color = false },
          { pattern = 'flash', icon = '󰉁 ', color = false },
          { pattern = '%f[%a]prev', icon = ' ', color = false },
          { pattern = '%f[%a]previous', icon = ' ', color = false },
          { pattern = '%f[%a]left', icon = ' ', color = false },
          { pattern = '%f[%a]next', icon = ' ', color = false },
          { pattern = '%f[%a]right', icon = ' ', color = false },
          { pattern = '%f[%a]up', icon = ' ', color = false },
          { pattern = '%f[%a]down', icon = ' ', color = false },
          { pattern = '%f[%a]last', icon = ' ', color = false },
          { pattern = '%f[%a]end', icon = ' ', color = false },
          { pattern = '%f[%a]goto', icon = ' ', color = false },
          { pattern = '%f[%a]go to', icon = ' ', color = false },
          { pattern = '%f[%a]move', icon = ' ', color = false },
          { pattern = '%f[%a]fold', icon = ' ', color = false },
          { pattern = '%f[%a]surround', icon = ' ', color = false },
          { pattern = '%f[%a]around', icon = '󰺖 ', color = false },
          { pattern = '%f[%a]inside', icon = ' ', color = false },
          { pattern = '%f[%a]add', icon = ' ', color = false },
          { pattern = '%f[%a]delete', icon = ' ', color = false },
          { pattern = '%f[%a]replace', icon = ' ', color = false },
          { pattern = '%f[%a]update', icon = ' ', color = false },
          { pattern = '%f[%a]highlight', icon = ' ', color = false },
          { pattern = '%f[%a]with', icon = ' ', color = false },
          { pattern = '%f[%a]reference', icon = ' ', color = false },
          { pattern = '%f[%a]class', icon = ' ', color = false },
          { pattern = '%f[%a]function', icon = '󰊕 ', color = false },
          { pattern = '%f[%a]method', icon = '󰊕 ', color = false },
          { pattern = '%f[%a]digit', icon = '󰎠 ', color = false },
          { pattern = '%f[%a]camelcase', icon = '󱔎 ', color = false },
          { pattern = '%f[%a]snake_case', icon = '󱔎 ', color = false },
          { pattern = '%f[%a]indent', icon = ' ', color = false },
          { pattern = '%f[%a]quote', icon = ' ', color = false },
          { pattern = '%f[%a]tag', icon = ' ', color = false },
          { pattern = '%f[%a]use/call', icon = ' ', color = false },
          { pattern = '%f[%a]block', icon = '󰅪 ', color = false },
          { pattern = '%f[%a]conditional', icon = ' ', color = false },
          { pattern = '%f[%a]loop', icon = ' ', color = false },
        } or {},
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
        { '<leader>a', group = 'ai' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug' },
        { '<leader>f', group = 'file/find' },
        { '<leader>g', group = 'git' },
        { '<leader>n', group = 'noice' },
        { '<leader>p', group = 'profiler' },
        { '<leader>q', group = 'quit/session' },
        { '<leader>s', group = 'search' },
        { '<leader>ug', group = 'git' },
        { '<leader>u', group = 'ui' },
        { '<leader>v', group = 'move' },
        {
          '<leader>w',
          group = 'windows',
          proxy = '<c-w>',
          expand = function()
            return require('which-key.extras').expand.win()
          end,
        },
        { '<leader>x', group = 'diagnostics/quickfix' },
        { '[', group = 'prev' },
        { ']', group = 'next' },
        { 'g', group = 'goto' },
        { 'm', group = 'surround', mode = { 'n', 'v' } },
        { 'z', group = 'fold' },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
    },
  },
}
