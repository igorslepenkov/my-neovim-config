-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'xiyaowong/transparent.nvim',
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('typescript-tools').setup {
        settings = {
          tsserver_plugins = {
            '@styled/typescript-styled-plugin',
          },
        },
      }
    end,
  },
  {
    'tpope/vim-fugitive',
  },
  {
    'sindrets/diffview.nvim',
  },
  {
    'christoomey/vim-tmux-navigator',
  },
  {
    'mfussenegger/nvim-jdtls',
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)
    end,
  },
  {
    'ThePrimeagen/git-worktree.nvim',
    config = function()
      require('telescope').load_extension 'git_worktree'

      vim.keymap.set('n', '<leader>st', require('telescope').extensions.git_worktree.git_worktrees, { desc = '[S]earch Git Work[T]ree' })
      vim.keymap.set('n', '<leader>cw', require('telescope').extensions.git_worktree.create_git_worktree, { desc = '[C]reate Git [W]orktree' })
    end,
  },
}
