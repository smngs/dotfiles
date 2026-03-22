require('claude-code').setup({
  window = {
    position = 'botright',
    split_ratio = 0.35,
  },
  keymaps = {
    toggle = {
      normal = '<leader>cc',
      terminal = '<leader>cc',
    },
    window_navigation = true,
  },
})
