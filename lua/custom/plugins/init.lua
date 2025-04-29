-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'xiyaowong/transparent.nvim',
  },
  -- {
  --   'pmizio/typescript-tools.nvim',
  --   dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  --   config = function()
  --     require('typescript-tools').setup {
  --       settings = {
  --         tsserver_plugins = {
  --           '@styled/typescript-styled-plugin',
  --         },
  --       },
  --     }
  --   end,
  -- },
  {
    'tpope/vim-fugitive',
  },
  {
    'sindrets/diffview.nvim',
  },
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<c-j>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-;>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
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
  -- {
  --   'ThePrimeagen/git-worktree.nvim',
  --   config = function()
  --     require('telescope').load_extension 'git_worktree'
  --
  --     vim.keymap.set('n', '<leader>st', require('telescope').extensions.git_worktree.git_worktrees, { desc = '[S]earch Git Work[T]ree' })
  --     vim.keymap.set('n', '<leader>cw', require('telescope').extensions.git_worktree.create_git_worktree, { desc = '[C]reate Git [W]orktree' })
  --   end,
  -- },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local language_servers = vim.lsp.get_clients() -- or list servers manually like {'gopls', 'clangd'}
      for _, ls in ipairs(language_servers) do
        require('lspconfig')[ls].setup {
          capabilities = capabilities,
        }
      end

      require('ufo').setup {
        provider_selector = function()
          return { 'lsp', 'indent' }
        end,
      }
    end,
  },
}
