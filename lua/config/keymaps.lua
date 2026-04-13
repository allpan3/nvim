-- Keymaps

---------- Keys free to map -------------
-- key        mode      description
-- M           n         not useful
-- <C-r>       n         use U for redo
-- <C-/>       n         unbound
-- <leader>`   n         switch buffer, redundant
-----------------------------------------

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
-- remap: recursively map the keys when the rhs contains lhs
-- silent: when mapping a key to a command, don't show the command prompt popup
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--   operator-pending = "o"

-- Double space to enter command mode
vim.keymap.set({ 'n', 'v' }, '<leader><leader>', ':', { desc = 'Command Mode' })

-- Edit
vim.keymap.set({ "n", "i", "v", "x" }, "<C-_>", "<cmd>undo<CR>", { desc = "Undo" }) -- same as terminal
vim.keymap.set({ "n", "i", "v", "x" }, "<M-r>", "<cmd>redo<CR>", { desc = "Redo" }) -- ctrl-r is search history in shell; this is mainly for mapping cmd-shift-z
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" }) -- pair with u as undo; map to ctrl-r instead of :redo allows count
vim.keymap.set("n", "<S-enter>", "<cmd>put _<cr>") -- shift-enter to insert new line below in normal mode
-- By default, pasting in visual mode puts the replaced text in default register. This writes to blackhole register instead
-- both p and P work
vim.keymap.set({ "v", "x" }, "p", '"_dP', { desc = "Replace with Paste" })
-- x behavior mimic d
vim.keymap.set({"n", "x"}, "d", '"_d', { remap = false })
vim.keymap.set({"n", "x"}, "D", '"_D', { remap = false })
vim.keymap.set({"n", "x"}, "x", "d", { remap = false })
vim.keymap.set("n", "xx", "dd", { remap = false })
vim.keymap.set({"n", "x"}, "X", "D", { remap = false })
vim.keymap.set({"n", "x"}, "<Del>", '"_x', { remap = false })

-- Disable default 's' (substitute) so it acts purely as a prefix
vim.keymap.set({'n', 'v'}, 's', '<Nop>', { desc = 'Surround prefix' })

-- Indentation
vim.keymap.set('n', '<Tab>', '>>', { desc = 'Indent line', silent = true })
vim.keymap.set('n', '<S-Tab>', '<<', { desc = 'Unindent line', silent = true })
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Unindent block', silent = true })
vim.keymap.set('v', '<Tab>', '>gv', { desc = 'Indent block', silent = true })
-- <tab> and ctrl-i are distinguished if both are unmapped or both are mapped. So here we map ctrl-i to itself.
vim.keymap.set('n', '<C-i>', '<C-i>', { desc = 'Jump forward (separate from Tab)' })

-- Navigation
-- better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set("i", "<M-b>", "<S-left>") -- word backward, match shell (shift-left is neovim default)
vim.keymap.set("i", "<M-f>", "<S-right>") -- word forward, match shell (shift-right is neovim default)
vim.keymap.set("n", "<M-f>", "e") -- word forward, match terminal; <M-b> is word backward by default
vim.keymap.set({ "n", "v", "x", "o" }, "gh", "^", { desc = "Goto Beginning of Indented Line" })
-- in visual mode $ includes the new line char, which isn't consistent with other operator mode
-- using g_ excludes the new line char, better consistency
vim.keymap.set({ "n", "v", "x", "o" }, "gl", "g_", { desc = "Goto End of Line" })


-- Window management
vim.keymap.set("n", "<leader>\\", "<C-w>v", { desc = "Split Window Right" })
vim.keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split Window Below" })
vim.keymap.set("n", "<leader>wd", "<C-w>c", { desc = "Delete Window" })
vim.keymap.set("n", "<leader>wb", "<C-w>s", { desc = "Split Window Below" })
vim.keymap.set("n", "<leader>wn", "<C-w>w", { desc = "Cycle Through Windows" })
vim.keymap.set("n", "<leader>wth", "<C-w>t<C-w>K", { desc = "Change Vertical to Horizontal" })
vim.keymap.set("n", "<leader>wtv", "<C-w>t<C-w>H", { desc = "Change Horizontal to Vertical" })
vim.keymap.set("n", "<leader>`", "<cmd>wincmd p<CR>", { desc = "Switch to Other Window" })
-- Move to window using the <ctrl> hjkl keys
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window' })

-- Buffer management
vim.keymap.set("n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Save File
vim.keymap.set({ "n", "x", "s" }, "<leader>fs", "<cmd>w<CR>", { desc = "Save File" })
vim.keymap.set({ "n", "x", "s" }, "<leader>fS", ":w ", { desc = "Save as" })
vim.keymap.set("n", "<leader>qw", "<cmd>wq<cr>", { desc = "Save and Quit" })

-- Copy current file path
vim.keymap.set("n", "<leader>fy", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Copy File Path" })
vim.keymap.set("n", "<leader>fe", ":edit ", { desc = "Open Path" }) -- open file with absolute or relative path

-- Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Git
-- This shows all (up to a limit) history of the line
-- git log -L flag doesn't support uncommitted lines. It only sees the single revision (in this case the default is HEAD)
-- So this command is only reliable in unchanged files
-- NOTE: very hard to use this view
vim.keymap.set("n", "<leader>gB", function()
	Snacks.git.blame_line({ count = 10 })
end, { desc = "Blame Line History" })
-- Open git remote repo
vim.keymap.set({ "n", "x" }, "<leader>gH", function()
	Snacks.gitbrowse()
end, { desc = "Open Remote Repo" })
vim.keymap.set({"n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Copy Repo URL" })
if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
end

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Resize window using <ctrl> arrow keys
-- map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
-- map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
-- map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
-- map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
vim.keymap.set('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- better indenting - stay in visual mode
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
