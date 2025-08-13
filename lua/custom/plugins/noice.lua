return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      messages = { view = 'mini', view_warn = 'mini' },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },
}
