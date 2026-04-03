# .nvim

My Neovim setup, packaged like my `.tmux` repo so I can bootstrap a fresh machine quickly and keep the config reproducible.

## Features

- ships my current Neovim config from `~/.config/nvim`
- bootstraps `lazy.nvim` automatically
- restores pinned plugin versions from `lazy-lock.json`
- installs Treesitter parsers used by the config
- installs Mason-managed LSPs / formatters / linters referenced by the config
- installs common system dependencies (`git`, `ripgrep`, `fd`, ImageMagick, Node, etc.)
- falls back to a local official Neovim build if the package-manager version is older than 0.11

## Repo layout

- `nvim/` — actual config that gets symlinked to `~/.config/nvim`
- `install.sh` — bootstrap installer
- `LICENSE` — MIT license

## Quick install

### From GitHub

```bash
curl -fsSL "https://raw.githubusercontent.com/RPIFisherman/.nvim/main/install.sh" | bash
```

### From GitHub with a custom clone path

```bash
OH_MY_NVIM_CLONE_PATH="$HOME/.local/share/nvim/my-nvim" \
  curl -fsSL "https://raw.githubusercontent.com/RPIFisherman/.nvim/main/install.sh" | bash
```

### Local checkout

```bash
~/projects/.nvim/install.sh
```

## What the installer does

1. Detects your package manager (`apt`, `brew`, `dnf`, or `pacman`)
2. Installs common Neovim dependencies
3. Upgrades to a local official Neovim build when the system version is too old for this config
4. Backs up an existing `~/.config/nvim` if present
5. Clones this repo into `~/.local/share/nvim/oh-my-nvim` when installing from GitHub, or uses the local checkout when run from the repo
6. Symlinks `~/.config/nvim` → the managed `nvim/` directory
7. Bootstraps plugins with `lazy.nvim`
8. Installs Mason packages referenced by the config
9. Installs the configured Treesitter parsers

## Notes

- The config is self-contained and does not depend on `~/.vimrc`.
- On Ubuntu/Debian, the installer installs `nodejs` but intentionally does **not** force-install the distro `npm` package, because NodeSource `nodejs` can conflict with Ubuntu's `npm` package.
- `peek.nvim` is kept, but its build step is skipped automatically if `deno` is missing.
- `image.nvim` is still included and uses the current `magick_rock` setup, so the installer also pulls ImageMagick development packages when available.
- State files like `webui.db` are intentionally not tracked.

## Dry run

```bash
DRY_RUN=true ~/projects/.nvim/install.sh
```

Or from GitHub:

```bash
curl -fsSL "https://raw.githubusercontent.com/RPIFisherman/.nvim/main/install.sh" | DRY_RUN=true bash
```

## Manual bootstrap inside Neovim

If you ever want to rerun the managed installs:

```vim
:Lazy! sync
:MasonInstall pyright clangd stylua shfmt shellcheck black isort ruff prettier prettierd eslint_d markdownlint yamllint google-java-format ktlint php-cs-fixer pint phpcbf csharpier swiftformat clang-format xmlformatter sqlfmt sql-formatter
:TSInstallSync bash c cpp css html java javascript typescript tsx json jsonc kotlin lua markdown markdown_inline php python sql swift vue xml yaml
```

## License

MIT
