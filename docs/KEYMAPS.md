# Keymap Reference

`<leader>` is **Space**. Press `Space` and wait a moment: **which-key** pops up and shows every group.
Press `Space ?` at any time to open this file. `Space c h` opens NvChad's built-in cheatsheet.

Legend: `%` = the file in the current buffer. "word under cursor" = `<cWORD>` (the whole
non-blank word, so `10.0.0.0/24` or `api.example.com:443` are picked up as one).

---

## 1. Basics

| Key | Mode | What it does |
|---|---|---|
| `jk` | insert | leave insert mode |
| `;` | normal | enter command mode (`:`) |
| `Ctrl s` | any | save |
| `Esc` | normal | clear search highlight |
| `Space q q` / `Space q a` | normal | quit window / quit all |
| `Space Q` | normal | quit all, discard changes |
| `Alt j` / `Alt k` | n / i / v | move line or selection down / up |
| `<` / `>` | visual | indent and keep selection |
| `Ctrl d` / `Ctrl u` | normal | half-page scroll, cursor stays centred |
| `n` / `N` | normal | next / previous match, centred |
| `p` | visual | paste over selection without losing the register |
| `Ctrl a` / `Ctrl x` | normal | increment / decrement number (versions, ports, last IP octet) |
| `s` + two chars | n / v / o | **flash** jump anywhere on screen |
| `S` | n / v / o | flash treesitter selection (grow by node) |
| `ys{motion}{char}` `ds{char}` `cs{a}{b}` | normal | surround add / delete / change (`ysiw"` wraps word in quotes) |
| `Space /` | n / v | toggle comment |
| `gcc` / `gc{motion}` | normal | comment line / motion |
| `Ctrl c` | normal | copy whole file |

## 2. Windows, buffers, terminal

| Key | What it does |
|---|---|
| `Ctrl h/j/k/l` | move between splits (works across tmux panes too) |
| `Space w v` / `Space w s` | vertical / horizontal split |
| `Space w c` / `Space w o` | close window / close all other windows |
| `Space w =` | equalise split sizes |
| `Ctrl ←↑↓→` | resize the current split |
| `Tab` / `Shift Tab` | next / previous buffer (tab bar) |
| `Shift l` / `Shift h` | next / previous buffer |
| `Space b d` | close buffer |
| `Space b o` | close all other buffers |
| `Space b n` | new empty buffer |
| `Space b b` | pick buffer (telescope) |
| `Ctrl n` | toggle file tree (nvim-tree) |
| `Space e` | focus file tree |
| `Space h` / `Space v` | NvChad terminal: horizontal / vertical |
| `Alt i` / `Alt h` / `Alt v` | toggle floating / horizontal / vertical terminal |
| `Space d s` / `Space d S` | toggle a shell split / floating shell |
| `Esc Esc` (in terminal) | back to normal mode |
| `Ctrl x` (in terminal) | back to normal mode (NvChad default) |

In the file tree: `a` add, `d` delete, `r` rename, `x` cut, `c` copy, `p` paste, `H` toggle dotfiles, `?` help.

## 3. Find / search (Telescope)

| Key | What it does |
|---|---|
| `Space f f` | find files |
| `Space f a` | find ALL files (hidden + gitignored) |
| `Space f g` | git-tracked files |
| `Space f w` | live grep (in visual mode: grep the selection) |
| `Space f *` | grep the word under cursor |
| `Space f z` | fuzzy search in current buffer |
| `Space f b` | buffers |
| `Space f o` | recent files |
| `Space f r` | resume last picker |
| `Space f s` / `Space f S` | symbols in buffer / workspace |
| `Space f d` | diagnostics |
| `Space f k` | search keymaps |
| `Space f c` | search commands |
| `Space f h` | help tags |
| `Space f t` | TODO / FIXME comments |
| `Space f e` | **browse /etc** configs |
| `Space f n` | open a file of this nvim config |
| `Space s r` | project search & replace (grug-far) |
| `Space s w` | search & replace word under cursor |
| `Space s f` | search & replace in the current file |

Inside telescope: `Ctrl j/k` move, `Ctrl v` open in vsplit, `Ctrl x` split, `Ctrl t` tab, `Ctrl q` send to quickfix.

## 4. Git

| Key | What it does |
|---|---|
| `Space g g` | **lazygit** (full TUI in a float) |
| `Space g f` | lazygit filtered to current file's history |
| `Space g d` | diffview: working tree vs HEAD |
| `Space g D` | diffview: branch vs origin |
| `Space g h` / `Space g H` | file history: current file / whole repo |
| `Space g q` | close diffview |
| `Space g s` / `g c` / `g b` | telescope git status / commits / branches |
| `Space g p` | preview hunk under cursor |
| `Space g a` / `Space g u` | stage hunk / undo stage |
| `Space g r` | reset hunk |
| `Space g B` | blame current line (full) |
| `Space g t` | toggle inline blame |
| `]h` / `[h` | next / previous hunk |

