#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  printf '❌ Do not execute this script as root!
' >&2
  exit 1
fi

if [ -z "${BASH_VERSION:-}" ]; then
  printf '❌ This installation script requires bash
' >&2
  exit 1
fi

is_true() {
  case "${1:-}" in
    true|yes|1|on)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

log() {
  printf '%s
' "$*" >&2
}

warn() {
  printf '⚠️  %s
' "$*" >&2
}

run() {
  if is_true "${DRY_RUN:-false}"; then
    printf 'DRY_RUN:' >&2
    for arg in "$@"; do
      printf ' %q' "$arg" >&2
    done
    printf '
' >&2
  else
    "$@"
  fi
}

run_maybe_failing() {
  if is_true "${DRY_RUN:-false}"; then
    run "$@"
  else
    if ! "$@"; then
      warn "Command failed but installation will continue: $*"
    fi
  fi
}

backup_path() {
  local path="$1"
  local now="$2"

  if [ -L "$path" ] || [ -e "$path" ]; then
    local backup="${path}.${now}"
    log "⚠️  Backing up ${path/#"$HOME"/'~'} -> ${backup/#"$HOME"/'~'}"
    run mv "$path" "$backup"
  fi
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

nvim_version() {
  if ! have_cmd nvim; then
    return 1
  fi
  nvim --version | awk 'NR==1 { sub(/^v/, "", $2); print $2 }'
}

version_ge() {
  [ "$(printf '%s
%s
' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

install_local_neovim_if_needed() {
  local now="$1"
  local min_version="0.11.0"
  local current_version=''
  current_version="$(nvim_version || true)"

  if [ -n "$current_version" ] && version_ge "$current_version" "$min_version"; then
    log "✅ Neovim version ${current_version} is compatible"
    return
  fi

  warn "Neovim ${current_version:-missing} is too old for this config; installing a local official Neovim build"

  local system
  local machine
  local asset=''
  local unpacked=''
  system="$(uname -s)"
  machine="$(uname -m)"

  case "$system-$machine" in
    Linux-x86_64)
      asset='nvim-linux-x86_64.tar.gz'
      unpacked='nvim-linux-x86_64'
      ;;
    Linux-aarch64|Linux-arm64)
      asset='nvim-linux-arm64.tar.gz'
      unpacked='nvim-linux-arm64'
      ;;
    Darwin-arm64)
      asset='nvim-macos-arm64.tar.gz'
      unpacked='nvim-macos-arm64'
      ;;
    Darwin-x86_64)
      asset='nvim-macos-x86_64.tar.gz'
      unpacked='nvim-macos-x86_64'
      ;;
    *)
      warn "Unsupported platform for automatic Neovim upgrade: $system-$machine"
      warn "Please install Neovim >= ${min_version} manually"
      return
      ;;
  esac

  local tmpdir
  local target_root="$HOME/.local/opt/nvim"
  tmpdir="$(mktemp -d)"

  run mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  backup_path "$target_root" "$now"

  log "⬇️  Downloading Neovim ${asset}"
  run curl -fL "https://github.com/neovim/neovim/releases/download/stable/${asset}" -o "$tmpdir/${asset}"
  run tar -C "$tmpdir" -xzf "$tmpdir/${asset}"
  run mv "$tmpdir/${unpacked}" "$target_root"
  run ln -sfn "$target_root/bin/nvim" "$HOME/.local/bin/nvim"
  export PATH="$HOME/.local/bin:$PATH"

  local updated_version=''
  updated_version="$(nvim_version || true)"
  if [ -n "$updated_version" ]; then
    log "✅ Local Neovim version ${updated_version} installed"
  fi
}

