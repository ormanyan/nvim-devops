-- Formatters. Use <leader>fm to format; format-on-save is limited to filetypes
-- where it is always safe (terraform, go, lua). Toggle with :FormatOnSaveToggle.
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    python = { "ruff_format" },
    go = { "goimports", "gofmt" },
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    ["yaml.docker-compose"] = { "prettier" },
    ["yaml.github"] = { "prettier" },
    ["yaml.gitlab"] = { "prettier" },
    ["yaml.kubernetes"] = { "prettier" },
    ["yaml.helm-values"] = { "prettier" },
    ["yaml.helm-chart"] = { "prettier" },
    ["yaml.kustomize"] = { "prettier" },
    ["yaml.ansible"] = { "prettier" },
    markdown = { "prettier" },
    toml = { "taplo" },
    ["*"] = { "trim_whitespace" },
  },

  formatters = {
    shfmt = { prepend_args = { "-i", "4", "-ci", "-bn" } },
    prettier = { prepend_args = { "--prose-wrap", "preserve" } },
  },

  format_on_save = function(bufnr)
    if vim.g.format_on_save_disabled or vim.b[bufnr].format_on_save_disabled then
      return nil
    end
    local safe = { terraform = true, ["terraform-vars"] = true, go = true, lua = true }
    if not safe[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 1500, lsp_format = "fallback" }
  end,
}

vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
  vim.g.format_on_save_disabled = not vim.g.format_on_save_disabled
  vim.notify("format on save: " .. (vim.g.format_on_save_disabled and "OFF" or "ON (tf/go/lua)"))
end, { desc = "toggle format-on-save" })

return options
