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
    'goolord/alpha-nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify"
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
          view = "cmdline_popup", -- or "cmdline" for default
        },
      })
    end
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

        -- File operations
        vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
        vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
        vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
        vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
        vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))

        -- Existing custom mappings
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
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}

return plugins
