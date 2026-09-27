require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- UI
o.cursorlineopt = "both"
o.relativenumber = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.colorcolumn = "120"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
o.showmode = false
o.conceallevel = 0 -- never hide quotes in JSON / YAML / Markdown

-- Editing (2 spaces is the DevOps default: YAML, HCL, JSON, Helm...)
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.smartindent = true
o.breakindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

-- Files
o.undofile = true
o.swapfile = false
o.backup = false
o.autoread = true
o.updatetime = 200
o.timeoutlen = 400

-- Splits
o.splitright = true
o.splitbelow = true

-- Folding via treesitter (start fully unfolded)
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

-- Spelling only in prose files (enabled per-filetype in autocmds)
o.spelllang = "en_us"

-- Clipboard: use system clipboard for all yanks/pastes
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- Recognise more config extensions natively
vim.filetype.add {
  extension = {
    tf = "terraform",
    tfvars = "terraform",
    hcl = "hcl",
    nomad = "hcl",
    pkr = "hcl",
    conf = "conf",
    ini = "dosini",
    env = "sh",
    jinja = "jinja",
    j2 = "jinja",
    tmpl = "gotmpl",
    gotmpl = "gotmpl",
    service = "systemd",
    timer = "systemd",
    socket = "systemd",
    mount = "systemd",
    target = "systemd",
    path = "systemd",
    netdev = "systemd",
    network = "systemd",
    link = "systemd",
    http = "http",
    rest = "http",
    hurl = "hurl",
    cfg = "cisco",
    ios = "cisco",
    nxos = "cisco",
    junos = "junos",
    crt = "pem",
    cer = "pem",
    pem = "pem",
    key = "pem",
    csr = "pem",
    zone = "bindzone",
    rules = "conf",
    nft = "conf",
  },
  filename = {
    [".env"] = "sh",
    [".envrc"] = "sh",
    ["Jenkinsfile"] = "groovy",
    ["Vagrantfile"] = "ruby",
    ["Brewfile"] = "ruby",
    ["Dockerfile"] = "dockerfile",
    ["Containerfile"] = "dockerfile",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    ["Chart.yaml"] = "yaml.helm-chart",
    ["values.yaml"] = "yaml.helm-values",
    ["kustomization.yaml"] = "yaml.kustomize",
    ["kustomization.yml"] = "yaml.kustomize",
    [".yamllint"] = "yaml",
    [".ansible-lint"] = "yaml",
    ["ansible.cfg"] = "dosini",
    ["hosts"] = "dosini",
    ["inventory"] = "dosini",
    ["sshd_config"] = "sshdconfig",
    ["ssh_config"] = "sshconfig",
    ["config"] = "sshconfig", -- ~/.ssh/config
    ["nginx.conf"] = "nginx",
    ["haproxy.cfg"] = "conf",
    ["Caddyfile"] = "caddy",
    ["dnsmasq.conf"] = "dnsmasq",
    ["named.conf"] = "named",
    ["wg0.conf"] = "dosini",
    ["sudoers"] = "sudoers",
    ["fstab"] = "fstab",
    ["crontab"] = "crontab",
    ["resolv.conf"] = "resolv",
    ["hosts.allow"] = "hostsaccess",
    ["hosts.deny"] = "hostsaccess",
    ["Makefile"] = "make",
    ["Tiltfile"] = "starlark",
    ["BUILD"] = "starlark",
    ["WORKSPACE"] = "starlark",
    ["go.mod"] = "gomod",
    ["go.sum"] = "gosum",
    ["Pipfile"] = "toml",
    ["poetry.lock"] = "toml",
    ["uv.lock"] = "toml",
  },
  pattern = {
    -- Ansible: playbooks / roles / group_vars etc. -> yaml.ansible so ansiblels attaches
    [".*/playbooks?/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/meta/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*"] = "yaml.ansible",
    [".*/host_vars/.*"] = "yaml.ansible",
    [".*/inventory/.*%.ya?ml"] = "yaml.ansible",
    [".*/molecule/.*%.ya?ml"] = "yaml.ansible",
    [".*playbook.*%.ya?ml"] = "yaml.ansible",
    [".*site%.ya?ml"] = "yaml.ansible",
    -- Helm templates
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/NOTES%.txt"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    -- GitHub / GitLab CI
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
    [".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    -- Kubernetes manifests (fallback; schema still detected by yamlls via content)
    [".*/k8s/.*%.ya?ml"] = "yaml.kubernetes",
    [".*/kubernetes/.*%.ya?ml"] = "yaml.kubernetes",
    [".*/manifests/.*%.ya?ml"] = "yaml.kubernetes",
    -- Systemd, networkd, wireguard, nginx sites
    ["/etc/systemd/.*"] = "systemd",
    ["/etc/wireguard/.*%.conf"] = "dosini",
    ["/etc/nginx/.*"] = "nginx",
    ["/etc/haproxy/.*"] = "conf",
    ["/etc/ssh/sshd_config%.d/.*"] = "sshdconfig",
    ["/etc/NetworkManager/.*%.nmconnection"] = "dosini",
    ["/etc/netplan/.*%.ya?ml"] = "yaml",
    ["/etc/iptables/.*"] = "conf",
    -- dotenv variants
    ["%.env%..*"] = "sh",
    -- Terraform lock file is HCL
    ["%.terraform%.lock%.hcl"] = "hcl",
  },
}
