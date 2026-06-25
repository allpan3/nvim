-- Configures Snacks.nvim UI features, dashboard shortcuts, pickers, and utility toggles
local toggles = {}

-- Builds cached toggle callbacks for Snacks toggle providers
local function toggle(id, create)
  return function()
    toggles[id] = toggles[id] or create()
    toggles[id]:toggle()
  end
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = {
        enabled = true,
        setup = function(ctx)
          require('config.bigfile').disable_buffer_features(ctx.buf)
          Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
        end,
      },
      quickfile = { enabled = true },
      notifier = { enabled = true },
      profiler = { enabled = true },
      dashboard = {
        -- width = 100,
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Git Files', action = function() Snacks.picker.git_files() end },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'e', desc = 'Explorer', action = function() Snacks.explorer() end },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
          header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
        },
        sections = {
          { pane = 1, section = 'header' },
          { pane = 1, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { pane = 1, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 2 },
          { pane = 1, section = 'keys', gap = 1, padding = 1 },
          { pane = 1, section = 'startup' },
          -- { pane = 2, section = "terminal", cmd = "echo ' '", padding = 1 },
        },
      },
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
      { "<leader>nn", function() Snacks.picker.notifications() end, desc = 'Notification History' },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Grep Selection or Word", mode = { "n", "x" } },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },

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
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Comment Notes" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME", "FIXIT", "BUG", "ISSUE" } }) end, desc = "Todo/Fix" },

      -- profiler
      { "<leader>pp", function() Snacks.profiler.toggle() end, desc = "Toggle Profiler" },
      { "<leader>ph", function() Snacks.profiler.highlight() end, desc = "Toggle Profiler Highlights" },
      { "<leader>ps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

      -- ui
      { "<leader>ua", toggle("animate", function() return Snacks.toggle.animate() end), desc = "Toggle Animations" },
      { "<leader>ub", toggle("background", function() return Snacks.toggle.option("background", { name = "Dark Background", off = "light", on = "dark", global = true }) end), desc = "Toggle Dark Background" },
      { "<leader>uB", toggle("showtabline", function() return Snacks.toggle.option("showtabline", { name = "Tabline", off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, global = true }) end), desc = "Toggle Bufferline" },
      { "<leader>uc", toggle("conceallevel", function() return Snacks.toggle.option("conceallevel", { name = "Conceal Level", off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }) end), desc = "Toggle Conceal Level" },
      { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes', },
      { "<leader>ud", toggle("diagnostics", function() return Snacks.toggle.diagnostics() end), desc = "Toggle Diagnostics" },
      { "<leader>uD", toggle("dim", function() return Snacks.toggle.dim() end), desc = "Toggle Dimming" },
      { "<leader>ui", toggle("indent_guides", function() return Snacks.toggle({ name = "Indent Guides", get = function() return require("ibl.config").get_config(0).enabled end, set = function(state) require("ibl").update({ enabled = state }) end }) end), desc = "Toggle Indent Guides" },
      { "<leader>uh", toggle("inlay_hints", function() return Snacks.toggle.inlay_hints() end), desc = "Toggle Inlay Hints" },
      { "<leader>ul", toggle("relativenumber", function() return Snacks.toggle.option("relativenumber", { name = "Relative Number" }) end), desc = "Toggle Relative Number" },
      { "<leader>uL", toggle("line_number", function() return Snacks.toggle.line_number() end), desc = "Toggle Line Numbers" },
      { "<leader>uR", toggle("list", function() return Snacks.toggle.option("list", { name = "List Chars" }) end), desc = "Toggle List Chars" },
      { "<leader>us", toggle("spell", function() return Snacks.toggle.option("spell", { name = "Spelling" }) end), desc = "Toggle Spelling" },
      { "<leader>uS", toggle("scroll", function() return Snacks.toggle.scroll() end), desc = "Toggle Smooth Scroll" },
      { "<leader>uT", toggle("treesitter", function() return Snacks.toggle.treesitter() end), desc = "Toggle Treesitter Highlight" },
      { "<leader>uv", toggle("diagnostic_virtual_text", function() local virtual_text = vim.diagnostic.config().virtual_text return Snacks.toggle({ name = "Diagnostic Virtual Text", get = function() return vim.diagnostic.config().virtual_text ~= false end, set = function(state) vim.diagnostic.config({ virtual_text = state and virtual_text or false }) end }) end), desc = "Toggle Diagnostic Virtual Text" },
      { "<leader>uV", toggle("diagnostic_virtual_lines", function() local virtual_lines = vim.diagnostic.config().virtual_lines return Snacks.toggle({ name = "Diagnostic Virtual Lines", get = function() return vim.diagnostic.config().virtual_lines ~= false end, set = function(state) vim.diagnostic.config({ virtual_lines = state and (virtual_lines or true) or false }) end }) end), desc = "Toggle Diagnostic Virtual Lines" },
      { "<leader>uw", toggle("wrap", function() return Snacks.toggle.option("wrap", { name = "Wrap" }) end), desc = "Toggle Wrap" },
      { "<leader>uz", toggle("zen", function() return Snacks.toggle.zen() end), desc = "Toggle Zen Mode" },
      { "<leader>wm", toggle("zoom", function() return Snacks.toggle.zoom() end), desc = "Toggle Zoom Mode" },

      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
      { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
      { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols', },
      { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols', },
      { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
      { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"} },
      { "]]", function() if Snacks.words.is_enabled() then Snacks.words.jump(vim.v.count1) end end,
        desc = "Next Reference" },
      { "[[", function() if Snacks.words.is_enabled() then Snacks.words.jump(-vim.v.count1) end end,
        desc = "Prev Reference" },



    },
  },
}
