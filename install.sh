#!/usr/bin/env bash
# One-shot installer for the DevOps/Networking NvChad config.
# Supports: Arch / Garuda / Manjaro (pacman)  and  Ubuntu / Debian / Mint / Pop (apt).
# Usage:   ./install.sh              (asks for sudo password once)
#          FRESH=1 ./install.sh      (also wipes ~/.local/share/nvim for a clean plugin state)
set -Eeuo pipefail

CFG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG_DST="$HOME/.config/nvim"
NVIM_MIN="0.11"

say()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# CPU arch for GitHub release downloads
case "$(uname -m)" in
  x86_64)  ARCH=x86_64;  ARCH_DEB=amd64 ;;
  aarch64) ARCH=arm64;   ARCH_DEB=arm64 ;;
  *) warn "unsupported arch $(uname -m); binary downloads may fail"; ARCH=x86_64; ARCH_DEB=amd64 ;;
esac

# Distro detection
. /etc/os-release 2>/dev/null || true
DISTRO="${ID:-unknown}"
case "$DISTRO ${ID_LIKE:-}" in
  *arch*|*garuda*|*manjaro*|*endeavouros*) FAMILY=arch ;;
  *ubuntu*|*debian*|*linuxmint*|*pop*)     FAMILY=debian ;;
  *) FAMILY=unknown ;;
esac
say "Detected: ${PRETTY_NAME:-$DISTRO} (family: $FAMILY, arch: $ARCH)"

# Helper: fetch latest GitHub release asset matching a pattern into a temp file
gh_latest_asset() { # repo pattern -> prints download url
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 | grep -iE "$2" | head -n1
}

ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

# ===========================================================================
# 1. System packages
# ===========================================================================
install_arch() {
  local PKGS=(
    neovim git base-devel unzip curl wget
    ripgrep fd fzf tree-sitter-cli luarocks
    lazygit jq yq
    python python-pip nodejs npm go
    shellcheck shfmt yamllint ansible ansible-lint
    terraform tflint kubectl helm docker docker-compose
    bind traceroute whois nmap openssl inetutils iproute2 net-tools hurl
    ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols
  )
  say "Installing packages with pacman (sudo)…"
  local AVAILABLE=()
  for p in "${PKGS[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then AVAILABLE+=("$p"); else warn "skipping unavailable package: $p"; fi
  done
  sudo pacman -S --needed --noconfirm "${AVAILABLE[@]}"

  if ! have hadolint; then
    if   have paru; then paru -S --needed --noconfirm hadolint-bin || true
    elif have yay;  then yay  -S --needed --noconfirm hadolint-bin || true
    else warn "hadolint not installed system-wide; Mason provides it inside nvim."; fi
  fi
}

install_debian() {
  say "Installing packages with apt (sudo)…"
  sudo apt-get update -qq
  local PKGS=(
    git build-essential unzip curl wget ca-certificates gnupg fontconfig
    ripgrep fd-find fzf luarocks
    jq
    python3 python3-pip python3-venv nodejs npm golang-go
    shellcheck shfmt yamllint ansible ansible-lint
    docker.io docker-compose-v2
    dnsutils traceroute whois nmap openssl iputils-ping iproute2 net-tools
  )
  local AVAILABLE=()
  for p in "${PKGS[@]}"; do
    if apt-cache show "$p" >/dev/null 2>&1; then AVAILABLE+=("$p"); else warn "skipping unavailable package: $p"; fi
  done
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${AVAILABLE[@]}"

  # Debian names fd "fdfind"; telescope/fzf expect "fd"
  if ! have fd && have fdfind; then
    mkdir -p "$HOME/.local/bin" && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  # --- Neovim: apt ships too old a version for NvChad v2.5 (needs >= 0.11) ---
  local need_nvim=1
  if have nvim; then
    local v; v="$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)"
    ver_ge "$v" "$NVIM_MIN" && need_nvim=0
  fi
  if [ "$need_nvim" = 1 ]; then
    say "Installing latest Neovim from GitHub releases into /opt/nvim…"
    local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH}.tar.gz"
    curl -fsSL "$url" -o /tmp/nvim.tar.gz
    sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
    sudo tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim.tar.gz
  fi

  # --- lazygit (not in most Ubuntu releases) ---
  if ! have lazygit; then
    say "Installing lazygit…"
    local url; url="$(gh_latest_asset jesseduffield/lazygit "lazygit_.*_linux_${ARCH}\.tar\.gz")"
    [ -n "$url" ] && curl -fsSL "$url" | sudo tar -xz -C /usr/local/bin lazygit || warn "lazygit download failed"
  fi

  # --- hurl (.deb from GitHub) ---
  if ! have hurl; then
    say "Installing hurl…"
    local url; url="$(gh_latest_asset Orange-OpenSource/hurl "hurl_.*_${ARCH_DEB}\.deb$")"
    if [ -n "$url" ]; then curl -fsSL "$url" -o /tmp/hurl.deb && sudo apt-get install -y -qq /tmp/hurl.deb && rm -f /tmp/hurl.deb
    else warn "hurl download failed"; fi
  fi

  # --- hadolint (static binary) ---
  if ! have hadolint; then
    say "Installing hadolint…"
    local url; url="$(gh_latest_asset hadolint/hadolint "hadolint-Linux-${ARCH}$")"
    [ -n "$url" ] && sudo curl -fsSL "$url" -o /usr/local/bin/hadolint && sudo chmod +x /usr/local/bin/hadolint || warn "hadolint download failed (Mason provides it inside nvim)"
  fi

  # --- terraform (HashiCorp apt repo, official instructions) ---
  if ! have terraform; then
    say "Installing terraform from HashiCorp apt repo…"
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/hashicorp.gpg
    echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${VERSION_CODENAME:-jammy} main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq terraform || warn "terraform install failed"
  fi

  # --- kubectl (official Kubernetes apt repo) ---
  if ! have kubectl; then
    say "Installing kubectl from the Kubernetes apt repo…"
    local kver; kver="$(curl -fsSL https://dl.k8s.io/release/stable.txt | grep -oE 'v[0-9]+\.[0-9]+')"
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/${kver}/deb/Release.key" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/${kver}/deb/ /" \
      | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq kubectl || warn "kubectl install failed"
  fi

  # --- helm (official installer script) ---
  if ! have helm; then
    say "Installing helm…"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || warn "helm install failed"
  fi

  # --- Nerd Font (not packaged in apt) ---
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    say "Installing JetBrainsMono Nerd Font to ~/.local/share/fonts…"
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
      | tar -xJ -C "$HOME/.local/share/fonts/JetBrainsMonoNerd" || warn "font download failed"
  fi

  # yq, tflint, tree-sitter-cli, terraform-ls, etc. come from Mason inside nvim (see chadrc M.mason.pkgs)
  # Docker: let the current user run docker without sudo (takes effect after re-login)
  if getent group docker >/dev/null && ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER" && warn "added $USER to the docker group; log out and back in for it to apply"
  fi
}

