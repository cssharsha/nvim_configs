-- Configure treesitter
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
  callback = function()
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = false
  end,
})

-- Optional: Add this if you want treesitter to not slow down big files
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  callback = function()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > 100 * 1024 then -- 100 KB
      vim.cmd("TSBufDisable highlight")
    end
  end,
})

-- Terminal-specific settings for tmux
vim.opt.title = true
vim.opt.titlestring = "%{expand('%:p')}"
vim.g.focused_split = vim.api.nvim_get_current_win()

-- Basic syntax highlighting
vim.cmd("syntax enable")

-- Dashboard configuration
local status_ok, alpha = pcall(require, "alpha")
if status_ok then
    local dashboard = require("alpha.themes.dashboard")
    
    -- Custom header
    dashboard.section.header.val = {
        [[                                                    ]],
        [[                                                    ]],
        [[                                                    ]],
        [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                                                    ]],
        [[                 [ Let's Code! ]                    ]],
        [[                                                    ]],
    }

    -- Menu options
    dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("s", "  Settings", ":e $MYVIMRC<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    -- Footer
    local function footer()
        local total_plugins = #vim.tbl_keys(packer_plugins)
        local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
        return "⚡ " .. total_plugins .. " plugins loaded" .. datetime
    end

    dashboard.section.footer.val = footer()

    -- Layout
    dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
    }

    -- Send config to alpha
    alpha.setup(dashboard.config)

    -- Automatically open alpha when no files are specified
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            local should_skip = false
            if vim.fn.argc() > 0 or vim.fn.line2byte('$') ~= -1 or not vim.o.modifiable then
                should_skip = true
            else
                for _, arg in pairs(vim.v.argv) do
                    if arg == '-b' or arg == '-c' or vim.startswith(arg, '+') or arg == '-S' then
                        should_skip = true
                        break
                    end
                end
            end
            if not should_skip then
                require('alpha').start()
            end
        end,
    })
end

-- Basic settings for development
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
