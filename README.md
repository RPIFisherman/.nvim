# .nvim

My Neovim setup, packaged like my `.tmux` repo so I can clone it onto a fresh machine and bootstrap everything quickly.

## What this repo installs

- my current Neovim config from `~/.config/nvim`
- `lazy.nvim` as the plugin manager / bootstrapper
- pinned plugin versions via `lazy-lock.json`
- Treesitter parsers used by the config
- Mason-managed LSPs / formatters / linters referenced by the config
- system packages needed for the main workflow (`git`, `ripgrep`, `fd`, ImageMagick, Node, etc.)
- a local official Neovim build if the package-manager version is older than 0.11

## Repo layout

- `nvim/` → actual config that gets symlinked to `~/.config/nvim`
- `install.sh` → installer / bootstrap script

## Quick install

### Local checkout

```bash
~/projects/.nvim/install.sh
```

### From GitHub after you push this repo

Option 1: set the repo URL explicitly:

```bash
export OH_MY_NVIM_REPOSITORY="https://github.com/<your-user>/.nvim.git"
curl -fsSL "https://raw.githubusercontent.com/<your-user>/.nvim/main/install.sh" | bash
```

Option 2: edit the default `OH_MY_NVIM_REPOSITORY` value inside `install.sh` after you push, then the curl command can be shorter.

## What the installer does

1. Detects your package manager (`apt`, `brew`, `dnf`, or `pacman`)
2. Installs common Neovim dependencies
3. Upgrades to a local official Neovim build when the system version is too old for this config
4. Backs up an existing `~/.config/nvim` if present
5. Clones this repo into `~/.local/share/nvim/oh-my-nvim` (or uses the local checkout when run from the repo)
6. Symlinks `~/.config/nvim` → `.../oh-my-nvim/nvim`
7. Bootstraps plugins with `lazy.nvim`
8. Installs Mason packages referenced by the config
9. Installs the configured Treesitter parsers

## Notes

- The config is now self-contained and no longer depends on `~/.vimrc`.
- `peek.nvim` is kept, but its build step is skipped automatically if `deno` is missing.
- `image.nvim` is still included and uses the current `magick_rock` setup, so the installer also pulls ImageMagick development packages when available.
- State files like `webui.db` are intentionally not tracked.

## Dry run

```bash
DRY_RUN=true ~/projects/.nvim/install.sh
```

## Manual bootstrap inside Neovim

If you ever want to rerun the managed installs:

```vim
:Lazy! sync
:MasonInstall pyright clangd stylua shfmt shellcheck black isort ruff prettier prettierd eslint_d markdownlint yamllint google-java-format ktlint php-cs-fixer pint phpcbf csharpier swiftformat clang-format xmlformatter sqlfmt sql-formatter
:TSInstallSync bash c cpp css html java javascript typescript tsx json jsonc kotlin lua markdown markdown_inline php python sql swift vue xml yaml
```
