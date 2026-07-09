-- Adds Markdown editing support through Marksman, Prettier, Treesitter, and inline rendering
return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {},
      },
      tools = {
        'prettier',
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        markdown = { 'prettier' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = { 'markdown', 'markdown_inline', 'html', 'latex', 'yaml' },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    cmd = { 'RenderMarkdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>um', '<cmd>RenderMarkdown buf_toggle<cr>', ft = 'markdown', desc = 'Toggle Markdown Render' },
      { '<leader>uM', '<cmd>RenderMarkdown preview<cr>', ft = 'markdown', desc = 'Markdown Preview' },
    },
    opts = {
      preset = 'obsidian',
      completions = {
        lsp = {
          enabled = true,
        },
      },
      file_types = { 'markdown' },
    },
  },
}
