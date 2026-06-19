local diagnostic_icons = vim.g.have_nerd_font and {
  error = ' ',
  warn = ' ',
  info = ' ',
  hint = ' ',
} or {
  error = 'E:',
  warn = 'W:',
  info = 'I:',
  hint = 'H:',
}

local git_icons = vim.g.have_nerd_font and {
  added = ' ',
  modified = ' ',
  removed = ' ',
} or {
  added = '+',
  modified = '~',
  removed = '-',
}

local copilot_icons = vim.g.have_nerd_font
    and {
      Error = { ' ', 'DiagnosticError' },
      Inactive = { ' ', 'MsgArea' },
      Warning = { ' ', 'DiagnosticWarn' },
      Normal = { ' ', 'Special' },
    }
  or {
    Error = { 'CP!', 'DiagnosticError' },
    Inactive = { 'CP', 'MsgArea' },
    Warning = { 'CP?', 'DiagnosticWarn' },
    Normal = { 'CP', 'Special' },
  }

local function hl_color(name, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl[attr] then
    return string.format('#%06x', hl[attr])
  end
end

local function oxocarbon_lualine_y_color()
  if vim.g.colors_name ~= 'oxocarbon' then
    return
  end

  return {
    fg = hl_color('StatusLine', 'fg') or hl_color('Normal', 'fg'),
    bg = hl_color('StatusLineNC', 'bg') or hl_color('CursorLine', 'bg'),
  }
end

local function oxocarbon_lualine_branch_color()
  if vim.g.colors_name ~= 'oxocarbon' then
    return
  end

  return {
    fg = hl_color('Directory', 'fg') or hl_color('StatusLine', 'fg') or hl_color('Normal', 'fg'),
    bg = hl_color('StatusLineNC', 'bg') or hl_color('CursorLine', 'bg'),
  }
end

local function lualine_theme()
  if vim.g.colors_name ~= 'oxocarbon' then
    return 'auto'
  end

  local ok, theme = pcall(require('lualine.utils.loader').load_theme, 'auto')
  if not ok or type(theme) ~= 'table' then
    return 'auto'
  end

  theme = vim.deepcopy(theme)

  local branch_color = oxocarbon_lualine_branch_color()
  if branch_color then
    for _, mode in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive' } do
      if theme[mode] and theme[mode].b then
        theme[mode].b = vim.tbl_extend('force', theme[mode].b, branch_color)
      end
    end
  end

  return theme
end

local function get_root()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local lsp_root = client and (client.root_dir or (client.config and client.config.root_dir))

  return vim.fs.normalize(lsp_root or vim.fs.root(0, { '.git', 'lua', 'package.json', 'pyproject.toml', 'Cargo.toml', 'go.mod' }) or vim.fn.getcwd())
end

local function pretty_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    return ''
  end

  path = vim.fs.normalize(path)

  for _, base in ipairs { vim.fs.normalize(vim.fn.getcwd()), get_root() } do
    if vim.startswith(path, base .. '/') then
      path = path:sub(#base + 2)
      break
    end
  end

  local parts = vim.split(path, '/', { plain = true, trimempty = true })
  if #parts > 3 then
    path = table.concat({ parts[1], '…', parts[#parts - 1], parts[#parts] }, '/')
  end

  if vim.bo.readonly or not vim.bo.modifiable then
    path = path .. (vim.g.have_nerd_font and ' 󰌾 ' or ' [RO]')
  end

  return path
end

local function add_trouble_symbols(opts)
  local symbols

  -- Shows the current document symbol path in the statusline when an LSP
  -- provides symbols for the buffer. Disable per buffer with:
  --   :let b:trouble_lualine = v:false
  local function get_symbols()
    if symbols then
      return symbols
    end

    if not package.loaded.trouble then
      return
    end

    local ok, trouble = pcall(require, 'trouble')
    if not ok then
      return
    end

    symbols = trouble.statusline {
      mode = 'lsp_document_symbols',
      groups = {},
      title = false,
      filter = { range = true },
      format = '{kind_icon}{symbol.name:Normal}',
      hl_group = 'lualine_c_normal',
    }

    return symbols
  end

  opts.sections = opts.sections or {}
  opts.sections.lualine_c = opts.sections.lualine_c or {}
  table.insert(opts.sections.lualine_c, {
    function()
      local trouble_symbols = get_symbols()
      return trouble_symbols and trouble_symbols.get() or ''
    end,
    cond = function()
      local trouble_symbols = get_symbols()
      return vim.b.trouble_lualine ~= false and trouble_symbols ~= nil and trouble_symbols.has()
    end,
  })
end

return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = vim.g.have_nerd_font and { 'nvim-tree/nvim-web-devicons' } or {},
    opts = function()
      local opts = {
        options = {
          icons_enabled = vim.g.have_nerd_font,
          theme = lualine_theme,
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'bigfile' },
            winbar = { 'bigfile' },
          },
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'diagnostics',
              symbols = diagnostic_icons,
            },
            {
              function()
                return (vim.g.have_nerd_font and '󱉭  ' or 'root ') .. vim.fs.basename(get_root())
              end,
            },
            -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },

            { pretty_path, padding = { left = 1, right = 1 } },
          },
          lualine_x = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
              end,
              -- icon = 'cwd',
              cond = function()
                return vim.o.columns > 100
              end,
            },
            -- 'encoding',
            -- 'fileformat',
            {
              'filetype',
              colored = true,
            },
            {
              function()
                local status = require('sidekick.status').cli()
                return (vim.g.have_nerd_font and ' ' or 'AI ') .. (#status > 1 and #status or '')
              end,
              cond = function()
                return #require('sidekick.status').cli() > 0
              end,
              color = function()
                return { fg = Snacks.util.color 'Special' }
              end,
            },
            {
              function()
                local status = require('sidekick.status').get()
                return status and vim.tbl_get(copilot_icons, status.kind, 1)
              end,
              cond = function()
                return require('sidekick.status').get() ~= nil
              end,
              color = function()
                local status = require('sidekick.status').get()
                local hl = status and (status.busy and 'DiagnosticWarn' or vim.tbl_get(copilot_icons, status.kind, 2))
                return { fg = Snacks.util.color(hl) }
              end,
            },
            {
              'searchcount',
              maxcount = 999,
              timeout = 500,
              color = function()
                return { fg = Snacks.util.color 'Special' }
              end,
            },
            -- stylua: ignore
            -- still unsure what this does
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color("Constant") } end,

            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function() return { fg = Snacks.util.color("Special") } end,
            },
            {
              'diff',
              symbols = {
                added = git_icons.added,
                modified = git_icons.modified,
                removed = git_icons.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            {
              'progress',
              fmt = function(progress)
                return progress .. '/'
              end,
              separator = '',
              padding = { left = 1, right = 0 },
              color = oxocarbon_lualine_y_color,
            },
            -- show line count and size, total and selection count
            -- disable showcmd since it also shows selection info
            {
              function()
                local starts = vim.fn.line 'v'
                local ends = vim.fn.line '.'
                local wc = vim.fn.wordcount()
                if vim.fn.mode():find '[Vv]' then
                  local count = starts <= ends and ends - starts + 1 or starts - ends + 1
                  local bytes = wc['visual_bytes'] > 1024 and string.format('%.1f', wc['visual_bytes'] / 1024) .. 'k' or wc['visual_bytes']
                  return count .. 'L/' .. bytes
                else
                  local count = vim.fn.line '$'
                  local bytes = wc['bytes'] > 1048576 and string.format('%.1f', wc['bytes'] / 1048576) .. 'M'
                    or wc['bytes'] > 1024 and string.format('%.1f', wc['bytes'] / 1024) .. 'K'
                    or wc['bytes'] .. 'B'
                  return count .. 'L/' .. bytes
                end
              end,
              padding = { left = 0, right = 1 },
              color = oxocarbon_lualine_y_color,
            },
          },
          lualine_z = {
            {
              'datetime',
              style = '%H:%M',
              icon = vim.g.have_nerd_font and '' or nil,
            },
          },
        },
      }

      add_trouble_symbols(opts)

      return opts
    end,
  },
}
