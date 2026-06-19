-- debug.lua
--
-- Debug Adapter Protocol support for Neovim.

---@param config { type?: string, args?: string[]|string|fun():string[]? }
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {}
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str))
    return require('dap.utils').splitstr(new_args)
  end
  return config
end

return {
  'mfussenegger/nvim-dap',
  opts_extend = { 'ensure_installed' },
  opts = {
    automatic_installation = true,
    handlers = {},
    ensure_installed = {},
  },
  dependencies = {
    -- Creates a debugger UI.
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui.
    'nvim-neotest/nvim-nio',

    -- Inline values while stopped in a debug session.
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = {
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
      },
    },

    -- Installs the debug adapters for you.
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  -- stylua: ignore
  keys = {
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Breakpoint Condition' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'Run/Continue' },
    { '<leader>da', function() require('dap').continue { before = get_args } end, desc = 'Run with Args' },
    { '<leader>dC', function() require('dap').run_to_cursor() end, desc = 'Run to Cursor' },
    { '<leader>de', function() require('dapui').eval() end, desc = 'Eval', mode = { 'n', 'x' } },
    { '<leader>dg', function() require('dap').goto_() end, desc = 'Go to Line (No Execute)' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Step Into' },
    { '<leader>dj', function() require('dap').down() end, desc = 'Stack Down' },
    { '<leader>dk', function() require('dap').up() end, desc = 'Stack Up' },
    { '<leader>dl', function() require('dap').run_last() end, desc = 'Run Last' },
    { '<leader>do', function() require('dap').step_out() end, desc = 'Step Out' },
    { '<leader>dO', function() require('dap').step_over() end, desc = 'Step Over' },
    { '<leader>dp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ') end, desc = 'Log Point' },
    { '<leader>dP', function() require('dap').pause() end, desc = 'Pause' },
    { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Toggle REPL' },
    { '<leader>ds', function() require('dap').session() end, desc = 'Session' },
    { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
    { '<leader>du', function() require('dapui').toggle({}) end, desc = 'Toggle UI' },
    { '<leader>dw', function() require('dap.ui.widgets').hover() end, desc = 'Hover Widgets' },

  },
  config = function(_, opts)
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = opts.automatic_installation,
      handlers = opts.handlers or {},
      ensure_installed = opts.ensure_installed or {},
    }

    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

    local dap_signs = vim.g.have_nerd_font
        and {
          Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
          Breakpoint = { ' ', 'DiagnosticInfo' },
          BreakpointCondition = { ' ', 'DiagnosticInfo' },
          BreakpointRejected = { ' ', 'DiagnosticError' },
          LogPoint = { '.>', 'DiagnosticInfo' },
        }
      or {
        Stopped = { '>', 'DiagnosticWarn', 'DapStoppedLine' },
        Breakpoint = { 'B', 'DiagnosticInfo' },
        BreakpointCondition = { 'C', 'DiagnosticInfo' },
        BreakpointRejected = { 'R', 'DiagnosticError' },
        LogPoint = { 'L', 'DiagnosticInfo' },
      }

    for name, sign in pairs(dap_signs) do
      vim.fn.sign_define('Dap' .. name, {
        text = sign[1],
        texthl = sign[2] or 'DiagnosticInfo',
        linehl = sign[3],
        numhl = sign[3],
      })
    end

    dapui.setup {
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = vim.g.have_nerd_font and '󰁕' or '*',
      },
      controls = {
        icons = vim.g.have_nerd_font and {
          pause = '',
          play = '',
          step_into = '',
          step_over = '',
          step_out = '',
          step_back = '',
          run_last = '',
          terminate = '',
          disconnect = '',
        } or {
          pause = 'pause',
          play = 'run',
          step_into = 'in',
          step_over = 'over',
          step_out = 'out',
          step_back = 'back',
          run_last = 'last',
          terminate = 'stop',
          disconnect = 'disc',
        },
      },
      floating = {
        border = 'rounded',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open {}
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close {}
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close {}
    end
  end,
}
