local config = require("plugins.configs.lspconfig")
local capabilities = config.capabilities

local lspconfig = require("lspconfig")

-- Function to set up format on save
local function setup_format_on_save(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ 
          bufnr = bufnr,
          timeout_ms = 2000,
        })
      end,
    })
  end
end

-- Modified on_attach function
local on_attach = function(client, bufnr)
  config.on_attach(client, bufnr)
  setup_format_on_save(client, bufnr)
end

lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--fallback-style=llvm",  -- Use LLVM style as fallback
  },
}
