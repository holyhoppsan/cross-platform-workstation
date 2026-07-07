local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.termguicolors = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.wrap = false
opt.breakindent = true
opt.scrolloff = 6
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitbelow = true
opt.splitright = true
opt.updatetime = 250
opt.timeoutlen = 500
opt.undofile = true
opt.swapfile = false
opt.backup = false

vim.cmd('filetype plugin indent on')
