-- Phase 4 keeps Neovim LSP-ready without choosing a plugin manager yet.
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
