-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

plugins = require('plugins')
require('lazy').setup(plugins)

-- Mapping
vim.api.nvim_set_keymap('c', 'w!!', 'w !sudo tee > /dev/null %<CR> :e!<CR>', {})
-- vim.api.nvim_set_keymap('n', 'x', '"_x', {})
vim.api.nvim_set_keymap('c', '/', 'getcmdtype() == "/" ? "\\/" : "/"', {expr = true})
vim.api.nvim_set_keymap('c', '?', 'getcmdtype() == "?" ? "\\?" : "?"', {expr = true})

-- to Normal mode:
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('i', 'っｊ', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('i', 'っj', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':<C-u>set nohlsearch!<CR>', {silent = true})

-- Cursor
vim.api.nvim_set_keymap('n', 'j', 'gj', {})
vim.api.nvim_set_keymap('n', 'k', 'gk', {})
vim.api.nvim_set_keymap('n', '<down>', 'gj', {})
vim.api.nvim_set_keymap('n', '<up>', 'gk', {})

-- Color
vim.o.termguicolors = true

-- Lightline
vim.o.laststatus = 2

-- linenumber
vim.o.relativenumber = true
vim.o.number = true
vim.o.signcolumn = "yes:1"

-- Undo
if vim.fn.has('persistent_undo') == 1 then
    vim.o.undodir = './undo'
    vim.o.undofile = true
end

-- Clipboard
vim.o.clipboard = vim.o.clipboard .. 'unnamedplus'

-- Character code
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'ucs-bom,utf-8,euc-jp,cp932'
vim.o.fileformats = 'unix,dos,mac'
vim.o.ambiwidth = 'double'

-- Tab / Indent
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.shiftwidth = 2

-- Search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true

-- Cursor
vim.o.whichwrap = 'b,s,h,l,<,>,[,],~'
vim.o.backspace = 'indent,eol,start'
vim.o.wildmenu = true
vim.o.wildmode = 'full'
vim.o.history = 5000
vim.o.cursorline = true

-- Bracket
vim.o.showmatch = true

-- Mouse
vim.o.mouse = 'a'
