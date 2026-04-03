# Dependencies

This file explains what `install.sh` needs, what it installs automatically, and which extra tools are optional but useful for the full Neovim experience.

## 1. Installer profiles

`install.sh` supports two dependency profiles:

- `recommended` (default)
  - installs the base dependency set
  - tries to install extra runtimes like Java / PHP / LuaRocks in best-effort mode
  - prints a dependency report at the end
- `minimal`
  - installs the base dependency set only
  - still tries a few lightweight optional extras in best-effort mode
  - skips the larger recommended runtime add-ons

Use the minimal profile like this:

```bash
OH_MY_NVIM_INSTALL_PROFILE=minimal ./install.sh
```

Or from GitHub:

```bash
curl -fsSL "https://raw.githubusercontent.com/RPIFisherman/.nvim/main/install.sh" | \
  OH_MY_NVIM_INSTALL_PROFILE=minimal bash
```

## 2. Minimum requirements to run `install.sh`

These are needed before the installer can do anything meaningful:

- `bash`
- `curl`
- `git`
- `tar`
- `unzip`
- a supported package manager:
  - `apt`
  - `brew`
  - `dnf`
  - `pacman`

If your machine does not have one of those package managers, the script can still do the repo/linking parts, but you may need to install dependencies manually.

## 3. What `install.sh` tries to install automatically

### Ubuntu / Debian (`apt`)

Base install:

```bash
sudo apt-get update
sudo apt-get install -y \
  git curl unzip build-essential ripgrep fd-find xclip wl-clipboard \
  imagemagick libmagickwand-dev python3 python3-pip nodejs neovim
```

Recommended extras (`recommended` profile, best effort):

```bash
sudo apt-get install -y default-jre-headless php-cli luarocks lua5.1
```

Optional extras (best effort):

```bash
sudo apt-get install -y deno libxml2-utils
```

### Homebrew (`brew`)

Base install:

```bash
brew install \
  neovim git curl unzip ripgrep fd imagemagick python node
```

Recommended extras (`recommended` profile, best effort):

```bash
brew install openjdk php luarocks
```

Optional extras (best effort):

```bash
brew install deno
```

### Fedora (`dnf`)

Base install:

```bash
sudo dnf install -y \
  neovim git curl unzip gcc-c++ make ripgrep fd-find xclip wl-clipboard \
  ImageMagick ImageMagick-devel python3 python3-pip nodejs npm
```

Recommended extras (`recommended` profile, best effort):

```bash
sudo dnf install -y java-21-openjdk-headless php-cli luarocks lua
```

Optional extras (best effort):

```bash
sudo dnf install -y deno libxml2
```

### Arch (`pacman`)

Base install:

```bash
sudo pacman -Sy --needed --noconfirm \
  neovim git curl unzip base-devel ripgrep fd xclip wl-clipboard \
  imagemagick python python-pip nodejs npm
```

Recommended extras (`recommended` profile, best effort):

```bash
sudo pacman -Sy --needed --noconfirm jre-openjdk-headless php luarocks lua
```

Optional extras (best effort):

```bash
sudo pacman -Sy --needed --noconfirm deno libxml2
```

## 4. Important distro note: Ubuntu + NodeSource

On Ubuntu/Debian, this repo intentionally installs **`nodejs` but not the distro `npm` package** in the `apt` path.

Why:
- many systems use NodeSource `nodejs`
- Ubuntu's distro `npm` package can conflict with NodeSource `nodejs`
- that can make `apt install nodejs npm` fail before the rest of the installer can continue

If `node` is already present, Mason/npm-based tools can still install normally.

## 5. Core runtime dependencies by feature

These are the important dependencies that matter after Neovim starts.

### Always useful / strongly recommended

| Tool | Why it matters |
|---|---|
| `git` | lazy.nvim bootstrap, plugin installs, repo workflows |
| `node` | required by Node-based Mason packages like `pyright`, `prettier`, `prettierd`, `eslint_d`, `markdownlint` |
| `python3` | used by Python-based Mason packages like `black`, `isort`, `ruff`, `yamllint`, `sqlfmt` |
| `ripgrep` (`rg`) | used by Telescope live grep |
| `fd` / `fdfind` | useful for fast file finding workflows |
| `make` + C/C++ toolchain | needed for native plugin builds like `telescope-fzf-native.nvim` |
| `ImageMagick` | required by `image.nvim` |

### Clipboard / terminal niceties

| Tool | Why it matters |
|---|---|
| `xclip` | clipboard integration on X11 |
| `wl-clipboard` (`wl-copy`, `wl-paste`) | clipboard integration on Wayland |
| OSC 52-capable terminal | remote clipboard fallback configured in `init.lua` |

### Optional but useful

