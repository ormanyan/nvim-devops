require "nvchad.autocmds"

local au = vim.api.nvim_create_autocmd
local grp = function(name)
  return vim.api.nvim_create_augroup("devops_" .. name, { clear = true })
end

-- Highlight yanked text briefly
au("TextYankPost", {
  group = grp "yank",
  callback = function()
    vim.hl.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})

-- Strip trailing whitespace on save (but not in markdown / diff / pem)
au("BufWritePre", {
  group = grp "trim_ws",
  callback = function()
    local ft = vim.bo.filetype
    if vim.tbl_contains({ "markdown", "diff", "gitcommit", "pem" }, ft) then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})

-- Return to last cursor position when reopening a file
au("BufReadPost", {
  group = grp "last_pos",
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lc = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lc then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-create parent directories when saving a new file
au("BufWritePre", {
  group = grp "mkdir",
  callback = function(ev)
    if ev.match:match "^%w%w+:[\\/][\\/]" then
      return
    end
    local dir = vim.fn.fnamemodify(ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Reload files changed on disk (handy when tools rewrite configs)
au({ "FocusGained", "BufEnter", "CursorHold", "TermClose" }, {
  group = grp "checktime",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd "checktime"
    end
  end,
})

-- Per-filetype indentation / behaviour
au("FileType", {
  group = grp "indent",
  pattern = { "go", "make", "gomod", "gosum" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

au("FileType", {
  group = grp "indent4",
  pattern = { "python", "groovy", "dockerfile", "sh", "bash", "fish" },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- YAML: 2 spaces, indent-aware keys, and hyphens continue lists cleanly
au("FileType", {
  group = grp "yaml",
  pattern = { "yaml", "yaml.ansible", "yaml.docker-compose", "yaml.kubernetes", "yaml.github", "yaml.gitlab", "helm" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
    vim.opt_local.indentkeys:remove "0#"
    vim.opt_local.indentkeys:remove "<:>"
    vim.opt_local.foldlevel = 99
  end,
})

-- Prose: wrap + spell
au("FileType", {
  group = grp "prose",
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 0
  end,
})

-- Close some buffers with just `q`
au("FileType", {
  group = grp "quick_close",
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "notify", "trouble", "query", "git", "fugitive" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "close window" })
  end,
})

-- Simple syntax fallbacks for network-device config filetypes that have no treesitter parser
au("FileType", {
  group = grp "netconf_syntax",
  pattern = { "cisco", "junos", "caddy", "bindzone", "pem" },
  callback = function()
    vim.bo.commentstring = ({
      cisco = "! %s",
      junos = "# %s",
      caddy = "# %s",
      bindzone = "; %s",
      pem = "# %s",
    })[vim.bo.filetype]
    vim.opt_local.list = false
  end,
})

-- Large files: turn off expensive features
au("BufReadPre", {
  group = grp "bigfile",
  callback = function(ev)
    local ok, stat = pcall(vim.uv.fs_stat, ev.match)
    if ok and stat and stat.size > 2 * 1024 * 1024 then -- 2 MB
      vim.b[ev.buf].bigfile = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.opt_local.list = false
      vim.opt_local.undofile = false
    end
  end,
})

-- Show a short hint the first time a devops filetype opens (LSP name)
au("LspAttach", {
  group = grp "lsp_hint",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and not vim.g.__lsp_hint_shown then
      vim.g.__lsp_hint_shown = true
      vim.notify(("LSP attached: %s   (<leader>? for keymap help)"):format(client.name), vim.log.levels.INFO)
    end
  end,
})
