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

return M
