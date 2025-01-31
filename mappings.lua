local M = {}

M.lspconfig = {
  n = {
    ["<leader>gd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      "LSP definition",
    },
    ["<leader>K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "LSP hover",
    },
    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end,
      "LSP format",
    },
  },
}

M.nvimtree = {
  n = {
    ["<C-n>"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
    ["<C-e>"] = { "<cmd> NvimTreeFocus <CR>", "Focus nvimtree" },
  }
}

M.tmux = {
  n = {
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "Navigate tmux left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "Navigate tmux right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "Navigate tmux down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "Navigate tmux up" },
  }
}

M.zoom = {
  n = {
    ["<C-w>z"] = { "<cmd>NeoZoomToggle<CR>", "Toggle zoom" },
    ["<leader>z"] = { "<cmd>NeoZoomToggle<CR>", "Toggle zoom" },  -- Alternative mapping
  }
}

M.telescope = {
  n = {
    ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find files" },
    ["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
  },
}

return M
