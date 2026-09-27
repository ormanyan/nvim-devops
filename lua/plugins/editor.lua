-- General editing quality-of-life plugins.
return {
  -- Jump anywhere on screen with `s` + 2 chars
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "flash treesitter select" },
    },
  },

  -- Surround: ys{motion}{char}, ds{char}, cs{old}{new}
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Diagnostics / references / quickfix in a nice list
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true, auto_close = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "trouble: all diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "trouble: buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "trouble: symbols outline" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", desc = "trouble: references" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "trouble: quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "trouble: loclist" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "trouble: TODO / FIXME" },
    },
  },

  -- Highlight & find TODO / FIXME / HACK / NOTE comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "prev TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "find TODOs" },
    },
  },

  -- Seamless <C-h/j/k/l> across nvim and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },

  -- Project-wide search & replace UI
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80 },
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "search & replace (project)" },
      { "<leader>sw", function() require("grug-far").open { prefills = { search = vim.fn.expand "<cword>" } } end, desc = "search & replace word under cursor" },
      { "<leader>sf", function() require("grug-far").open { prefills = { paths = vim.fn.expand "%" } } end, desc = "search & replace in this file" },
    },
  },

  -- Show keymap help / inline hints for LSP progress
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = { notification = { window = { winblend = 0 } } },
  },

  -- Better `%` and highlighted word under cursor
  { "RRethy/vim-illuminate", event = { "BufReadPost", "BufNewFile" }, config = function() require("illuminate").configure { delay = 200, large_file_cutoff = 2000 } end },

  -- Persist sessions per directory (:SessionRestore / auto on start with dir argument)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "session: restore for cwd" },
      { "<leader>ql", function() require("persistence").load { last = true } end, desc = "session: restore last" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "session: don't save on exit" },
    },
  },

  -- Treesitter text objects: select/move by function, class, parameter, block
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup { select = { lookahead = true } }
      local sel = require "nvim-treesitter-textobjects.select"
      local map = vim.keymap.set
      map({ "x", "o" }, "af", function() sel.select_textobject("@function.outer", "textobjects") end, { desc = "a function" })
      map({ "x", "o" }, "if", function() sel.select_textobject("@function.inner", "textobjects") end, { desc = "inner function" })
      map({ "x", "o" }, "ab", function() sel.select_textobject("@block.outer", "textobjects") end, { desc = "a block" })
      map({ "x", "o" }, "ib", function() sel.select_textobject("@block.inner", "textobjects") end, { desc = "inner block" })
      map({ "x", "o" }, "aa", function() sel.select_textobject("@parameter.outer", "textobjects") end, { desc = "a parameter" })
      map({ "x", "o" }, "ia", function() sel.select_textobject("@parameter.inner", "textobjects") end, { desc = "inner parameter" })
    end,
  },
}