install_packages() {
  local pm=''
  if have_cmd apt-get; then
    pm='apt'
  elif have_cmd brew; then
    pm='brew'
  elif have_cmd dnf; then
    pm='dnf'
  elif have_cmd pacman; then
    pm='pacman'
  fi

  if [ -z "$pm" ]; then
    warn 'No supported package manager detected; skipping system package install'
    return
  fi

  log "🔧 Detected package manager: $pm"

  case "$pm" in
    apt)
      local base=(git curl unzip build-essential ripgrep fd-find xclip wl-clipboard imagemagick libmagickwand-dev python3 python3-pip nodejs npm neovim)
      run sudo apt-get update
      run sudo apt-get install -y "${base[@]}"
      run_maybe_failing sudo apt-get install -y deno libxml2-utils
      ;;
    brew)
      local base=(neovim git curl unzip ripgrep fd imagemagick python node deno)
      run brew install "${base[@]}"
      ;;
    dnf)
      local base=(neovim git curl unzip gcc-c++ make ripgrep fd-find xclip wl-clipboard ImageMagick ImageMagick-devel python3 python3-pip nodejs npm)
      run sudo dnf install -y "${base[@]}"
      run_maybe_failing sudo dnf install -y deno libxml2
      ;;
    pacman)
      local base=(neovim git curl unzip base-devel ripgrep fd xclip wl-clipboard imagemagick python python-pip nodejs npm)
      run sudo pacman -Sy --needed --noconfirm "${base[@]}"
      run_maybe_failing sudo pacman -Sy --needed --noconfirm deno libxml2
      ;;
  esac
}

main() {
  local now
  now=$(date +'%Y%m%d%H%M%S')

  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local xdg_cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
  local xdg_state_home="${XDG_STATE_HOME:-$HOME/.local/state}"

  local config_dir="$xdg_config_home/nvim"
  local clone_path="${OH_MY_NVIM_CLONE_PATH:-$xdg_data_home/nvim/oh-my-nvim}"
  local config_source="$clone_path/nvim"
  local repo_url="${OH_MY_NVIM_REPOSITORY:-https://github.com/REPLACE_ME/.nvim.git}"

  install_packages
  install_local_neovim_if_needed "$now"

  if ! have_cmd git; then
    printf '❌ git is required
' >&2
    exit 1
  fi

  if ! have_cmd nvim; then
    printf '❌ nvim is required (installer could not find it after package install)
' >&2
    exit 1
  fi

  if [ -f "$script_dir/nvim/init.lua" ] && [ -z "${OH_MY_NVIM_REPOSITORY:-}" ]; then
    log "📁 Using local checkout at ${script_dir/#"$HOME"/'~'}"
    config_source="$script_dir/nvim"
  else
    if [[ "$repo_url" == *'REPLACE_ME'* ]]; then
      printf '❌ Set OH_MY_NVIM_REPOSITORY to your GitHub repo URL or edit install.sh after you push the repo
' >&2
      exit 1
    fi

    backup_path "$clone_path" "$now"
    run mkdir -p "$(dirname "$clone_path")"
    log "⬇️  Cloning ${repo_url} -> ${clone_path/#"$HOME"/'~'}"
    run git clone --single-branch "$repo_url" "$clone_path"
  fi

  backup_path "$config_dir" "$now"
  run mkdir -p "$xdg_config_home" "$xdg_data_home/nvim" "$xdg_cache_home/nvim" "$xdg_state_home/nvim"
  run mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$xdg_data_home/nvim/mason/bin:$PATH"

  log "🔗 Linking ${config_dir/#"$HOME"/'~'} -> ${config_source/#"$HOME"/'~'}"
  run ln -sfn "$config_source" "$config_dir"

  local mason_packages=(
    pyright clangd stylua shfmt shellcheck black isort ruff prettier prettierd eslint_d
    markdownlint yamllint google-java-format ktlint php-cs-fixer pint phpcbf csharpier
    swiftformat clang-format xmlformatter sqlfmt sql-formatter
  )

  local ts_parsers=(
    bash c cpp css html java javascript typescript tsx json jsonc kotlin lua markdown
    markdown_inline php python sql swift vue xml yaml
  )

  log '🚀 Bootstrapping lazy.nvim plugins'
  run_maybe_failing nvim --headless '+Lazy! sync' '+qa'

  log '🚀 Installing Mason packages'
  run_maybe_failing nvim --headless "+MasonInstall ${mason_packages[*]}" '+qa'

  log '🚀 Installing Treesitter parsers'
  run_maybe_failing nvim --headless "+TSInstallSync ${ts_parsers[*]}" '+qa'

  log ''
  log '🎉 .nvim installation finished'
  log "✅ Config: ${config_dir/#"$HOME"/'~'}"
  if [ "$config_source" = "$script_dir/nvim" ]; then
    log "✅ Source: ${script_dir/#"$HOME"/'~'}"
  else
    log "✅ Source: ${clone_path/#"$HOME"/'~'}"
  fi
}

main "$@"