## 5. LSP, diagnostics, formatting, linting

| Key | What it does |
|---|---|
| `K` | hover documentation |
| `gd` / `gD` | go to definition / declaration |
| `gr` | references (telescope) |
| `gI` | implementations |
| `Space D` | type definition |
| `Space r a` | rename (NvChad renamer UI) |
| `Space l r` | rename (plain LSP) |
| `Space l a` | code action (n / v) |
| `Space l f` | show diagnostics for the current line in a float |
| `Space l s` | signature help |
| `]d` / `[d` | next / previous diagnostic |
| `]e` / `[e` | next / previous **error** |
| `Space x x` | trouble: all diagnostics |
| `Space x b` | trouble: current buffer diagnostics |
| `Space x s` | trouble: symbols outline |
| `Space x r` | trouble: references |
| `Space x t` | trouble: TODO list |
| `Space f m` | format buffer (NvChad) |
| `Space l F` | format buffer / selection (conform) |
| `Space l t` | toggle format-on-save (default: only terraform, go, lua) |
| `Space l l` | run linters now |
| `Space l L` | toggle linting |
| `Space l i` / `Space l R` | LSP info / restart |
| `Space l m` | open Mason |
| `Space l M` | `:MasonInstallAll` install every tool this config references |

Completion menu: `Tab` / `Shift Tab` move, `Enter` accept, `Ctrl Space` trigger. Snippets: type a prefix (see §10) then `Tab`.

## 6. DevOps: run / validate / helpers

| Key | What it does |
|---|---|
| `Space d r` | **run** the current file with the right tool (bash, python, `go run`, `ansible-playbook`, `kubectl apply --dry-run`, `docker compose config`, `docker build`, `terraform plan`, `make`) |
| `Space d v` | **validate** the current file with its native validator (yamllint, ansible-lint, hadolint, `terraform validate`, `helm lint`, shellcheck, `nginx -t`, `sshd -t`, `systemd-analyze verify`, `jq empty`, `kubectl --dry-run=server`) |
| `Space d u` | insert a UUID |
| `Space d t` | insert an ISO-8601 timestamp |
| `Space d x` | `chmod +x` the current file |
| `Space d l` | plugin manager (Lazy) |
| `Space d h` | `:checkhealth` |
| `Space c p` / `Space c P` | copy relative / absolute path of file |
| `Space c l` | copy `path:line` |
| `Space c n` | copy file name |

## 7. Kubernetes (`Space k`)

| Key | What it does |
|---|---|
| `Space k k` | **kubectl.nvim** dashboard (pods, deployments, logs, exec, describe...) |
| `Space k x` / `Space k n` | switch context / namespace |
| `Space k a` | `kubectl apply -f %` |
| `Space k d` | `kubectl diff -f %` |
| `Space k D` | `kubectl delete -f %` |
| `Space k p` | `kubectl get pods -A` |
| `Space k c` | list contexts |
| `Space k e` | recent cluster events |
| `Space k h` | `helm template` the chart in the current dir |

Inside the kubectl dashboard: `g?` shows its help; `Enter` drill in, `gd` describe, `gl` logs, `ge` exec, `gk` kill/delete, `<C-f>` filter, `<BS>` go back.

## 8. Terraform (`Space t`)

