return {
  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      keywords = {
        FIX = {
          icon = ' ',
          color = 'error',
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE', 'ERROR' },
        },
        QUES = { icon = ' ', color = 'question', alt = { 'QUESTION', 'DOUBT', 'UNSURE' } },
      },
      highlight = {
        before = 'fg',
        keyword = 'wide',
        pattern = [[.*<((KEYWORDS)\s*%(\(.{-1,}\))?)\s*:]],
        comments_only = false,
        exclude = { 'bigfile' },
      },
      search = {
        pattern = [[\b(KEYWORDS)\s*(\([^\)]*\))?\s*:]],
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--hidden',
          '--no-ignore',
        },
      },
      colors = {
        question = { '#FBBF24' },
      },
    },
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' }, 
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
    },
  },
}
