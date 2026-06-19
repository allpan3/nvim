return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        pyright = {},
        ruff = {
          cmd_env = { RUFF_TRACE = 'messages' },
          init_options = {
            settings = {
              logLevel = 'error',
            },
          },
        },
      },
      setup = {
        ruff = function(_, server)
          local on_attach = server.on_attach
          server.on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            if on_attach then
              on_attach(client, bufnr)
            end
          end
        end,
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        python = { 'ruff_format' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = { 'python' },
    },
  },
}
