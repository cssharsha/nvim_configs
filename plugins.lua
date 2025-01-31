local plugins = {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,  -- Important: Load immediately for tmux integration
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      git = {
        enable = true,
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = true,
          },
        },
      },
      view = {
        side = "left",
        width = 30,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
          },
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Custom mappings
        vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'sv', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 'sh', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'st', api.node.open.tab, opts('Open: New Tab'))
      end,
    },
  },
  {
    "nyngwang/NeoZoom.lua",
    lazy = false,
    config = function()
      require('neo-zoom').setup {
        winopts = {
          offset = {
            top = 0,
            left = 0,
            width = 150,
            height = 0.95,
          },
          border = "double",
        },
        exclude_filetypes = {
          "nvim-tree",
          "terminal",
        },
      }
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,  -- Important: Load immediately for tmux integration
    init = function()
      -- Disable default mappings
      vim.g.tmux_navigator_no_mappings = 1

      -- Enable focus events for better tmux integration
      vim.g.tmux_navigator_preserve_zoom = 1
      vim.opt.termguicolors = true
      vim.opt.updatetime = 300
      vim.opt.timeoutlen = 400
    end,
  },
    {
    "nvim-treesitter/nvim-treesitter",
    commit = "27f68c0b6a",  -- This commit is compatible with Neovim 0.9.5
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "lua",
      },
      highlight = {
        enable = true,
        use_languagetree = true,
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "Telescope",
    init = function()
      require("core.utils").load_mappings("telescope")
    end,
    opts = function()
      return require "plugins.configs.telescope"
    end,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
    end,
  },
}

return plugins
