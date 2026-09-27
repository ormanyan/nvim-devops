-- LSP servers. NvChad's defaults() already sets capabilities/on_attach for "*" and enables lua_ls.
require("nvchad.configs.lspconfig").defaults()

local ok_schemastore, schemastore = pcall(require, "schemastore")

----------------------------------------------------------------------
-- YAML (Kubernetes, Compose, GitHub Actions, GitLab CI, Helm values ...)
----------------------------------------------------------------------
local yaml_schemas = ok_schemastore and schemastore.yaml.schemas {
  extra = {
    {
      name = "Argo CD Application",
      description = "Argo CD Application/AppProject",
      fileMatch = { "argocd/**/*.yaml", "argo/**/*.yaml" },
      url = "https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/crds/application-crd.yaml",
    },
  },
} or {}

-- yaml-language-server ships its own kubernetes schema under the special "kubernetes" key
yaml_schemas["kubernetes"] = {
  "*.k8s.yaml", "*.k8s.yml",
  "k8s/**/*.yaml", "k8s/**/*.yml",
  "kubernetes/**/*.yaml", "kubernetes/**/*.yml",
  "manifests/**/*.yaml", "manifests/**/*.yml",
  "deploy/**/*.yaml", "deploy/**/*.yml",
  "**/templates/**/*.yaml",
  "deployment*.yaml", "service*.yaml", "ingress*.yaml", "configmap*.yaml", "secret*.yaml",
  "namespace*.yaml", "statefulset*.yaml", "daemonset*.yaml", "cronjob*.yaml", "job*.yaml",
  "pvc*.yaml", "pv*.yaml", "rbac*.yaml", "serviceaccount*.yaml", "networkpolicy*.yaml", "hpa*.yaml",
}

vim.lsp.config("yamlls", {
  filetypes = {
    "yaml", "yaml.docker-compose", "yaml.kubernetes", "yaml.github", "yaml.gitlab",
    "yaml.helm-chart", "yaml.helm-values", "yaml.kustomize",
  },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      schemaStore = { enable = false, url = "" }, -- we use SchemaStore.nvim instead
      schemas = yaml_schemas,
      validate = true,
      hover = true,
      completion = true,
      format = { enable = false }, -- conform handles formatting
      keyOrdering = false,
      -- CloudFormation intrinsic functions + Ansible vault
      customTags = {
        "!vault", "!vault scalar",
        "!Ref", "!Sub", "!Sub sequence", "!GetAtt", "!GetAtt sequence", "!Join sequence", "!Select sequence",
        "!Split sequence", "!If sequence", "!Equals sequence", "!Not sequence", "!And sequence", "!Or sequence",
        "!FindInMap sequence", "!Base64", "!Cidr sequence", "!ImportValue", "!Condition", "!Transform mapping",
      },
    },
  },
})

----------------------------------------------------------------------
-- JSON with SchemaStore
----------------------------------------------------------------------
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = ok_schemastore and schemastore.json.schemas() or {},
      validate = { enable = true },
    },
  },
})

----------------------------------------------------------------------
-- Ansible
----------------------------------------------------------------------
vim.lsp.config("ansiblels", {
  filetypes = { "yaml.ansible" },
  settings = {
    ansible = {
      ansible = { path = "ansible", useFullyQualifiedCollectionNames = true },
      executionEnvironment = { enabled = false },
      python = { interpreterPath = "python3" },
      validation = { enabled = true, lint = { enabled = true, path = "ansible-lint" } },
    },
  },
})

----------------------------------------------------------------------
-- Terraform / HCL
----------------------------------------------------------------------
vim.lsp.config("terraformls", {
  filetypes = { "terraform", "terraform-vars", "hcl" },
  settings = {
    terraform = { experimentalFeatures = { validateOnSave = true, prefillRequiredFields = true } },
  },
})
vim.lsp.config("tflint", { filetypes = { "terraform" } })

----------------------------------------------------------------------
-- Docker / Compose / Helm
----------------------------------------------------------------------
vim.lsp.config("dockerls", {
  settings = { docker = { languageserver = { formatter = { ignoreMultilineInstructions = true } } } },
})
vim.lsp.config("docker_compose_language_service", { filetypes = { "yaml.docker-compose" } })
vim.lsp.config("helm_ls", {
  filetypes = { "helm" },
  settings = {
    ["helm-ls"] = {
      yamlls = { enabled = true, path = "yaml-language-server" },
      valuesFiles = { mainValuesFile = "values.yaml", lintOverlayValuesFile = "values.lint.yaml", additionalValuesFilesGlobPattern = "values*.yaml" },
    },
  },
})

----------------------------------------------------------------------
-- Shell / Python / Go / TOML / Markdown / systemd
----------------------------------------------------------------------
vim.lsp.config("bashls", {
  filetypes = { "sh", "bash", "zsh" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      shellcheckPath = "shellcheck",
      shfmt = { path = "shfmt", simplifyCode = true, caseIndent = true },
    },
  },
})
vim.lsp.config("basedpyright", {
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard", autoImportCompletions = true } } },
})
vim.lsp.config("gopls", {
  settings = { gopls = { gofumpt = true, staticcheck = true, analyses = { unusedparams = true } } },
})
vim.lsp.config("taplo", {})
vim.lsp.config("marksman", {})
-- nginx-language-server is NOT enabled: its Mason package needs Python < 3.14 (Garuda ships 3.14).
-- nginx files still get treesitter highlighting and `nginx -t` via <leader>dv. Re-add here if you need it.
-- systemd units: JFryy/systemd-lsp (Mason package "systemd-lsp", listed in chadrc M.mason.pkgs)
vim.lsp.config("systemd_lsp", {
  cmd = { "systemd-lsp" },
  filetypes = { "systemd" },
  root_markers = { ".git" },
})

vim.lsp.enable {
  "yamlls",
  "jsonls",
  "ansiblels",
  "terraformls",
  "tflint",
  "dockerls",
  "docker_compose_language_service",
  "helm_ls",
  "bashls",
  "basedpyright",
  "gopls",
  "taplo",
  "marksman",
  "systemd_lsp",
}

-- Nicer diagnostics: virtual text only for errors/warnings, float on hover via <leader>lf
vim.diagnostic.config {
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN }, spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
}
