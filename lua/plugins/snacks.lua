return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      explorer = {
        enabled = true,
        git_status_open = true,
        -- diagnostics_open = true,
      },
      picker = {
        enabled = true,
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          explorer = { hidden = true },
        },
        formatters = {
          file = {
            -- filename_first = true, -- show the filename first
          },
        },
        win = {
          -- input window
          input = {
            keys = {
              -- WARN: would prefer to use ctrl-i/h/l for toggling ignored, hidden, follow (link), but fzf doesn't seem to
              --       support CSI u, and better to match fzf and snacks picker
              ['<c-n>'] = { 'history_forward', mode = { 'i', 'n' } },
              ['<c-p>'] = { 'history_back', mode = { 'i', 'n' } },
              -- a-h is used by zellij
              ['<a-g>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
              ['<a-h>'] = false,
              -- With zellij kitty keyboard protocol disabled, <c-/> is the same as <c-_> in neovim, which is reserved by undo
              -- ["<c-/>"] = { "toggle_preview", mode = { "i", "n" } },
              ['<c-t>'] = { 'trouble_open', mode = { 'n', 'i' } },
              -- Right now there's no action to directly toggle preview wrap, have to switch to preview window then <leader>uw
            },
          },
          -- result list window
          -- INFO: once enter list or preview window, can use all normal mode keybings (including leader keys)
          list = {
            keys = {
              -- ["<c-/>"] = "toggle_preview",
              ['<c-t>'] = 'trouble_open',
              -- a-h is used by zellij
              ['<a-g>'] = 'toggle_hidden',
              ['<a-h>'] = false,
            },
            -- wo = {
            -- 	wrap = true,
            -- },
          },
          -- preview window
          preview = {
            keys = {
              -- ["<c-/>"] = "toggle_preview",
            },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- Top Pickers & Explorer
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer", },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = 'Notification History' },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual Selection or Word", mode = { "n", "x" } },

      -- Picker
      -- files
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config File" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git Files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },

      -- git (some are set in keymaps.lua and gitsigns.lua)
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      -- This shows the commit histories that contain this line, but shows all changes in the commit instead of just the hunk containing the line
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      { "<leader>gh", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },

      -- grep
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Open Buffers" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual Selection or Word", mode = { "n", "x" } },

      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { '<leader>sp', function() Snacks.picker.lazy() end, desc = 'Search for Plugin Spec' },
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },

  
      -- ui
      { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes', },
      -- LSP
      -- { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition', },
      -- { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration', },
      -- { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References', },
      -- { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation', },
      -- { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition', },
      -- { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols', },
      -- { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols', },
    },
  },
}
