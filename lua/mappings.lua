-- Keymaps. NvChad defaults are loaded first (see docs/KEYMAPS.md for the full list).
require "nvchad.mappings"

local map = vim.keymap.set
local net = require "utils.net"
net.setup()

-- Unmap NvChad defaults we re-purpose (so which-key groups stay clean)
pcall(vim.keymap.del, "n", "<leader>b") -- was "buffer new"; <leader>b is now the buffer group
pcall(vim.keymap.del, "n", "<leader>n") -- was "toggle line number"; moved to <leader>un
pcall(vim.keymap.del, "n", "<leader>rn") -- was "toggle relative number"; moved to <leader>ur
pcall(vim.keymap.del, "n", "<leader>x") -- was "close buffer"; now <leader>bd (x = trouble group)

---------------------------------------------------------------------------
-- Basics
---------------------------------------------------------------------------
map("n", ";", ":", { desc = "enter command mode" })
map("i", "jk", "<ESC>", { desc = "exit insert mode" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "save file" })
map("n", "<leader>qq", "<cmd>q<CR>", { desc = "quit window" })
map("n", "<leader>qa", "<cmd>qa<CR>", { desc = "quit all" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "quit all (discard changes)" })
map("n", "<leader>?", "<cmd>Keymaps<CR>", { desc = "keymap help (docs/KEYMAPS.md)" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "clear search highlight" })

-- Move lines up/down (Alt+j/k) in normal, insert and visual mode
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "move line up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "move selection up" })

-- Keep selection when indenting; keep cursor centred when jumping
map("v", "<", "<gv", { desc = "indent left" })
map("v", ">", ">gv", { desc = "indent right" })
map("n", "<C-d>", "<C-d>zz", { desc = "half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "half page up" })
map("n", "n", "nzzzv", { desc = "next match" })
map("n", "N", "Nzzzv", { desc = "prev match" })
map("n", "J", "mzJ`z", { desc = "join lines (keep cursor)" })

-- Paste over selection without clobbering the register
map("x", "p", '"_dP', { desc = "paste (keep register)" })
-- <C-a> / <C-x> stay as increment / decrement (handy for versions, ports, IPs)

---------------------------------------------------------------------------
-- Windows / splits / tmux
---------------------------------------------------------------------------
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "window left (tmux aware)" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "window down (tmux aware)" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "window up (tmux aware)" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "window right (tmux aware)" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "split vertical" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "split horizontal" })
map("n", "<leader>wc", "<cmd>close<CR>", { desc = "close window" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "equalize windows" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "grow window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "shrink window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "narrow window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "widen window" })

---------------------------------------------------------------------------
-- Buffers
---------------------------------------------------------------------------
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "new buffer" })
map("n", "<leader>bd", function() require("nvchad.tabufline").close_buffer() end, { desc = "close buffer" })
map("n", "<leader>bo", function() require("nvchad.tabufline").closeAllBufs(false) end, { desc = "close other buffers" })
map("n", "<leader>bb", "<cmd>Telescope buffers<CR>", { desc = "list buffers" })
map("n", "<S-l>", function() require("nvchad.tabufline").next() end, { desc = "next buffer" })
map("n", "<S-h>", function() require("nvchad.tabufline").prev() end, { desc = "prev buffer" })

---------------------------------------------------------------------------
-- Find (Telescope) — extends NvChad's <leader>ff / fw / fb / fo / fz / fh
---------------------------------------------------------------------------
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "find ALL files (incl. ignored)" })
map("n", "<leader>fg", "<cmd>Telescope git_files<CR>", { desc = "find git files" })
map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "resume last picker" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "find symbols (buffer)" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "find symbols (workspace)" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "find diagnostics" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "find keymaps" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "find commands" })
map("n", "<leader>f/", "<cmd>Telescope search_history<CR>", { desc = "search history" })
map("n", "<leader>fe", function()
  require("telescope.builtin").find_files { cwd = "/etc", hidden = true, prompt_title = "/etc configs" }
end, { desc = "find in /etc" })
map("n", "<leader>fn", function()
  require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config", prompt_title = "nvim config" }
end, { desc = "find nvim config file" })
map("v", "<leader>fw", function()
  vim.cmd 'noau normal! "vy'
  require("telescope.builtin").live_grep { default_text = vim.fn.getreg "v" }
end, { desc = "grep selection" })
map("n", "<leader>f*", function()
  require("telescope.builtin").grep_string { word_match = "-w" }
end, { desc = "grep word under cursor" })

