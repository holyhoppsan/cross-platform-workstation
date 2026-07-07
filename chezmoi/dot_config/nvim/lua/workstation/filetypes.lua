local augroup = vim.api.nvim_create_augroup('workstation_filetypes', { clear = true })

vim.filetype.add({
  extension = {
    ahk = 'autohotkey',
    Build = 'cs',
    Target = 'cs',
    uplugin = 'json',
    uproject = 'json',
    ush = 'hlsl',
    usf = 'hlsl',
  },
  filename = {
    ['AGENTS.md'] = 'markdown',
    ['PLAN.md'] = 'markdown',
  },
  pattern = {
    ['.*%.Build%.cs'] = 'cs',
    ['.*%.Target%.cs'] = 'cs',
    ['.*%.uproject'] = 'json',
    ['.*%.uplugin'] = 'json',
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'c', 'cpp', 'cs', 'lua', 'python', 'javascript', 'typescript', 'json', 'yaml', 'toml', 'sh' },
  callback = function()
    vim.opt_local.formatoptions:remove({ 'o' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'markdown', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'c', 'cpp', 'cs', 'hlsl' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
