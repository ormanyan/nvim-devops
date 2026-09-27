-- Overrides / extensions of plugins that NvChad already ships.
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/SchemaStore.nvim" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "configs.treesitter",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = { dotfiles = false, git_ignored = false, custom = { "^.git$", "^.terraform$", "^node_modules$", "^__pycache__$" } },
      git = { enable = true, ignore = false },
      view = { width = 34, side = "left" },
      renderer = {
        highlight_git = true,
        indent_markers = { enable = true },
        icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
      },
      update_focused_file = { enable = true, update_root = false },
      actions = { open_file = { quit_on_open = false, resize_window = true } },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    opts = function()
      local conf = require "nvchad.configs.telescope"
      conf.extensions_list = { "themes", "terms", "fzf", "ui-select" }
      conf.defaults.file_ignore_patterns = { "%.git/", "node_modules/", "%.terraform/", "__pycache__/", "%.lock$" }
      conf.defaults.path_display = { "truncate" }
      conf.defaults.layout_config = { horizontal = { preview_width = 0.55 }, width = 0.9, height = 0.85 }
      conf.pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { "--hidden" } },
      }
      conf.extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
        ["ui-select"] = { require("telescope.themes").get_dropdown {} },
      }
      return conf
    end,
  },

  {
    "folke/which-key.nvim",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>f", group = "find / files" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>d", group = "devops" },
        { "<leader>k", group = "kubernetes" },
        { "<leader>a", group = "ansible" },
        { "<leader>t", group = "terraform / toggles" },
        { "<leader>n", group = "network" },
        { "<leader>j", group = "json / yaml" },
        { "<leader>r", group = "run / requests" },
        { "<leader>x", group = "diagnostics / trouble" },
        { "<leader>w", group = "workspace / windows" },
        { "<leader>c", group = "code / copy" },
        { "<leader>b", group = "buffers" },
        { "<leader>s", group = "search / replace" },
        { "<leader>u", group = "ui toggles" },
        { "<leader>q", group = "quit / session" },
        { "<leader>p", group = "pick" },
        { "<leader>m", group = "marks / markdown" },
        { "<leader>?", desc = "keymap help (docs/KEYMAPS.md)" },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = false,
      current_line_blame_opts = { delay = 300 },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  -- Mason: make the window pretty and open the core packages quickly
  {
    "mason-org/mason.nvim",
    opts = { ui = { border = "rounded" } },
  },
}
