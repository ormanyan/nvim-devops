-- Treesitter parsers for DevOps / networking work.
-- NvChad handles highlighting (vim.treesitter.start on FileType) and :TSInstallAll.
local parsers = {
  -- editor / meta
  "lua", "luadoc", "vim", "vimdoc", "printf", "query", "regex", "comment",
  "markdown", "markdown_inline", "diff", "gitcommit", "gitignore", "git_config", "git_rebase",
  -- config formats
  "yaml", "json", "json5", "toml", "ini", "xml", "csv", "properties", "editorconfig", "requirements",
  -- shell / scripting
  "bash", "fish", "awk", "python", "go", "gomod", "gosum", "gotmpl", "groovy", "ruby", "jq", "make", "cmake", "just",
  -- infra
  "dockerfile", "terraform", "hcl", "helm", "jinja", "jinja_inline", "starlark", "puppet", "nix",
  -- networking / system
  "ssh_config", "nginx", "caddy", "pem", "passwd", "udev", "http", "hurl", "kconfig", "proto", "sql", "mermaid",
  -- web (for the occasional dashboard/template)
  "html", "css", "javascript", "typescript", "graphql",
}

return {
  ensure_installed = parsers,
}