case "$FAMILY" in
  arch)   install_arch ;;
  debian) install_debian ;;
  *)      warn "Unknown distro. Install manually: neovim>=$NVIM_MIN git gcc make unzip curl ripgrep fd fzf jq node npm python3 go lazygit; then re-run." ;;
esac

# make sure freshly installed binaries are visible for the rest of this script
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

if ! have nvim; then
  warn "nvim not found on PATH; aborting before bootstrap."; exit 1
fi
say "Using $(nvim --version | head -n1)"

# ===========================================================================
# 2. Link the config
# ===========================================================================
if [ -e "$CFG_DST" ] && [ ! -L "$CFG_DST" ]; then
  BAK="$CFG_DST.bak.$(date +%Y%m%d%H%M%S)"
  warn "Existing $CFG_DST moved to $BAK"
  mv "$CFG_DST" "$BAK"
fi
if [ "$(readlink -f "$CFG_DST" 2>/dev/null || true)" != "$CFG_SRC" ]; then
  mkdir -p "$(dirname "$CFG_DST")"
  ln -sfn "$CFG_SRC" "$CFG_DST"
fi
say "Config linked: $CFG_DST -> $CFG_SRC"

if [ "${FRESH:-0}" = "1" ]; then
  say "FRESH=1: removing old nvim data/cache"
  rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
fi

# ===========================================================================
# 3. Bootstrap plugins, Mason tools, treesitter parsers (headless)
#    Order matters: Mason first so tree-sitter-cli exists before parsers build.
# ===========================================================================
say "Bootstrapping plugins (lazy.nvim)…"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -n 3 || true

say "Installing LSP servers / linters / formatters via Mason (this takes a few minutes)…"
nvim --headless -c 'lua require("lazy").load({ plugins = { "nvim-lspconfig", "conform.nvim", "nvim-lint" } })' \
  -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 900000)' \
  -c 'lua local mr=require("mason-registry"); mr.refresh(function() local n=0; for _,name in ipairs(require("nvchad.mason").get_pkgs()) do local ok,p=pcall(mr.get_package,(name:match("^([^@]+)"))); if ok and not p:is_installed() then n=n+1; p:install():once("closed",function() n=n-1; if n==0 then vim.schedule(function() vim.cmd("qa!") end) end end) end end; if n==0 then vim.cmd("qa!") end end)' 2>&1 | tail -n 5 || true

say "Installing treesitter parsers…"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
nvim --headless -c 'lua require("nvim-treesitter").install(require("configs.treesitter").ensure_installed):wait(900000)' +qa 2>&1 | tail -n 3 || true

# ===========================================================================
# 4. Sanity
# ===========================================================================
say "Refreshing font cache"
fc-cache -f >/dev/null 2>&1 || true

cat <<MSG

Done.
  * Set your terminal font to "JetBrainsMono Nerd Font" for icons.
  * Start nvim. If anything is missing run:
      :Lazy sync      :MasonInstallAll      :TSInstallAll     :checkhealth
  * Keymap docs:  <Space>?   inside nvim, or open docs/KEYMAPS.md
MSG
