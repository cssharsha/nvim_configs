-- lua/custom/configs/lspconfig.lua
local config = require("plugins.configs.lspconfig")
local capabilities = config.capabilities
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

-- Function to find the Bazel workspace root
local function find_bazel_workspace_root(fname)
    return util.root_pattern("WORKSPACE", "WORKSPACE.bazel")(fname) or
           util.root_pattern(".bazelrc")(fname) or
           util.find_git_ancestor(fname)
end

-- Function to get compilation database directory
local function get_compile_commands_dir(root_dir)
    local compile_commands_paths = {
        root_dir .. "/compile_commands.json",
        root_dir .. "/bazel-bin/compile_commands.json",
        root_dir .. "/bazel-" .. vim.fn.fnamemodify(root_dir, ":t") .. "/compile_commands.json"
    }

    for _, path in ipairs(compile_commands_paths) do
        if vim.fn.filereadable(path) == 1 then
            return vim.fn.fnamemodify(path, ":h")
        end
    end

    return root_dir
end

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = "always",
        spacing = 4,
    },
    float = {
        source = "always",
        border = "rounded",
        header = "",
        prefix = "",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Set up diagnostic signs
local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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

-- Function to get clangd command with compile commands directory
local function get_clangd_cmd()
    local root = find_bazel_workspace_root(vim.fn.getcwd())
    local compile_commands_dir = root and get_compile_commands_dir(root) or ""

    local cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--fallback-style=llvm",
        "--enable-config",
        "--offset-encoding=utf-16",
        "--pch-storage=memory",
    }

    if compile_commands_dir ~= "" then
        table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
    end

    return cmd
end

-- Initial clangd setup
lspconfig.clangd.setup {
    on_attach = function(client, bufnr)
        config.on_attach(client, bufnr)
        setup_format_on_save(client, bufnr)

        -- Enhanced keymaps for diagnostics and navigation
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- Diagnostic navigation
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

        -- Code navigation
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

        -- Symbol navigation
        vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
        vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)

        -- Code actions and refactoring
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- Information
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

        -- Source/Header switching
        vim.keymap.set("n", "<leader>sh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)

        -- Formatting
        vim.keymap.set("n", "<leader>fm", function()
            vim.lsp.buf.format({ timeout_ms = 2000 })
        end, opts)

        -- Workspace management
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
    end,
    capabilities = capabilities,
    cmd = get_clangd_cmd(),
    root_dir = find_bazel_workspace_root,
    init_options = {
        compilationDatabasePath = get_compile_commands_dir(find_bazel_workspace_root(vim.fn.getcwd()) or ""),
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticHighlighting = true,
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}

-- Function to restart clangd
local function restart_clangd()
    -- Stop all clangd clients
    local active_clients = vim.lsp.get_active_clients({ name = "clangd" })
    for _, client in ipairs(active_clients) do
        vim.lsp.stop_client(client.id, true)
    end

    -- Wait briefly to ensure cleanup
    vim.defer_fn(function()
        -- Store current buffer
        local current_buf = vim.api.nvim_get_current_buf()

        -- Start clangd for all C/C++ buffers
        local buffers = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(buffers) do
            if vim.api.nvim_buf_is_valid(bufnr) then
                local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
                if ft == "c" or ft == "cpp" or ft == "cuda" then
                    vim.cmd("buffer " .. bufnr)
                    vim.cmd("LspStart clangd")
                end
            end
        end

        -- Return to original buffer
        vim.cmd("buffer " .. current_buf)
        vim.notify("Clangd restarted", vim.log.levels.INFO)
    end, 100)
end

-- Add commands for restarting clangd
vim.api.nvim_create_user_command("ClangdRestart", restart_clangd, {
    desc = "Restart clangd server"
})

-- Add keymapping for restarting clangd
vim.keymap.set("n", "<leader>cr", restart_clangd, { noremap = true, silent = true })

-- Generate compile_commands.json automatically when needed
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.cpp", "*.cc", "*.h", "hpp", "*.cu" },
    callback = function()
        local root_dir = find_bazel_workspace_root(vim.fn.expand("%:p"))
        if root_dir and vim.fn.filereadable(root_dir .. "/compile_commands.json") == 0 then
            vim.fn.system("cd " .. root_dir .. " && bazel run @hedron_compile_commands//:refresh_compile_commands")
        end
    end,
})
