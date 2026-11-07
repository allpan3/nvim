-- Adds Markdown editing support through Marksman, Prettier, Treesitter, and inline rendering

-- Conceals Markdown escape markers while preserving escaped characters
local function conceal_escape(ctx)
  local query = vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
  local marks = {}

  for _, node in query:iter_captures(ctx.root, ctx.buf) do
    local start_row, start_col, end_row = node:range()
    marks[#marks + 1] = {
      conceal = true,
      start_row = start_row,
      start_col = start_col,
      opts = {
        end_row = end_row,
        end_col = start_col + 1,
        conceal = '',
      },
    }
  end

  return marks
end

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
        markdown = { 'prettier_markdown' },
      },
      formatters = {
        prettier_markdown = {
          inherit = 'prettier',
          append_args = { '--prose-wrap', 'always', '--print-width', '100' },
        },
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
      custom_handlers = {
        markdown_inline = {
          extends = true,
          parse = conceal_escape,
        },
      },
      completions = {
        lsp = {
          enabled = true,
        },
      },
      file_types = { 'markdown' },
    },
  },
}
