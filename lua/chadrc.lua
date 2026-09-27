-- NvChad main config. Structure mirrors:
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "onedark" },
  transparency = false,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    -- make YAML keys / HCL attributes pop a bit more
    ["@property.yaml"] = { fg = "blue" },
    ["@property"] = { fg = "blue" },
  },
}

M.ui = {
  cmp = { style = "atom_colored", icons_left = true },
  telescope = { style = "bordered" },
  statusline = {
    theme = "vscode_colored",
    separator_style = "block",
  },
  tabufline = { enabled = true, lazyload = false },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                                                    ",
    "  ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗",
    "  ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝",
    "  ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗",
    "  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║",
    "  ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║",
    "  ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝",
    "         infra · network · automation · nvim        ",
    "                                                    ",
  },
  buttons = {
    { txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
    { txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
    { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep" },
    { txt = "  Git Status", keys = "gg", cmd = "LazyGit" },
    { txt = "  Keymap Help", keys = "?", cmd = "edit ~/.config/nvim/docs/KEYMAPS.md" },
    { txt = "󱥚  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()" },
    { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashFooter",
      no_gap = true,
      content = "fit",
    },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  },
}

M.term = {
  sizes = { sp = 0.35, vsp = 0.35, ["bo sp"] = 0.35, ["bo vsp"] = 0.35 },
  float = { relative = "editor", row = 0.15, col = 0.15, width = 0.7, height = 0.7, border = "rounded" },
}

M.lsp = { signature = true }

M.cheatsheet = {
  theme = "grid",
  excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" },
}

-- Extra Mason packages that are not auto-detected from LSP / conform / nvim-lint.
-- :MasonInstallAll installs these + everything referenced in lspconfig/conform/lint.
M.mason = {
  pkgs = {
    "yq",
    "jq",
    "ruff",
    "systemd-lsp",
    "tree-sitter-cli", -- needed by nvim-treesitter (main) to build parsers
  },
  skip = {},
}

return M
