-- DevOps / infrastructure / networking plugins.
return {
  -- JSON / YAML schemas for k8s, compose, GH Actions, Helm Chart.yaml, etc.
  { "b0o/SchemaStore.nvim", lazy = true },

  -- Linters that are not LSPs (yamllint, ansible-lint, hadolint)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      require "configs.lint"
    end,
  },

  -- Mason tools that are not LSPs (formatters, linters) install via :MasonInstallAll

  -- Helm chart templates: proper filetype + gotmpl injection
  { "towolf/vim-helm", ft = "helm" },

  -- Ansible: filetype detection helpers + :AnsibleRun
  {
    "mfussenegger/nvim-ansible",
    ft = { "yaml.ansible" },
    keys = {
      { "<leader>ar", function() require("ansible").run() end, desc = "ansible: run playbook/role", ft = "yaml.ansible" },
      { "<leader>ar", function() require("ansible").run() end, mode = "v", desc = "ansible: run selection", ft = "yaml.ansible" },
    },
  },

  -- Kubernetes dashboard inside nvim (needs kubectl + a kubeconfig)
  {
    "ramilito/kubectl.nvim",
    version = "2.*",
    dependencies = "saghen/blink.download",
    cmd = { "Kubectl", "Kubectx", "Kubens" },
    keys = {
      { "<leader>kk", "<cmd>Kubectl<CR>", desc = "kubectl: open dashboard" },
      { "<leader>kx", "<cmd>Kubectx<CR>", desc = "kubectl: switch context" },
      { "<leader>kn", "<cmd>Kubens<CR>", desc = "kubectl: switch namespace" },
    },
    opts = {
      kubectl_cmd = { cmd = "kubectl", env = {}, args = {} },
      namespace = "All",
      auto_refresh = { enabled = true, interval = 300 },
      diff = { bin = "kubediff" },
      lineage = { enabled = false },
    },
  },

  -- HTTP client for testing APIs / webhooks / health endpoints (*.hurl files, runs via the `hurl` CLI)
  {
    "jellydn/hurl.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = "hurl",
    cmd = { "HurlRunner", "HurlRunnerAt", "HurlRunnerToEntry", "HurlRunnerToEnd", "HurlVerbose", "HurlToggleMode", "HurlSetVariable", "HurlManageVariable", "HurlShowLastResponse" },
    keys = {
      { "<leader>rr", "<cmd>HurlRunnerAt<CR>", desc = "hurl: run request under cursor", ft = "hurl" },
      { "<leader>ra", "<cmd>HurlRunner<CR>", desc = "hurl: run all requests in file", ft = "hurl" },
      { "<leader>rr", ":HurlRunner<CR>", mode = "v", desc = "hurl: run selected requests", ft = "hurl" },
      { "<leader>re", "<cmd>HurlRunnerToEntry<CR>", desc = "hurl: run from start to this entry", ft = "hurl" },
      { "<leader>rE", "<cmd>HurlRunnerToEnd<CR>", desc = "hurl: run from this entry to end", ft = "hurl" },
      { "<leader>rv", "<cmd>HurlVerbose<CR>", desc = "hurl: run verbose (headers/timings)", ft = "hurl" },
      { "<leader>rt", "<cmd>HurlToggleMode<CR>", desc = "hurl: toggle split/popup", ft = "hurl" },
      { "<leader>rs", "<cmd>HurlSetVariable<CR>", desc = "hurl: set variable", ft = "hurl" },
      { "<leader>rm", "<cmd>HurlManageVariable<CR>", desc = "hurl: manage variables", ft = "hurl" },
      { "<leader>rl", "<cmd>HurlShowLastResponse<CR>", desc = "hurl: show last response", ft = "hurl" },
    },
    opts = {
      debug = false,
      show_notification = false,
      mode = "split",
      formatters = {
        json = { "jq" },
        html = { "prettier", "--parser", "html" },
      },
      mappings = { close = "q", next_panel = "<C-n>", prev_panel = "<C-p>" },
    },
  },

  -- Git: lazygit in a float, diffview for reviewing changes / history
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      vim.g.lazygit_floating_window_use_plenary = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = { enhanced_diff_hl = true, view = { merge_tool = { layout = "diff3_mixed" } } },
  },

  -- Network device configs: Cisco IOS / NX-OS / ASA and Junos syntax highlighting
  { "momota/cisco.vim", ft = "cisco" },
  { "momota/junos.vim", ft = "junos" },

  -- Markdown rendering for runbooks / READMEs
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = { code = { sign = false, width = "block", right_pad = 1 }, heading = { sign = false, icons = {} } },
  },

  -- Colored matching brackets (JSON / HCL / nested YAML flow maps)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup").setup {}
    end,
  },

  -- Extra devops snippets for LuaSnip (k8s, compose, terraform, gh actions, ansible ...)
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      require "snippets.devops" -- lua/snippets/devops.lua (k8s, compose, terraform, ansible, bash, docker)
      return opts
    end,
  },
}