| Key | What it does |
|---|---|
| `Space t i` | `terraform init` (in the file's dir) |
| `Space t p` | `terraform plan` |
| `Space t a` | `terraform apply` |
| `Space t v` | `terraform validate` |
| `Space t f` | `terraform fmt -recursive` |
| `Space t s` | `terraform state list` |
| `Space t o` | `terraform output` |
| `Space t h` | theme picker (NvChad) |

## 9. Ansible (`Space a`)

| Key | What it does |
|---|---|
| `Space a r` | run playbook / role (nvim-ansible). In visual mode, run only the selected tasks |
| `Space a c` | `ansible-playbook --syntax-check %` |
| `Space a d` | dry run: `--check --diff` |
| `Space a l` | `ansible-lint %` |
| `Space a i` | `ansible-inventory --graph` |
| `Space a v` / `Space a V` | `ansible-vault decrypt` / `encrypt` the current file |

Files in `playbooks/`, `roles/*/tasks`, `group_vars/`, `host_vars/` and `*playbook*.yml` are detected as `yaml.ansible` and get the Ansible language server automatically.

## 10. Networking (`Space n`)

All "host" commands use the word under the cursor, so put the cursor on an IP, hostname or URL inside any config and hit the key.

| Key | What it does |
|---|---|
| `Space n c` | **CIDR calculator** for the word under cursor: netmask, wildcard, network, broadcast, host range, usable count, class, RFC1918 (`y` copies, `q` closes). Accepts `10.0.0.0/24`, `10.0.0.5 255.255.255.0` |
| `Space n C` | CIDR calculator, type an address |
| `Space n m` | convert netmask ⇄ prefix (`255.255.255.0` → `/24`) and copy to clipboard |
| `Space n p` | ping host |
| `Space n d` | dig A + AAAA |
| `Space n D` | reverse DNS for IP |
| `Space n n` | nslookup |
| `Space n t` | traceroute |
| `Space n w` | whois |
| `Space n S` | show TLS certificate subject / issuer / dates for host |
| `Space n h` | `curl -sI` response headers for URL |
| `Space n P` | nmap top-100 ports |
| `Space n s` | local listening sockets (`ss -tulpn`) |
| `Space n i` | local `ip addr` + routes |

Commands: `:Cidr 192.168.1.0/22`, `:MaskToggle`.

## 11. JSON / YAML / base64 (`Space j`)

| Key | What it does |
|---|---|
| `Space j p` | pretty-print JSON with jq (buffer or visual selection) |
| `Space j m` | minify JSON |
| `Space j q` | run an arbitrary jq filter on the buffer |
| `Space j j` | YAML → JSON (yq) |
| `Space j y` | JSON → YAML (yq) |
| `Space j v` | normalise / validate YAML through yq |
| `Space j k` | query a yq path in the current YAML file (`.spec.template.spec.containers[0].image`) |
| `Space j e` (visual) | base64-**encode** selection (k8s Secrets) |
| `Space j d` (visual) | base64-**decode** selection |

## 12. HTTP requests (`.hurl` files, `Space r`)

Uses [Hurl](https://hurl.dev), the same files run in CI with `hurl --test`. Create `api.hurl`:

```hurl
# health check
GET https://example.com/healthz
Accept: application/json
HTTP 200

# create an item
POST https://api.example.com/items
Content-Type: application/json
{"name": "x"}
HTTP 201
[Asserts]
jsonpath "$.id" exists
```

| Key | What it does |
|---|---|
| `Space r r` | run the request under cursor (visual mode: run the selected requests) |
| `Space r a` | run all requests in the file |
| `Space r e` / `Space r E` | run from start to this entry / from this entry to end |
| `Space r v` | run verbose (headers, timings) |
| `Space r t` | toggle split / popup result view |
| `Space r s` / `Space r m` | set / manage variables (also `vars.env` next to the file) |
| `Space r l` | show last response |
| `Space d r` | `hurl --test %` (assertions as a test run) |

In the response window: `q` close, `Ctrl n` / `Ctrl p` switch panels.

## 13. UI toggles (`Space u`)

| Key | What it does |
|---|---|
| `Space u n` / `Space u r` | line numbers / relative numbers |
| `Space u w` | wrap |
| `Space u s` | spell check |
| `Space u l` | show whitespace characters |
| `Space u c` | cursor line |
| `Space u i` | indent guides |
| `Space u t` | theme picker |
| `Space u T` | transparency |
| `Space u m` | markdown rendering |
| `Space u z` | zen: hide statusline / tab bar / numbers |
| `Space t h` | NvChad theme picker (default) |

## 14. Folds

| Key | What it does |
|---|---|
| `za` | toggle fold under cursor |
| `zR` / `zM` | open all / close all |
| `z1` / `z2` | fold to level 1 / 2 (collapse a YAML doc to top-level keys) |
| `zj` / `zk` | next / previous fold |

## 15. Sessions

| Key | What it does |
|---|---|
| `Space q s` | restore the session for the current directory |
| `Space q l` | restore the last session |
| `Space q d` | do not save the session on exit |

## 16. Snippets (type prefix, press `Tab`)

| Prefix | File type | Expands to |
|---|---|---|
| `k8sdeploy` `k8ssvc` `k8sing` `k8scm` `k8ssecret` | yaml | Deployment / Service / Ingress / ConfigMap / Secret |
| `compose` | yaml | docker-compose service block |
| `ghjob` | yaml | GitHub Actions workflow |
| `aplay` `atask` | yaml | Ansible playbook / task |
| `tfres` `tfvar` `tfout` `tfmod` `tfbackend` | terraform | resource / variable / output / module / S3 backend |
| `#!` `log` `trap` | sh | strict bash header / log function / cleanup trap |
| `dockermulti` | dockerfile | multi-stage build |

Plus hundreds from friendly-snippets (bash, python, go, yaml, docker, terraform...).

## 17. Text objects (visual / operator pending)

`af` / `if` function, `ab` / `ib` block, `aa` / `ia` argument. E.g. `daa` deletes an argument, `vif` selects a function body.

## 18. Changed NvChad defaults

| NvChad default | Here | Why |
|---|---|---|
| `Space x` close buffer | `Space b d` | `Space x` is now the diagnostics (trouble) group |
| `Space b` new buffer | `Space b n` | `Space b` is now the buffers group |
| `Space n` toggle numbers | `Space u n` | `Space n` is the network group |
| `Space r n` relative numbers | `Space u r` | `Space r` is the run/requests group |
| `Space d s` diagnostic loclist | `Space x x` (trouble) | `Space d s` toggles a shell |
| `Space g t` git status | `Space g s` | `Space g t` toggles inline blame |
