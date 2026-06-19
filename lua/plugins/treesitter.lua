return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false, -- this plugin does not support lazy loading
    build = ':TSUpdate',
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {},
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('bigfile-treesitter', { clear = true }),
        pattern = 'bigfile',
        callback = function(event)
          if vim.treesitter.stop then
            pcall(vim.treesitter.stop, event.buf)
          end
        end,
      })
    end,
    config = function(_, opts)
      if opts.install_dir then
        require('nvim-treesitter').setup { install_dir = opts.install_dir }
      end

      if opts.ensure_installed and #opts.ensure_installed > 0 then
        require('nvim-treesitter').install(opts.ensure_installed)
      end
    end,

    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
          goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
          goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
          goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
        },
      },
    },
    config = function(_, opts)
      local TS = require 'nvim-treesitter-textobjects'
      if not TS.setup then
        vim.notify('Please update nvim-treesitter-textobjects', vim.log.levels.ERROR)
        return
      end
      TS.setup(opts)

      local queries = {}

      local function have_textobjects(buf)
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if not lang or not pcall(vim.treesitter.language.add, lang) then
          return false
        end

        if queries[lang] == nil then
          local ok, query = pcall(vim.treesitter.query.get, lang, 'textobjects')
          queries[lang] = ok and query ~= nil
        end

        return queries[lang]
      end

      local function attach(buf)
        if not (vim.tbl_get(opts, 'move', 'enable') and have_textobjects(buf)) then
          return
        end

        local moves = vim.tbl_get(opts, 'move', 'keys') or {}
        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries_for_desc = type(query) == 'table' and query or { query }
            local parts = {}

            for _, q in ipairs(queries_for_desc) do
              local part = q:gsub('@', ''):gsub('%..*', '')
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end

            local desc = table.concat(parts, ' or ')
            desc = (key:sub(1, 1) == '[' and 'Prev ' or 'Next ') .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and ' End' or ' Start')

            vim.keymap.set({ 'n', 'x', 'o' }, key, function()
              if vim.wo.diff and key:find '[cC]' then
                return vim.cmd('normal! ' .. key)
              end
              require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
            end, {
              buffer = buf,
              desc = desc,
              silent = true,
            })
          end
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-textobjects', { clear = true }),
        callback = function(event)
          attach(event.buf)
        end,
      })

      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
}
