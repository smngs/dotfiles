-- iceberg dark palette (from iceberg.vim)
local colors = {
  bg       = '#0f1117', -- col_base bg (middle)
  fg       = '#3e445e', -- col_base fg
  edge_bg  = '#818596', -- statusline / edge bg
  edge_fg  = '#17171b', -- statusline / edge fg
  mid_bg   = '#2e313f', -- gradient bg (branch, location)
  mid_fg   = '#6b7089', -- gradient fg (comment tone)
  normal   = '#818596', -- NORMAL mode
  insert   = '#84a0c6', -- INSERT mode (blue)
  visual   = '#b4be82', -- VISUAL mode (green)
  replace  = '#e2a478', -- REPLACE mode (orange)
  command  = '#a093c7', -- COMMAND mode (purple)
  error    = '#e27878', -- error (red)
  warning  = '#e2a478', -- warning (orange)
  hint     = '#89b8c2', -- hint (light blue)
  info     = '#84a0c6', -- info (blue)
  added    = '#b4be82', -- git added
  changed  = '#e2a478', -- git changed
  removed  = '#e27878', -- git removed
}

local iceberg = {
  normal = {
    a = { fg = colors.edge_fg, bg = colors.normal,  gui = 'bold' },
    b = { fg = colors.mid_fg,  bg = colors.mid_bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
  insert = {
    a = { fg = colors.edge_fg, bg = colors.insert,  gui = 'bold' },
    b = { fg = colors.mid_fg,  bg = colors.mid_bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
  visual = {
    a = { fg = colors.edge_fg, bg = colors.visual,  gui = 'bold' },
    b = { fg = colors.mid_fg,  bg = colors.mid_bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
  replace = {
    a = { fg = colors.edge_fg, bg = colors.replace, gui = 'bold' },
    b = { fg = colors.mid_fg,  bg = colors.mid_bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
  command = {
    a = { fg = colors.edge_fg, bg = colors.command, gui = 'bold' },
    b = { fg = colors.mid_fg,  bg = colors.mid_bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
  inactive = {
    a = { fg = colors.fg,      bg = colors.bg },
    b = { fg = colors.fg,      bg = colors.bg },
    c = { fg = colors.fg,      bg = colors.bg },
  },
}

require('lualine').setup {
  options = {
    theme = iceberg,
    component_separators = { left = '|', right = '|' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      { 'branch' },
      {
        'diff',
        symbols = { added = '+', modified = '~', removed = '-' },
        diff_color = {
          added    = { fg = colors.added },
          modified = { fg = colors.changed },
          removed  = { fg = colors.removed },
        },
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1,
        symbols = { modified = '[+]', readonly = '[RO]', unnamed = '[No Name]' },
      },
    },
    lualine_x = {
      {
        'diagnostics',
        sources = { 'nvim_lsp' },
        symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
        diagnostics_color = {
          error = { fg = colors.error },
          warn  = { fg = colors.warning },
          info  = { fg = colors.info },
          hint  = { fg = colors.hint },
        },
      },
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'location' },
  },
}
