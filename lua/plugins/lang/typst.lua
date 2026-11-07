-- Adds Typst editing support through Tinymist, typstyle, preview, and Treesitter
return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tinymist = {
          single_file_support = true,
          settings = {
            tinymist = {
              formatterMode = 'typstyle',
              exportPdf = 'onSave',
              outputPath = '$root/$dir/$name',
            },
          },
        },
      },
      tools = {
        'typstyle',
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'Add Typst-specific Tinymist mappings',
        group = vim.api.nvim_create_augroup('typst-lsp-mappings', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client or client.name ~= 'tinymist' then
            return
          end

          -- Maps a Tinymist command after the language server attaches
          local map = function(keys, command, desc)
            vim.keymap.set('n', keys, '<cmd>' .. command .. '<cr>', { buffer = event.buf, desc = desc })
          end

          map('<leader>ce', 'LspTinymistExportPdf', 'Export PDF')
          map('<leader>cP', 'LspTinymistPinMain', 'Pin Main File')
        end,
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        typst = { 'typstyle', lsp_format = 'prefer' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = { 'typst' },
    },
  },
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    cmd = { 'TypstPreview', 'TypstPreviewToggle', 'TypstPreviewUpdate' },
    keys = {
      { '<leader>cp', '<cmd>TypstPreviewToggle<cr>', ft = 'typst', desc = 'Toggle Typst Preview' },
    },
    opts = {
      dependencies_bin = {
        tinymist = 'tinymist',
      },
    },
  },
}
