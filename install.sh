#!/usr/bin/env bash
# One-shot installer for the DevOps/Networking NvChad config (Arch / Garuda).
# Usage:  ./install.sh            (asks for sudo password once)
set -Eeuo pipefail

CFG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG_DST="$HOME/.config/nvim"

say()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }

if ! command -v pacman >/dev/null; then
  warn "This installer targets Arch/Garuda (pacman). Install the packages below manually on other distros."
fi

# ---------------------------------------------------------------------------
# 1. System packages (editor, core CLI tools, fonts, devops/network tooling)
# ---------------------------------------------------------------------------
PKGS=(
  neovim git base-devel unzip curl wget
  ripgrep fd fzf tree-sitter-cli luarocks
  lazygit jq yq
  python python-pip nodejs npm go
  # linters / formatters that are nicer from the system than from Mason
  shellcheck shfmt yamllint ansible ansible-lint
  # infra tooling
  terraform tflint kubectl helm docker docker-compose
  # networking tooling used by the <leader>n keymaps
  bind traceroute whois nmap openssl inetutils iproute2 net-tools hurl
  # fonts (icons in the UI)
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols
)

say "Installing system packages (sudo)…"
# filter out packages that don't exist in this repo so one bad name doesn't abort
AVAILABLE=()
for p in "${PKGS[@]}"; do
  if pacman -Si "$p" >/dev/null 2>&1; then AVAILABLE+=("$p"); else warn "skipping unavailable package: $p"; fi
done
sudo pacman -S --needed --noconfirm "${AVAILABLE[@]}"

# hadolint lives in the AUR; try paru/yay, otherwise Mason will install it later
if ! command -v hadolint >/dev/null; then
  if command -v paru >/dev/null; then paru -S --needed --noconfirm hadolint-bin || true
  elif command -v yay  >/dev/null; then yay  -S --needed --noconfirm hadolint-bin || true
  else warn "hadolint not installed system-wide; Mason will provide it inside nvim."; fi
fi

# ---------------------------------------------------------------------------
# 2. Link the config
# ---------------------------------------------------------------------------
if [ -e "$CFG_DST" ] && [ ! -L "$CFG_DST" ]; then
  BAK="$CFG_DST.bak.$(date +%Y%m%d%H%M%S)"
  warn "Existing $CFG_DST moved to $BAK"
  mv "$CFG_DST" "$BAK"
fi
if [ "$(readlink -f "$CFG_DST" || true)" != "$CFG_SRC" ]; then
  ln -sfn "$CFG_SRC" "$CFG_DST"
fi
say "Config linked: $CFG_DST -> $CFG_SRC"

# Fresh plugin state? Only wipe caches if the user asks.
if [ "${FRESH:-0}" = "1" ]; then
  say "FRESH=1: removing old nvim data/cache"
  rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
fi

# ---------------------------------------------------------------------------
# 3. Bootstrap plugins, treesitter parsers and Mason tools headlessly
# ---------------------------------------------------------------------------
say "Bootstrapping plugins (lazy.nvim)…"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -n 3 || true

say "Installing treesitter parsers…"
nvim --headless -c 'lua require("nvim-treesitter").install(require("configs.treesitter").ensure_installed):wait(600000)' +qa 2>&1 | tail -n 3 || true

say "Installing LSP servers / linters / formatters via Mason…"
# MasonInstallAll is async; give it time then exit.
nvim --headless -c 'lua require("lazy").load({ plugins = { "nvim-lspconfig", "conform.nvim", "nvim-lint" } })' \
  -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 600000)' \
  -c 'lua local mr=require("mason-registry"); mr.refresh(function() local n=0; for _,name in ipairs(require("nvchad.mason").get_pkgs()) do local ok,p=pcall(mr.get_package,(name:match("^([^@]+)"))); if ok and not p:is_installed() then n=n+1; p:install():once("closed",function() n=n-1; if n==0 then vim.schedule(function() vim.cmd("qa!") end) end end) end end; if n==0 then vim.cmd("qa!") end end)' 2>&1 | tail -n 5 || true

# ---------------------------------------------------------------------------
# 4. Sanity
# ---------------------------------------------------------------------------
say "Refreshing font cache"
fc-cache -f >/dev/null 2>&1 || true

cat <<MSG

Done.
  * Set your terminal font to "JetBrainsMono Nerd Font" for icons.
  * Start nvim. First launch compiles the theme; if anything is missing run:
      :Lazy sync      :TSInstallAll      :MasonInstallAll     :checkhealth
  * Keymap docs:  <Space>?   inside nvim, or open docs/KEYMAPS.md
MSG
