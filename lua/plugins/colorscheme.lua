-- Change this string to swap your theme. 
-- 'oxocarbon', 'carbonfox', 'nightfox', 'dayfox'
local active_theme = 'oxocarbon'

return {
  {
    'EdenEast/nightfox.nvim',
    -- Make sure ALL themes have priority = 1000 so the active one loads first
    priority = 1000,
    opts = {
      specs = {
        carbonfox = {
          syntax = {
            -- conditional = "magenta.bright",
            -- keyword = "magenta.base",
          },
        },
      },
      groups = {
        carbonfox = {
          WinSeparator = { fg = 'palette.bg3' },
          FloatBorder = { fg = 'palette.bg4' },
          MatchParen = { fg = 'palette.pink', style = 'bold,underline' },
        },
      },
      palettes = {
        carbonfox = {
          comment = '#808892',
          sel0 = '#353535',
        },
      },
    },
    config = function(_, opts)
      -- Apply your settings
      require('nightfox').setup(opts)

      -- Only activate the colorscheme if it belongs to the nightfox family
      if active_theme:match("fox") then
        local status, _ = pcall(vim.cmd.colorscheme, active_theme)
        if not status then vim.cmd.colorscheme('habamax') end
      end
    end,
  },

  {
    'allpan3/oxocarbon.nvim',
    priority = 1000,
    config = function()
      -- Only activate the colorscheme if it matches oxocarbon
      if active_theme == 'oxocarbon' then
        local status, _ = pcall(vim.cmd.colorscheme, active_theme)
        if not status then vim.cmd.colorscheme('habamax') end
      end
    end,
  },
}
