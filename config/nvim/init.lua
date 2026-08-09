-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

require('lazy').setup(require('plugins'))

-- Mapping
vim.keymap.set('c', 'w!!', 'w !sudo tee > /dev/null %<CR> :e!<CR>')
vim.keymap.set('c', '/', 'getcmdtype() == "/" ? "\\/" : "/"', { expr = true })
vim.keymap.set('c', '?', 'getcmdtype() == "?" ? "\\?" : "?"', { expr = true })

-- to Normal mode:
vim.keymap.set('i', 'jj', '<ESC>', { silent = true })
vim.keymap.set('i', 'っｊ', '<ESC>', { silent = true })
vim.keymap.set('i', 'っj', '<ESC>', { silent = true })
vim.keymap.set('n', '<Esc><Esc>', ':<C-u>set nohlsearch!<CR>', { silent = true })

-- Cursor
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<down>', 'gj')
vim.keymap.set('n', '<up>', 'gk')

-- Color
vim.o.termguicolors = true

-- Global statusline (lualine)
vim.o.laststatus = 3

-- linenumber
vim.o.relativenumber = true
vim.o.number = true
vim.o.signcolumn = "yes:1"

-- Undo
vim.o.undofile = true

-- Clipboard
vim.opt.clipboard:append('unnamedplus')

-- Character code
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'ucs-bom,utf-8,euc-jp,cp932'
vim.o.fileformats = 'unix,dos,mac'
vim.o.ambiwidth = 'double'

-- Tab / Indent
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.smartindent = true
vim.o.shiftwidth = 2

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Cursor
vim.o.whichwrap = 'b,s,h,l,<,>,[,],~'
vim.o.cursorline = true

-- Bracket
vim.o.showmatch = true

-- Mouse
vim.o.mouse = 'a'
