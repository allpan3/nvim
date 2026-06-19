return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    opts_extend = { 'tools' },
    opts = {
      servers = {},
      native_servers = {
        copilot = {
          defer_until = 'InsertEnter',
        },
      },
      setup = {},
      tools = {
        'copilot-language-server',
      },
    },
    config = function(_, opts)
      local highlights = require 'config.highlights'

      highlights.set_lsp_inline_completion()
      vim.api.nvim_create_autocmd('ColorScheme', {
        desc = 'Keep LSP inline completion ghost text readable',
        group = vim.api.nvim_create_augroup('lsp-inline-completion-highlight', { clear = true }),
        callback = function()
          vim.schedule(highlights.set_lsp_inline_completion)
        end,
      })

      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          if require('config.bigfile').is_big(event.buf) then
            require('config.bigfile').disable_buffer_features(event.buf)
            return
          end

          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cr', vim.lsp.buf.rename, 'Rename')
          -- Execute a code action, usually your cursor needs to be on top of an error
          -- suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>cc', vim.lsp.codelens.run, 'Run Codelens', { 'n', 'x' })
          map('gk', vim.lsp.buf.signature_help, 'Signature Help', { 'n' })

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local function client_supports_organize_imports(client)
            if not client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeAction, event.buf) then
              return false
            end

            local provider = client.server_capabilities.codeActionProvider
            if type(provider) ~= 'table' or provider.codeActionKinds == nil then
              return true
            end

            for _, kind in ipairs(provider.codeActionKinds) do
              if kind == 'source' or kind == 'source.organizeImports' or kind:match '^source%.organizeImports%.' then
                return true
              end
            end

            return false
          end

          if client and client_supports_organize_imports(client) then
            map('<leader>co', function()
              vim.lsp.buf.code_action {
                apply = true,
                context = {
                  only = { 'source.organizeImports' },
                },
              }
            end, 'Organize Imports')
          end

          if client and vim.lsp.inline_completion and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlineCompletion, event.buf) then
            vim.lsp.inline_completion.enable(true, { bufnr = event.buf })

            local inline_completion_remainder = ''

            vim.api.nvim_create_autocmd('InsertLeave', {
              buffer = event.buf,
              callback = function()
                inline_completion_remainder = ''
              end,
            })

            local function split_inline_completion_line(text)
              local partial = text:match '^[^\n]*\n?' or text
              return partial, text:sub(#partial + 1)
            end

            local function accept_inline_completion_line()
              if inline_completion_remainder ~= '' then
                local partial
                partial, inline_completion_remainder = split_inline_completion_line(inline_completion_remainder)
                vim.api.nvim_paste(partial, false, 0)
                return true
              end

              return vim.lsp.inline_completion.get {
                on_accept = function(item)
                  local insert_text = item.insert_text
                  local text = type(insert_text) == 'string' and insert_text
                    or type(insert_text) == 'table' and type(insert_text.value) == 'string' and insert_text.value
                    or nil
                  if not text or text == '' then
                    return item
                  end

                  local partial
                  partial, inline_completion_remainder = split_inline_completion_line(text)
                  item.insert_text = partial
                  return item
                end,
              }
            end

            -- map('<C-p>', function()
            --   inline_completion_remainder = ''
            --   vim.lsp.inline_completion.select { count = -1 }
            -- end, 'Previous Inline Completion', 'i')
            -- map('<C-n>', function()
            --   inline_completion_remainder = ''
            --   vim.lsp.inline_completion.select { count = 1 }
            -- end, 'Next Inline Completion', 'i')
            map('<C-e>', accept_inline_completion_line, 'Accept Inline Completion Line', 'i')
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = opts.servers or {}
      local native_servers = opts.native_servers or {}
      local setup = opts.setup or {}

      -- Ensure servers and tools contributed by plugins/lang/*.lua are installed.
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      local ensure_installed = {}
      for server_name, server in pairs(servers or {}) do
        if server == true or (type(server) == 'table' and server.enabled ~= false) then
          table.insert(ensure_installed, server_name)
        end
      end
      vim.list_extend(ensure_installed, opts.tools or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- Kickstart populates installs via mason-tool-installer.
        automatic_enable = false,
      }

      local function configure_server(server_name, server)
        if type(server) ~= 'table' or server.enabled ~= false then
          server = vim.deepcopy(server or {})
          server.enabled = nil
          local defer_until = server.defer_until
          server.defer_until = nil
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

          local setup_server = setup[server_name] or setup['*']
          if setup_server and setup_server(server_name, server) then
            return
          end

          vim.lsp.config(server_name, server)
          if defer_until then
            vim.api.nvim_create_autocmd(defer_until, {
              desc = 'Enable deferred LSP server: ' .. server_name,
              group = vim.api.nvim_create_augroup('deferred-lsp-' .. server_name, { clear = true }),
              once = true,
              callback = function()
                vim.lsp.enable(server_name)
              end,
            })
          else
            vim.lsp.enable(server_name)
          end
        end
      end

      for server_name, server in pairs(servers) do
        configure_server(server_name, server)
      end

      for server_name, server in pairs(native_servers) do
        configure_server(server_name, server)
      end
    end,
  },
}