| Tool | Why it matters |
|---|---|
| `deno` | builds `peek.nvim` markdown preview support |
| `java` | useful for Java/Kotlin formatter tools like `google-java-format` and `ktlint` |
| `php` | needed if you expect PHP formatter tools to actually run |
| `.NET` / `dotnet` | may be needed depending on how `csharpier` is installed/used on a given platform |
| `swift` toolchain | needed for Swift-specific formatters/workflows |
| `xmllint` / `libxml2-utils` | fallback XML formatting path |
| `luarocks` | helpful when troubleshooting Lua rock / ImageMagick integration |

## 6. Mason-managed tools referenced by this config

The installer runs:

```vim
:MasonInstall pyright clangd stylua shfmt shellcheck black isort ruff prettier prettierd eslint_d markdownlint yamllint google-java-format ktlint php-cs-fixer pint phpcbf csharpier swiftformat clang-format xmlformatter sqlfmt sql-formatter
```

### What those tools roughly depend on

| Tool | Source type | Likely runtime dependency |
|---|---|---|
| `pyright` | npm | `node` |
| `clangd` | downloaded binary | none beyond system libraries |
| `stylua` | downloaded binary | none |
| `shfmt` | downloaded binary | none |
| `shellcheck` | downloaded binary | none |
| `black` | PyPI | `python3` / `pip` |
| `isort` | PyPI | `python3` / `pip` |
| `ruff` | PyPI/binary packaging | `python3` in Mason flow |
| `prettier` | npm | `node` |
| `prettierd` | npm | `node` |
| `eslint_d` | npm | `node` |
| `markdownlint` | npm | `node` |
| `yamllint` | PyPI | `python3` / `pip` |
| `google-java-format` | downloaded binary/jar wrapper | `java` recommended |
| `ktlint` | downloaded binary/jar wrapper | `java` recommended |
| `php-cs-fixer` | downloaded binary | `php` recommended |
| `pint` | composer/PHP ecosystem | `php` recommended |
| `phpcbf` | PHP ecosystem | `php` recommended |
| `csharpier` | platform-specific package | may need `.NET` |
| `swiftformat` | platform-specific package | Swift toolchain recommended |
| `clang-format` | platform-specific package | none / C++ runtime libs |
| `xmlformatter` | npm | `node` |
| `sqlfmt` | Python package | `python3` |
| `sql-formatter` | npm | `node` |

## 7. Treesitter parsers installed by this repo

The installer runs:

```vim
:TSInstallSync bash c cpp css html java javascript typescript tsx json jsonc kotlin lua markdown markdown_inline php python sql swift vue xml yaml
```

In practice, Treesitter mostly needs:
- a working Neovim
- network access on first install
- build tooling already covered by the installer

## 8. Plugin-specific gotchas

### `image.nvim`

Current config uses:

```lua
processor = "magick_rock"
```

That means:
- `ImageMagick` is required
- development headers/libraries help on Linux (`libmagickwand-dev` on Debian/Ubuntu)
- if image rendering still causes trouble on a host, switching to `magick_cli` is usually easier than debugging Lua/ImageMagick bindings

### `peek.nvim`

- works best with `deno`
- build is skipped gracefully if `deno` is missing
- missing `deno` should not break the rest of the setup

### `telescope-fzf-native.nvim`

- built with `make`
- requires compiler toolchain support
- on minimal systems, missing `make` / `cc` will degrade fuzzy matching performance but should not brick the whole config

## 9. Practical dependency tiers

If you want the shortest useful checklist for a new Linux machine:

### Tier 1: must-have

- `git`
- `curl`
- `bash`
- `neovim >= 0.11`
- `node`
- `python3`
- `ripgrep`
- `make`
- compiler toolchain (`cc` / `gcc` / `clang`)

### Tier 2: strongly recommended

- `fd` or `fdfind`
- `ImageMagick`
- `xclip` or `wl-clipboard`
- `java`
- `luarocks`

### Tier 3: optional / feature-specific

- `deno`
- `php`
- `dotnet`
- Swift toolchain
- `xmllint`

## 10. Debug checklist for a new machine

If install or runtime is flaky, check these first:

```bash
command -v bash git curl nvim node python3 rg make cc
command -v fd fdfind xclip wl-copy magick convert deno java php dotnet luarocks xmllint
nvim --version
node --version
python3 --version
```

Inside Neovim, useful checks are:

```vim
:checkhealth
:Mason
:Lazy
:TSInstallInfo
```

## 11. Recommendation

If a fresh machine is missing a lot of language runtimes, the safest mental model is:

- `install.sh` gets the base editor environment working
- Mason gets many editor-side tools installed
- some language-specific tools may still need their language runtime present to be fully useful

So for “works well on most developer machines”, the most important extra runtimes are:
- `node`
- `python3`
- `java`
- `make` + compiler toolchain
- `ImageMagick`
