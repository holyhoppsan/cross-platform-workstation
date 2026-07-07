local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>e', '<cmd>Explore<CR>', { desc = 'Open file explorer' })
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write file' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit window' })
map('n', '<leader>Q', '<cmd>quitall<CR>', { desc = 'Quit all windows' })
map('n', '<leader>h', '<cmd>checkhealth<CR>', { desc = 'Check Neovim health' })

map('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = 'Split vertically' })
map('n', '<leader>sh', '<cmd>split<CR>', { desc = 'Split horizontally' })
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