---------------------------------------------------------------------------
-- Git
---------------------------------------------------------------------------
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "lazygit" })
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", { desc = "lazygit (current file history)" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "diff: working tree" })
map("n", "<leader>gD", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", { desc = "diff: branch vs origin" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "history: current file" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "history: repo" })
map("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "close diffview" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "git status (telescope)" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "git commits" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "git branches" })
map("n", "<leader>gB", function() require("gitsigns").blame_line { full = true } end, { desc = "blame line" })
map("n", "<leader>gt", function() require("gitsigns").toggle_current_line_blame() end, { desc = "toggle inline blame" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "preview hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "reset hunk" })
map("n", "<leader>ga", function() require("gitsigns").stage_hunk() end, { desc = "stage hunk" })
map("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "undo stage hunk" })
map("n", "]h", function() require("gitsigns").nav_hunk "next" end, { desc = "next git hunk" })
map("n", "[h", function() require("gitsigns").nav_hunk "prev" end, { desc = "prev git hunk" })

---------------------------------------------------------------------------
-- LSP (in addition to NvChad's gd / gD / <leader>ra / <leader>D / <leader>ds)
---------------------------------------------------------------------------
map("n", "K", vim.lsp.buf.hover, { desc = "lsp: hover docs" })
map("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "lsp: references" })
map("n", "gI", "<cmd>Telescope lsp_implementations<CR>", { desc = "lsp: implementations" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "lsp: code action" })
map("v", "<leader>la", vim.lsp.buf.code_action, { desc = "lsp: code action (range)" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "lsp: rename symbol" })
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "lsp: line diagnostics" })
map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "lsp: signature help" })
map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "lsp: info" })
map("n", "<leader>lR", "<cmd>LspRestart<CR>", { desc = "lsp: restart" })
map("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "mason: open" })
map("n", "<leader>lM", "<cmd>MasonInstallAll<CR>", { desc = "mason: install all tools" })
map("n", "]d", function() vim.diagnostic.jump { count = 1, float = true } end, { desc = "next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump { count = -1, float = true } end, { desc = "prev diagnostic" })
map("n", "]e", function() vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR, float = true } end, { desc = "next error" })
map("n", "[e", function() vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR, float = true } end, { desc = "prev error" })
map({ "n", "v" }, "<leader>lF", function() require("conform").format { lsp_format = "fallback" } end, { desc = "format (conform)" })
map("n", "<leader>lt", "<cmd>FormatOnSaveToggle<CR>", { desc = "toggle format-on-save" })
map("n", "<leader>ll", "<cmd>Lint<CR>", { desc = "lint now" })
map("n", "<leader>lL", "<cmd>LintToggle<CR>", { desc = "toggle linting" })

---------------------------------------------------------------------------
-- DevOps: run / validate / helpers
---------------------------------------------------------------------------
map("n", "<leader>dr", "<cmd>RunFile<CR>", { desc = "run / apply current file" })
map("n", "<leader>dv", "<cmd>ValidateFile<CR>", { desc = "validate current file (native tool)" })
map("n", "<leader>du", "<cmd>Uuid<CR>", { desc = "insert UUID" })
map("n", "<leader>dt", "<cmd>Timestamp<CR>", { desc = "insert ISO timestamp" })
map("n", "<leader>dx", "<cmd>!chmod +x %<CR>", { desc = "chmod +x current file" })
map("n", "<leader>dl", "<cmd>Lazy<CR>", { desc = "plugin manager (lazy)" })
map("n", "<leader>dh", "<cmd>checkhealth<CR>", { desc = "checkhealth" })
map("n", "<leader>ds", function()
  require("nvchad.term").toggle { pos = "sp", id = "shell", size = 0.35 }
end, { desc = "toggle shell (horizontal)" })
map("n", "<leader>dS", function()
  require("nvchad.term").toggle { pos = "float", id = "floatshell" }
end, { desc = "toggle shell (float)" })

-- copy paths
map("n", "<leader>cp", function() net.copy_path "rel" end, { desc = "copy relative path" })
map("n", "<leader>cP", function() net.copy_path "abs" end, { desc = "copy absolute path" })
map("n", "<leader>cl", function() net.copy_path "line" end, { desc = "copy path:line" })
map("n", "<leader>cn", function() net.copy_path "name" end, { desc = "copy filename" })

---------------------------------------------------------------------------
-- Kubernetes (kubectl.nvim adds <leader>kk / kx / kn)
---------------------------------------------------------------------------
local function term_run(cmd)
  require("nvchad.term").runner { pos = "sp", id = "k8s", cmd = cmd, clear_cmd = true }
end
map("n", "<leader>ka", function() term_run("kubectl apply -f " .. vim.fn.expand "%:p") end, { desc = "kubectl apply -f %" })
map("n", "<leader>kd", function() term_run("kubectl diff -f " .. vim.fn.expand "%:p") end, { desc = "kubectl diff -f %" })
map("n", "<leader>kD", function() term_run("kubectl delete -f " .. vim.fn.expand "%:p") end, { desc = "kubectl delete -f %" })
map("n", "<leader>kp", function() term_run "kubectl get pods -A" end, { desc = "kubectl get pods -A" })
map("n", "<leader>kc", function() term_run "kubectl config get-contexts" end, { desc = "kubectl contexts" })
map("n", "<leader>ke", function() term_run "kubectl get events --sort-by=.lastTimestamp -A | tail -40" end, { desc = "kubectl recent events" })
map("n", "<leader>kh", function()
  local d = vim.fn.expand "%:p:h"
  term_run("helm template " .. d .. " 2>&1 | head -200")
end, { desc = "helm template (chart dir)" })

---------------------------------------------------------------------------
-- Terraform
---------------------------------------------------------------------------
local function tf(cmdline)
  return function()
    local d = vim.fn.expand "%:p:h"
    require("nvchad.term").runner { pos = "sp", id = "tf", cmd = "cd " .. d .. " && " .. cmdline, clear_cmd = true }
  end
end
map("n", "<leader>ti", tf "terraform init", { desc = "terraform init" })
map("n", "<leader>tp", tf "terraform plan", { desc = "terraform plan" })
map("n", "<leader>ta", tf "terraform apply", { desc = "terraform apply" })
map("n", "<leader>tv", tf "terraform validate", { desc = "terraform validate" })
map("n", "<leader>tf", tf "terraform fmt -recursive", { desc = "terraform fmt" })
map("n", "<leader>ts", tf "terraform state list", { desc = "terraform state list" })
map("n", "<leader>to", tf "terraform output", { desc = "terraform output" })

---------------------------------------------------------------------------
-- Ansible (nvim-ansible adds <leader>ar)
---------------------------------------------------------------------------
map("n", "<leader>ac", function() term_run("ansible-playbook --syntax-check " .. vim.fn.expand "%:p") end, { desc = "ansible syntax-check" })
map("n", "<leader>al", function() term_run("ansible-lint " .. vim.fn.expand "%:p") end, { desc = "ansible-lint" })
map("n", "<leader>ad", function() term_run("ansible-playbook --check --diff " .. vim.fn.expand "%:p") end, { desc = "ansible dry-run (--check --diff)" })
map("n", "<leader>ai", function() term_run "ansible-inventory --graph" end, { desc = "ansible inventory graph" })
map("n", "<leader>av", "<cmd>!ansible-vault decrypt %<CR>", { desc = "ansible-vault decrypt file" })
map("n", "<leader>aV", "<cmd>!ansible-vault encrypt %<CR>", { desc = "ansible-vault encrypt file" })

---------------------------------------------------------------------------
-- Networking helpers
---------------------------------------------------------------------------
map("n", "<leader>nc", "<cmd>Cidr<CR>", { desc = "CIDR calc (word under cursor)" })
map("n", "<leader>nC", ":Cidr ", { desc = "CIDR calc (type address)" })
map("n", "<leader>nm", "<cmd>MaskToggle<CR>", { desc = "netmask <-> prefix" })
map("n", "<leader>np", function() term_run("ping -c 4 " .. vim.fn.expand "<cWORD>") end, { desc = "ping host under cursor" })
map("n", "<leader>nd", function() term_run("dig +short " .. vim.fn.expand "<cWORD>" .. " A; dig +short " .. vim.fn.expand "<cWORD>" .. " AAAA") end, { desc = "dig host under cursor" })
map("n", "<leader>nD", function() term_run("dig -x " .. vim.fn.expand "<cWORD>" .. " +short") end, { desc = "reverse dns for ip" })
map("n", "<leader>nt", function() term_run("traceroute -n " .. vim.fn.expand "<cWORD>") end, { desc = "traceroute host under cursor" })
map("n", "<leader>nw", function() term_run("whois " .. vim.fn.expand "<cWORD>" .. " | head -60") end, { desc = "whois host under cursor" })
map("n", "<leader>ns", function() term_run("ss -tulpn") end, { desc = "listening sockets (ss -tulpn)" })
map("n", "<leader>ni", function() term_run("ip -br -c addr; echo; ip -c route") end, { desc = "ip addr + routes" })
map("n", "<leader>nS", function()
  local host = vim.fn.expand "<cWORD>"
  term_run("echo | openssl s_client -connect " .. host .. ":443 -servername " .. host .. " 2>/dev/null | openssl x509 -noout -subject -issuer -dates")
end, { desc = "TLS cert info for host under cursor" })
map("n", "<leader>nh", function() term_run("curl -sI " .. vim.fn.expand "<cWORD>") end, { desc = "curl headers for url under cursor" })
map("n", "<leader>nP", function()
  local host = vim.fn.expand "<cWORD>"
  term_run("nmap -Pn --top-ports 100 " .. host)
end, { desc = "nmap top-100 ports (host under cursor)" })
map("n", "<leader>nn", function() term_run("nslookup " .. vim.fn.expand "<cWORD>") end, { desc = "nslookup" })

---------------------------------------------------------------------------
-- JSON / YAML / base64 transforms
---------------------------------------------------------------------------
map("n", "<leader>jp", "<cmd>JsonPretty<CR>", { desc = "json: pretty (jq)" })
map("v", "<leader>jp", ":JsonPretty<CR>", { desc = "json: pretty selection" })
map("n", "<leader>jm", "<cmd>JsonMinify<CR>", { desc = "json: minify" })
map("v", "<leader>jm", ":JsonMinify<CR>", { desc = "json: minify selection" })
map("n", "<leader>jy", "<cmd>JsonToYaml<CR>", { desc = "json -> yaml (yq)" })
map("n", "<leader>jj", "<cmd>YamlToJson<CR>", { desc = "yaml -> json (yq)" })
map("v", "<leader>je", ":Base64Encode<CR>", { desc = "base64 encode selection" })
map("v", "<leader>jd", ":Base64Decode<CR>", { desc = "base64 decode selection" })
map("n", "<leader>jq", function()
  local filter = vim.fn.input "jq filter: "
  if filter ~= "" then
    vim.cmd("%!jq '" .. filter .. "'")
  end
end, { desc = "json: run jq filter on buffer" })
map("n", "<leader>jv", "<cmd>%!yq .<CR>", { desc = "yaml: normalise / validate (yq)" })
map("n", "<leader>jk", function()
  local q = vim.fn.input "yq path (e.g. .spec.containers[0].image): "
  if q ~= "" then
    term_run("yq '" .. q .. "' " .. vim.fn.expand "%:p")
  end
end, { desc = "yaml: query path with yq" })

---------------------------------------------------------------------------
-- UI toggles
---------------------------------------------------------------------------
map("n", "<leader>un", "<cmd>set nu!<CR>", { desc = "toggle line numbers" })
map("n", "<leader>ur", "<cmd>set rnu!<CR>", { desc = "toggle relative numbers" })
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "toggle wrap" })
map("n", "<leader>us", "<cmd>set spell!<CR>", { desc = "toggle spell" })
map("n", "<leader>ul", "<cmd>set list!<CR>", { desc = "toggle whitespace chars" })
map("n", "<leader>uc", "<cmd>set cursorline!<CR>", { desc = "toggle cursorline" })
map("n", "<leader>ui", "<cmd>IBLToggle<CR>", { desc = "toggle indent guides" })
map("n", "<leader>ut", function() require("nvchad.themes").open() end, { desc = "theme picker" })
map("n", "<leader>uT", function() require("base46").toggle_transparency() end, { desc = "toggle transparency" })
map("n", "<leader>um", "<cmd>RenderMarkdown toggle<CR>", { desc = "toggle markdown render" })
map("n", "<leader>uz", function()
  vim.o.laststatus = vim.o.laststatus == 0 and 3 or 0
  vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
  vim.o.number = vim.o.laststatus ~= 0
  vim.o.relativenumber = vim.o.laststatus ~= 0
end, { desc = "zen: hide ui chrome" })

---------------------------------------------------------------------------
-- Folds
---------------------------------------------------------------------------
map("n", "zR", function() vim.o.foldlevel = 99 end, { desc = "open all folds" })
map("n", "zM", function() vim.o.foldlevel = 0 end, { desc = "close all folds" })
map("n", "z1", function() vim.o.foldlevel = 1 end, { desc = "fold to level 1 (yaml top keys)" })
map("n", "z2", function() vim.o.foldlevel = 2 end, { desc = "fold to level 2" })

---------------------------------------------------------------------------
-- Terminal
---------------------------------------------------------------------------
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "terminal: normal mode" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "terminal: window left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "terminal: window down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "terminal: window up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "terminal: window right" })
