return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'folke/lazydev.nvim',
    },
    opts_extend = { 'sources.default' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',
        ['<C-e>'] = {},
        ['<C-g>'] = { 'hide', 'fallback' },
        ['Esc'] = { 'hide', 'fallback' },
        ['<C-s>'] = { 'show', 'show_documentation', 'hide_documentation' },
        -- ['<C-s>'] = {
        --   function(cmp)
        --     if cmp.is_visible() then
        --       return cmp.cancel()
        --     else
        --       return vim.schedule(function()
        --         cmp.show()
        --         cmp.show_documentation()
        --         cmp.hide_documentation()
        --       end)
        --     end
        --   end,
        -- },
        ['<Tab>'] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.select_and_accept()
            end

            if require('sidekick').nes_jump_or_apply() then
              return true
            end

            if cmp.snippet_active() then
              return cmp.accept()
            end
          end,
          'snippet_forward',
          function() -- if you are using Neovim's native inline completions
            return vim.lsp.inline_completion and vim.lsp.inline_completion.get()
          end,
          'fallback',
        },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 400,
        },
        ghost_text = {
          enabled = false,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          border = 'rounded',
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              { 'source_name' },
            },
          },
        },
      },

      cmdline = {
        enabled = true,
        completion = {
          menu = {
            auto_show = function(ctx)
              return ctx.mode == 'cmdwin'
            end,
          },
          ghost_text = { enabled = true },
        },
      },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },

      -- Shows a signature help window while you type arguments for a function
      signature = {
        enabled = true,
        window = { border = 'rounded' },
      },

      snippets = {
        preset = 'default',
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
          lazydev = {
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)

      local highlights = require 'config.highlights'
      highlights.set_blink_ghost_text()

      vim.api.nvim_create_autocmd('ColorScheme', {
        desc = 'Keep blink ghost text readable',
        group = vim.api.nvim_create_augroup('blink-ghost-text-highlight', { clear = true }),
        callback = function()
          vim.schedule(highlights.set_blink_ghost_text)
        end,
      })
    end,
  },
}
