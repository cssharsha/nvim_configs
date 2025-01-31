-- Auto open NvimTree when Neovim starts with proper tmux handling
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    -- Only open NvimTree if we're not in a git commit message
    local commit_msg = vim.fn.expand('%:t')
    if commit_msg ~= 'COMMIT_EDITMSG'
      and commit_msg ~= 'MERGE_MSG'
      and commit_msg ~= 'git-rebase-todo' then
      require("nvim-tree.api").tree.open()
    end
  end,
})

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

-- Basic settings for development
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
