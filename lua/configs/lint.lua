local lint = require "lint"

lint.linters_by_ft = {
  yaml = { "yamllint" },
  ["yaml.kubernetes"] = { "yamllint" },
  ["yaml.docker-compose"] = { "yamllint" },
  ["yaml.github"] = { "yamllint" },
  ["yaml.gitlab"] = { "yamllint" },
  ["yaml.helm-values"] = { "yamllint" },
  ["yaml.kustomize"] = { "yamllint" },
  ["yaml.ansible"] = { "ansible_lint" },
  dockerfile = { "hadolint" },
}

-- Relaxed yamllint rules that fit k8s / compose / CI files
local yamllint_cfg = table.concat({
  "{extends: default, rules: {",
  "line-length: {max: 160, allow-non-breakable-inline-mappings: true},",
  "document-start: disable,",
  "truthy: {check-keys: false},",
  "comments: {min-spaces-from-content: 1},",
  "comments-indentation: disable,",
  "indentation: {spaces: consistent, indent-sequences: consistent},",
  "braces: {max-spaces-inside: 1},",
  "brackets: {max-spaces-inside: 1}",
  "}}",
}, " ")
lint.linters.yamllint.args = { "-d", yamllint_cfg, "--format", "parsable", "-" }

local grp = vim.api.nvim_create_augroup("devops_lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = grp,
  callback = function()
    if vim.g.lint_disabled or vim.bo.buftype ~= "" then
      return
    end
    lint.try_lint(nil, { ignore_errors = true })
  end,
})

vim.api.nvim_create_user_command("LintToggle", function()
  vim.g.lint_disabled = not vim.g.lint_disabled
  vim.notify("linting: " .. (vim.g.lint_disabled and "OFF" or "ON"))
  if not vim.g.lint_disabled then
    lint.try_lint()
  end
end, { desc = "toggle nvim-lint" })

vim.api.nvim_create_user_command("Lint", function()
  lint.try_lint()
end, { desc = "run linters now" })
