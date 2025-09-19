-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    default_component_configs = {
      indent = {
        indent_size = 0.5,
        padding = 0,
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        position = 'left',
        width = 27,
        mappings = {
          ['\\'] = 'close_window',
          ['h'] = 'noop',
          ['j'] = 'noop',
          ['l'] = 'noop',
          [';'] = 'noop',
          ['k'] = 'noop',
        },
      },
    },
  },
}
