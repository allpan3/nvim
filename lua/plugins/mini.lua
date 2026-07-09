-- Configures mini.nvim modules and their local keymaps, highlights, and integrations
return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>fm',
        function()
          if not MiniFiles.close() then
            local path = vim.api.nvim_buf_get_name(0)
            MiniFiles.open(path ~= '' and path or nil, false)
          end
        end,
        desc = 'Mini Files',
      },
    },
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      local ai = require 'mini.ai'
      local ai_buffer = function(ai_type)
        local start_line, end_line = 1, vim.fn.line '$'

        if ai_type == 'i' then
          local first_nonblank = vim.fn.nextnonblank(start_line)
          local last_nonblank = vim.fn.prevnonblank(end_line)
          if first_nonblank == 0 or last_nonblank == 0 then
            return { from = { line = start_line, col = 1 } }
          end
          start_line, end_line = first_nonblank, last_nonblank
        end

        local to_col = math.max(vim.fn.getline(end_line):len(), 1)
        return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
      end

      local ai_opts = {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter {
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          },
          f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
          c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
          d = { '%f[%d]%d+' },
          e = {
            { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
            '^().*()$',
          },
          g = ai_buffer,
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call { name_pattern = '[%w_]' },
        },
      }
      require('mini.ai').setup(ai_opts)

      local register_ai_which_key = function(opts)
        local objects = {
          { ' ', desc = 'whitespace' },
          { '"', desc = '" string' },
          { "'", desc = "' string" },
          { '(', desc = '() block' },
          { ')', desc = '() block with ws' },
          { '<', desc = '<> block' },
          { '>', desc = '<> block with ws' },
          { '?', desc = 'user prompt' },
          { 'U', desc = 'use/call without dot' },
          { '[', desc = '[] block' },
          { ']', desc = '[] block with ws' },
          { '_', desc = 'underscore' },
          { '`', desc = '` string' },
          { 'a', desc = 'argument' },
          { 'b', desc = ')]} block' },
          { 'c', desc = 'class' },
          { 'd', desc = 'digit(s)' },
          { 'e', desc = 'CamelCase/snake_case' },
          { 'f', desc = 'function' },
          { 'g', desc = 'entire file' },
          { 'i', desc = 'indent' },
          { 'o', desc = 'block, conditional, loop' },
          { 'q', desc = 'quote `"\'' },
          { 't', desc = 'tag' },
          { 'u', desc = 'use/call' },
          { '{', desc = '{} block' },
          { '}', desc = '{} block with ws' },
        }

        local ret = { mode = { 'o', 'x' } }
        local mappings = vim.tbl_extend('force', {}, {
          around = 'a',
          inside = 'i',
          around_next = 'an',
          inside_next = 'in',
          around_last = 'al',
          inside_last = 'il',
        }, opts.mappings or {})
        mappings.goto_left = nil
        mappings.goto_right = nil

        for name, prefix in pairs(mappings) do
          name = name:gsub('^around_', ''):gsub('^inside_', '')
          ret[#ret + 1] = { prefix, group = name }
          for _, obj in ipairs(objects) do
            local desc = obj.desc
            if prefix:sub(1, 1) == 'i' then
              desc = desc:gsub(' with ws', '')
            end
            ret[#ret + 1] = { prefix .. obj[1], desc = desc }
          end
        end

        local ok, which_key = pcall(require, 'which-key')
        if ok then
          which_key.add(ret, { notify = false })
        end
      end

      vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('MiniAiWhichKey', { clear = true }),
        pattern = 'VeryLazy',
        callback = function()
          vim.schedule(function()
            register_ai_which_key(ai_opts)
          end)
        end,
      })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - maiw) - [A]dd [I]nner [W]ord [)]Paren
      -- - maiw" - [A]dd [I]nner [W]ord ["]Quotes
      -- - ma$]  - [A]dd to [$]line end []]Brackets
      -- - maiwth1<CR> - [A]dd [I]nner [W]ord [T]ag <h1>
      -- - md'   - [D]elete [']Quotes
      -- - mdq   - [D]elete nearest [Q]uote
      -- - mdb   - [D]elete nearest [B]racket
      -- - mr)'  - [R]eplace [)] [']Quote
      -- - mrf`  - [R]eplace [F]unction call [`]
      -- - mf)   - [F]ind [)]Paren to the right
      -- - mF)   - [F]ind [)]Paren to the left
      -- - mh}   - [H]ighlight [{}]Braces
      local surround_opts = {
        mappings = {
          add = 'ma', -- Add surrounding in Normal and Visual modes
          delete = 'md', -- Delete surrounding
          find = 'mf', -- Find surrounding (to the right)
          find_left = 'mF', -- Find surrounding (to the left)
          highlight = 'mh', -- Highlight surrounding
          replace = 'mr', -- Replace surrounding
          update_n_lines = 'mn', -- Update `n_lines`
        },
      }
      require('mini.surround').setup(surround_opts)

      local register_surround_which_key = function(opts)
        local ok, which_key = pcall(require, 'which-key')
        if not ok then
          return
        end

        local maps = opts.mappings or {}
        local suffix_last = maps.suffix_last or 'l'
        local suffix_next = maps.suffix_next or 'n'
        local targets = {
          { '(', desc = 'parentheses with ws' },
          { ')', desc = 'parentheses' },
          { '[', desc = 'brackets with ws' },
          { ']', desc = 'brackets' },
          { '{', desc = 'braces with ws' },
          { '}', desc = 'braces' },
          { '<lt>', desc = 'angle brackets with ws' },
          { '>', desc = 'angle brackets' },
          { '"', desc = 'double quotes' },
          { "'", desc = 'single quotes' },
          { '`', desc = 'backticks' },
          { '?', desc = 'custom prompt' },
          { 'b', desc = 'bracket alias' },
          { 'q', desc = 'quote alias' },
          { 'f', desc = 'function call' },
          { 't', desc = 'tag' },
        }

        local ret = {}
        local add_output_targets = function(prefix, action, mode, opts)
          if prefix == nil or prefix == '' then
            return
          end

          opts = opts or {}
          if opts.group ~= false then
            ret[#ret + 1] = { prefix, group = action:lower() .. ' with', mode = mode }
          end
          for _, target in ipairs(targets) do
            ret[#ret + 1] = { prefix .. target[1], desc = 'with ' .. target.desc, mode = mode }
          end
        end
        local add_targets = function(prefix, action, mode)
          if prefix == nil or prefix == '' then
            return
          end

          ret[#ret + 1] = { prefix, group = action:lower() .. ' surround', mode = mode }
          for _, target in ipairs(targets) do
            ret[#ret + 1] = { prefix .. target[1], desc = action .. ' ' .. target.desc, mode = mode }
          end
        end
        local add_replace_outputs = function(prefix, mode)
          if prefix == nil or prefix == '' then
            return
          end

          for _, input in ipairs(targets) do
            add_output_targets(prefix .. input[1], 'Replace ' .. input.desc, mode, { group = false })
          end
        end
        local add_search_targets = function(prefix, action, mode)
          if prefix == nil or prefix == '' then
            return
          end

          add_targets(prefix, action, mode)
          if suffix_next ~= '' then
            add_targets(prefix .. suffix_next, action .. ' next', mode)
          end
          if suffix_last ~= '' then
            add_targets(prefix .. suffix_last, action .. ' last', mode)
          end
        end

        add_targets(maps.add, 'Add', 'x')
        add_search_targets(maps.delete, 'Delete', 'n')
        add_search_targets(maps.replace, 'Replace', 'n')
        add_replace_outputs(maps.replace, 'n')
        if suffix_next ~= '' then
          add_replace_outputs(maps.replace .. suffix_next, 'n')
        end
        if suffix_last ~= '' then
          add_replace_outputs(maps.replace .. suffix_last, 'n')
        end
        add_search_targets(maps.find, 'Find right', { 'n', 'x', 'o' })
        add_search_targets(maps.find_left, 'Find left', { 'n', 'x', 'o' })
        add_search_targets(maps.highlight, 'Highlight', 'n')

        which_key.add(ret, { notify = false })
      end

      vim.schedule(function()
        register_surround_which_key(MiniSurround.config)
      end)

      local highlights = require 'config.highlights'

      require('mini.diff').setup {
        options = {
          algorithm = 'minimal',
        },
        mappings = {
          apply = '',
          reset = '',
          textobject = '',
          goto_first = '',
          goto_prev = '',
          goto_next = '',
          goto_last = '',
        },
      }
      highlights.set_mini_diff_overlay()

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('MiniDiffOverlayHighlights', { clear = true }),
        callback = function()
          vim.schedule(highlights.set_mini_diff_overlay)
        end,
      })

      vim.keymap.set('n', '<leader>go', function()
        MiniDiff.toggle_overlay()
      end, { desc = 'Toggle Diff Overlay' })

      -- File explorer
      require('mini.icons').setup() -- dependency
      local show_dotfiles = true
      local filter_show = function()
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end
      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        MiniFiles.refresh { content = { filter = new_filter } }
      end
      local map_split = function(buf_id, lhs, direction, desc)
        local rhs = function()
          local fs_entry = MiniFiles.get_fs_entry()
          if fs_entry == nil then
            return
          end

          if fs_entry.fs_type ~= 'file' then
            MiniFiles.go_in()
            return
          end

          local state = MiniFiles.get_explorer_state()
          if state == nil or not vim.api.nvim_win_is_valid(state.target_window) then
            return
          end

          local new_target = vim.api.nvim_win_call(state.target_window, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target)
          MiniFiles.go_in { close_on_file = true }
        end

        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end
      local files_set_cwd = function()
        local fs_entry = MiniFiles.get_fs_entry()
        if fs_entry == nil then
          return
        end

        local cur_entry_path = fs_entry.path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
          vim.notify('cwd: ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':~'), vim.log.levels.INFO, {
            title = 'Directory changed',
          })
        end
      end

      require('mini.files').setup {
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 30,
        },
      }

      vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('MiniFilesMappings', { clear = true }),
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle dotfiles' })
          vim.keymap.set('n', 'gc', files_set_cwd, { buffer = args.data.buf_id, desc = 'Set cwd' })

          map_split(buf_id, '<leader>\\', 'belowright vertical', 'Open in Split Right')
          map_split(buf_id, '<leader>wv', 'belowright vertical', 'Open in Split Right')
          map_split(buf_id, '<leader>-', 'belowright horizontal', 'Open in Split Below')
          map_split(buf_id, '<leader>wb', 'belowright horizontal', 'Open in Split Below')
        end,
      })
    end,
  },
}
