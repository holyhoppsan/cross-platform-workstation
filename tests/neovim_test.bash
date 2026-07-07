#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=test_helper.bash
. "$repo_root/tests/test_helper.bash"

nvim_init=$(cat "$repo_root/chezmoi/dot_config/nvim/init.lua")
nvim_options=$(cat "$repo_root/chezmoi/dot_config/nvim/lua/workstation/options.lua")
nvim_keymaps=$(cat "$repo_root/chezmoi/dot_config/nvim/lua/workstation/keymaps.lua")
nvim_filetypes=$(cat "$repo_root/chezmoi/dot_config/nvim/lua/workstation/filetypes.lua")
nvim_lsp=$(cat "$repo_root/chezmoi/dot_config/nvim/lua/workstation/lsp.lua")
nvim_doc=$(cat "$repo_root/docs/neovim.md")
doctor=$(cat "$repo_root/chezmoi/dot_config/workstation/doctor")

assert_contains "$nvim_init" "vim.g.mapleader = ' '" 'Neovim uses Space leader'
assert_contains "$nvim_init" "require('workstation.options')" 'Neovim loads options module'
assert_contains "$nvim_init" "require('workstation.keymaps')" 'Neovim loads keymaps module'
assert_contains "$nvim_init" "require('workstation.filetypes')" 'Neovim loads filetypes module'
assert_contains "$nvim_init" "require('workstation.lsp')" 'Neovim loads LSP-ready module'
assert_contains "$nvim_options" "opt.clipboard = 'unnamedplus'" 'Neovim enables system clipboard integration'
assert_contains "$nvim_options" 'opt.termguicolors = true' 'Neovim enables terminal colors'
assert_contains "$nvim_options" 'vim.cmd' 'Neovim enables filetype plugin indent'
assert_contains "$nvim_keymaps" "'<leader>e'" 'Neovim has basic file navigation keymap'
assert_contains "$nvim_keymaps" "'<leader>w'" 'Neovim has write keymap'
assert_contains "$nvim_keymaps" "'<C-h>'" 'Neovim has window navigation keymap'
assert_contains "$nvim_filetypes" 'uproject' 'Neovim handles Unreal project files'
assert_contains "$nvim_filetypes" 'Build%.cs' 'Neovim handles Unreal Build.cs files'
assert_contains "$nvim_filetypes" 'Target%.cs' 'Neovim handles Unreal Target.cs files'
assert_contains "$nvim_filetypes" 'hlsl' 'Neovim handles Unreal shader files'
assert_contains "$nvim_lsp" 'vim.diagnostic.config' 'Neovim has LSP-ready diagnostics config'
assert_not_contains "$nvim_init" 'lazy.nvim' 'Neovim does not force a plugin manager'
assert_contains "$nvim_doc" 'plugin-free' 'Neovim docs explain plugin-free baseline'
assert_contains "$nvim_doc" 'Ctrl+A' 'Neovim docs document WezTerm leader boundary'
assert_contains "$nvim_doc" 'macOS and Ubuntu behavior must remain marked unvalidated' 'Neovim docs mark unvalidated platforms'
assert_contains "$doctor" 'check_neovim' 'doctor implements Neovim checks'
assert_contains "$doctor" '/c/Program Files/Neovim/bin/nvim.exe' 'doctor checks standard Windows Neovim path'
assert_contains "$doctor" 'package.path' 'doctor seeds Lua package path'
assert_contains "$doctor" 'vim.opt.rtp:prepend' 'doctor prepends Neovim config directory to runtimepath'
assert_contains "$doctor" 'cygpath -aw "$config_path"' 'doctor converts Neovim config path for native Windows Neovim'
assert_contains "$doctor" 'Error in|E5113' 'doctor treats Neovim startup errors as failures'
assert_contains "$doctor" '-u "$nvim_config_path"' 'doctor validates Neovim config headlessly'
assert_contains "$doctor" "spawn_interactive_bash_command('nv')" 'doctor requires interactive WezTerm Neovim new-pane helper'

finish_tests
