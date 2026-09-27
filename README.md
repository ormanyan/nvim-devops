# DevOps & Networking Neovim (NvChad based)

A batteries-included Neovim setup built on [NvChad v2.5](https://nvchad.com) and tuned for
infrastructure work: Kubernetes, Helm, Docker/Compose, Terraform, Ansible, CI pipelines, shell,
and network device / daemon configs (Cisco, Junos, nginx, HAProxy, WireGuard, systemd, sshd, DNS zones…).

* **Keymap reference:** [docs/KEYMAPS.md](docs/KEYMAPS.md) or press `Space ?` inside nvim.
* Leader key is **Space**. Press it and wait: which-key lists every group.

---

## Install (Arch / Garuda)

```bash
cd ~/Desktop/claude/nvim
./install.sh          # asks for sudo once; installs packages, links ~/.config/nvim, bootstraps plugins
```

Then set your terminal font to **JetBrainsMono Nerd Font** and start `nvim`.

What the script does:

1. `pacman -S` neovim, ripgrep, fd, fzf, lazygit, jq, yq, node, python, go, shellcheck, shfmt,
   yamllint, ansible(+lint), terraform, tflint, kubectl, helm, docker, bind (dig), traceroute,
   whois, nmap, hurl, JetBrainsMono Nerd Font. `hadolint` via paru/yay if present (else Mason installs it).
2. Symlinks `~/.config/nvim` → this directory (an existing config is moved to `nvim.bak.<ts>`).
3. Headlessly runs `Lazy sync`, installs treesitter parsers, and `MasonInstallAll`.

`FRESH=1 ./install.sh` also wipes `~/.local/share/nvim` for a clean plugin state.

Manual equivalents inside nvim: `:Lazy sync`, `:TSInstallAll`, `:MasonInstallAll`, `:checkhealth`.

---

## What is included

### Language servers (Mason, auto-installed)

| Tool | For |
|---|---|
| yaml-language-server + SchemaStore | YAML with schemas: Kubernetes (built-in), docker-compose, GitHub Actions, GitLab CI, Helm `Chart.yaml`, kustomize, ArgoCD, CloudFormation tags |
| ansible-language-server | `yaml.ansible` (playbooks, roles, group_vars…) with ansible-lint diagnostics |
| terraform-ls + tflint | `.tf`, `.tfvars`, `.hcl` |
| helm-ls | Helm `templates/` |
| dockerfile-language-server, docker-compose-language-service | Dockerfile, compose files |
| bash-language-server (shellcheck + shfmt integrated) | `.sh`, `.bash`, `.env` |
| basedpyright, gopls, lua-language-server | Python, Go, Lua |
| json-lsp + SchemaStore, taplo, marksman | JSON, TOML, Markdown |
| systemd-lsp | systemd units (nginx gets treesitter + `nginx -t`; its LSP needs Python < 3.14) |

### Linters (nvim-lint) and formatters (conform)

* yamllint (relaxed rules: 160 cols, no `---` requirement), ansible-lint, hadolint.
* prettier (yaml/json/markdown), shfmt, terraform fmt, gofmt/goimports, ruff, stylua, taplo.
* Format with `Space f m` / `Space l F`. Format-on-save is **only** enabled for terraform, go and lua
  (`:FormatOnSaveToggle`) so YAML manifests are never rewritten behind your back.

### Plugins added on top of NvChad

| Plugin | Purpose |
|---|---|
| kubectl.nvim | Kubernetes dashboard: pods, logs, exec, describe, context/namespace switch |
| hurl.nvim | HTTP client for `.hurl` files (API / webhook / health checks); same files run in CI via `hurl --test` |
| nvim-ansible | run playbooks / selected tasks from the editor |
| vim-helm, cisco.vim, junos.vim | filetypes/syntax for Helm templates, Cisco IOS/NX-OS/ASA, Junos |
| SchemaStore.nvim | JSON/YAML schemas |
| lazygit.nvim, diffview.nvim, gitsigns | git TUI, diffs, history, hunks |
| trouble.nvim, todo-comments | diagnostics list, TODO/FIXME navigation |
| flash.nvim, nvim-surround, treesitter-textobjects | fast movement and editing |
| grug-far | project-wide search & replace |
| render-markdown | pretty runbooks / READMEs |
| rainbow-delimiters, vim-illuminate, fidget | visual helpers |
| vim-tmux-navigator | `Ctrl h/j/k/l` across tmux panes |
| persistence.nvim | per-directory sessions |
| telescope fzf-native + ui-select | faster fuzzy matching, nicer prompts |

### Built-in networking helpers (`lua/utils/net.lua`)

* `:Cidr 10.20.30.0/22` — subnet calculator (also `Space n c` on the word under cursor).
* `:MaskToggle` — `255.255.255.0` ⇄ `/24`.
* `:Base64Encode` / `:Base64Decode` on a selection — Kubernetes Secrets.
* `:JsonPretty`, `:JsonMinify`, `:YamlToJson`, `:JsonToYaml` (jq / yq).
* `:RunFile`, `:ValidateFile` — run or validate the current file with the correct native tool.
* `Space n p/d/t/w/S/h/P` — ping, dig, traceroute, whois, TLS cert info, HTTP headers, nmap for the host under the cursor.

### Filetype detection

`lua/options.lua` teaches Neovim about: `*.tf/*.tfvars`, `Jenkinsfile`, `Vagrantfile`, `.env*`,
`compose*.yml`, `Chart.yaml`, `values.yaml`, `kustomization.yaml`, Ansible directory layouts,
Helm `templates/`, `.github/workflows`, `.gitlab-ci.yml`, `k8s/`/`manifests/` directories,
systemd units (`.service`, `.timer`, `.network`, …), `/etc/nginx`, `/etc/wireguard`, `sshd_config`,
`~/.ssh/config`, `Caddyfile`, `haproxy.cfg`, `named.conf`, `*.zone`, `*.pem/.crt/.key`,
`*.cfg/*.ios/*.nxos` (Cisco), `*.junos`, `*.hurl`, `*.j2`, `*.gotmpl`, `go.mod`, and more.

---

## Layout

```
init.lua                 NvChad bootstrap (unchanged)
lua/chadrc.lua           theme (catppuccin), statusline, dashboard, Mason extra packages
lua/options.lua          editor options + filetype detection
lua/autocmds.lua         yank highlight, trim whitespace, per-filetype indent, big-file guard…
lua/mappings.lua         ALL custom keymaps (documented in docs/KEYMAPS.md)
lua/plugins/init.lua     overrides for NvChad-bundled plugins (telescope, tree, which-key, …)
lua/plugins/devops.lua   k8s / helm / ansible / http / git / network syntax plugins
lua/plugins/editor.lua   editing QoL plugins
lua/configs/lspconfig.lua  LSP servers and per-server settings
lua/configs/conform.lua    formatters
lua/configs/lint.lua       linters
lua/configs/treesitter.lua parser list
lua/utils/net.lua        CIDR calc, base64, jq/yq, run/validate helpers, user commands
lua/snippets/devops.lua  k8s / compose / terraform / ansible / bash / docker snippets
install.sh               one-shot installer for Arch/Garuda
docs/KEYMAPS.md          keymap reference
```

## Customising

* **Theme:** `Space t h` to preview; set permanently in `lua/chadrc.lua` (`M.base46.theme`).
* **Add an LSP:** add `vim.lsp.config("name", {...})` and the name to `vim.lsp.enable{}` in
  `lua/configs/lspconfig.lua`, then `:MasonInstallAll`.
* **Add a keymap:** `lua/mappings.lua`; add the group label to `lua/plugins/init.lua` (which-key spec).
* **Add a snippet:** `lua/snippets/devops.lua`.
* **New filetype rule:** `vim.filetype.add` in `lua/options.lua`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Boxes instead of icons | terminal font is not a Nerd Font |
| "yaml-language-server not found" | `:MasonInstallAll` (or `Space l M`) |
| No highlighting for a language | `:TSInstall <lang>` or `:TSInstallAll` |
| kubectl dashboard empty | `kubectl` must work in your shell first (`KUBECONFIG`) |
| Something odd after an update | `:Lazy sync` then restart; `:checkhealth` |
