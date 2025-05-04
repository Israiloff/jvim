# JVIM - Neovim Configuration for Java Development

[![Latest Release](https://img.shields.io/github/v/release/Israiloff/jvim)](https://github.com/Israiloff/jvim/releases/latest)

## Introduction

JVIM is a Neovim configuration tailored for Java development. This documentation describes the plugins used and key
configurations.

## Project Requirements

To use JVIM effectively, ensure the following software is installed on your system:

- **Java**: A Java Development Kit (JDK) is required for Java development.
- **npm**: Node Package Manager, used for managing JavaScript packages.
- **yarn**: A package manager that doubles down as a project manager.
- **git**: Version control system for tracking changes in source code.
- **curl**: A command-line tool for transferring data with URLs.
- **unzip**: An unarchivation tool for multiple plugins.

## Installation

1. Clone [configurations](https://github.com/Israiloff/jvim) into the **$HOME/.config/nvim/** folder.

```bash
git clone https://github.com/Israiloff/jvim.git $HOME/.config/nvim/
```

2. Install yarn to enable markdown preview UI (if you need).

```bash
cd $HOME/.local/share/nvim/lazy/markdown-preview.nvim && yarn install
```

## Plugins

### 1. [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Provides better syntax highlighting and code manipulation using Treesitter.

### 2. [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

A library of Lua functions used by many Neovim plugins.

### 3. [folke/which-key.nvim](https://github.com/folke/which-key.nvim)

Displays keybindings in a popup, helping you discover available keybindings.

### 4. [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

Quickstart configurations for the Neovim LSP client, essential for integrating language servers.

### 5. [israiloff/darcula-java](https://github.com/israiloff/darcula-java)

A colorscheme designed for Java development.

### 6. [github/copilot.vim](https://github.com/github/copilot.vim)

GitHub Copilot integration for code suggestions.

### 7. [dawsers/telescope-file-history.nvim](https://github.com/dawsers/telescope-file-history.nvim)

A Telescope extension for browsing file history.

### 8. [Pocco81/auto-save.nvim](https://github.com/Pocco81/auto-save.nvim)

Automatically saves files on certain events, ensuring you don't lose changes.

### 9. [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)

Highlights and searches for TODO comments, making task tracking easier.

### 10. [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

A fuzzy finder and more for Neovim, providing a powerful search interface.

### 11. [nvimtools/none-ls.nvim](https://github.com/nvimtools/none-ls.nvim)

A plugin for integrating external tools as language servers.

### 12. [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

An auto-completion plugin for Neovim, along with dependencies
like `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `LuaSnip`, and `cmp_luasnip`.

### 13. [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic)

Provides a statusline component that shows the current code context, helping you navigate your code.

### 14. [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

A plugin to preview Markdown files in a browser.

### 15. [Israiloff/lemminx-compiled](https://github.com/Israiloff/lemminx-compiled)

A precompiled version of Eclipse's Lemminx plugin for XML support.

## Key Configurations

### JDTLS Configuration (`java.lua`)

- **Logger Setup**: Initializes a logger for debugging purposes.
- **Mason and JDTLS Initialization**: Verifies and sets up `mason` and `jdtls`.
- **Utility Functions**: Checks and loads utility functions from `io.github.israiloff.config.utils`.

### which-key Configuration (`which-key.lua`)

- **Marks**: Shows a list of marks.
- **Registers**: Displays registers on specific keybindings.
- **Spelling**: Configured but disabled for showing spelling suggestions.
- **Presets**: Controls the display of help for various default keybindings in Neovim.

### Key Mappings

#### General Key Mappings

| Key Combination | Description             |
|-----------------|-------------------------|
| `<C-h>`         | Move to left window     |
| `<C-j>`         | Move to lower window    |
| `<C-k>`         | Move to upper window    |
| `<C-l>`         | Move to right window    |
| `<M-l>`         | Next buffer             |
| `<M-h>`         | Previous buffer         |
| `<M-j>`         | Move line down (normal) |
| `<M-k>`         | Move line up (normal)   |
| `<M-j>`         | Move line down (visual) |
| `<M-k>`         | Move line up (visual)   |
| `<M-j>`         | Move line down (insert) |
| `<M-k>`         | Move line up (insert)   |

#### LSP Mappings

| Key Combination | Description           |
|-----------------|-----------------------|
| `gr`            | Goto references       |
| `gD`            | Go to declaration     |
| `gd`            | Go to definition      |
| `gi`            | Go to implementation  |
| `<M-p>`         | Signature help        |
| `gt`            | Go to type definition |
| `<M-i>`         | Show hover            |

#### Java Mappings

| Key Combination | Description                |
|-----------------|----------------------------|
| `<M-5>`         | Refresh Maven dependencies |
| `<M-7>`         | Toggle DAP UI              |
| `<M-8>`         | Debug step over            |
| `<M-9>`         | Debug continue             |
| `<M-0>`         | Debug stop                 |

#### which-key Mappings

Press `<Space>` to activate the which-key menu.

| Key Combination | Description                           |
|-----------------|---------------------------------------|
| `<Space>f`      | Find Files                            |
| `<Space>u`      | Update configs                        |
| `<Space>c`      | Close buffer                          |
| `<Space>q`      | Quit                                  |
| `<Space>e`      | Explorer                              |
| `<Space>l`      | Code Actions                          |
| `<Space>l d`    | Buffer Diagnostics                    |
| `<Space>l w`    | Diagnostics                           |
| `<Space>l i`    | Info                                  |
| `<Space>l j`    | Next Diagnostic                       |
| `<Space>l k`    | Prev Diagnostic                       |
| `<Space>l r`    | Rename                                |
| `<Space>F`      | File                                  |
| `<Space>F h`    | View the file’s history               |
| `<Space>F l`    | View the file’s history incrementally |
| `<Space>F f`    | View every file in the repo           |
| `<Space>n`      | Notifications                         |
| `<Space>n l`    | Show notification log                 |
| `<Space>s`      | Search                                |
| `<Space>s b`    | Checkout branch                       |
| `<Space>s c`    | Colorscheme                           |
| `<Space>s f`    | Find File                             |
| `<Space>s h`    | Find Help                             |
| `<Space>s H`    | Find highlight groups                 |
| `<Space>s M`    | Man Pages                             |
| `<Space>s r`    | Open Recent File                      |
| `<Space>s R`    | Registers                             |
| `<Space>s t`    | Text                                  |
| `<Space>s k`    | Keymaps                               |
| `<Space>s C`    | Commands                              |
| `<Space>s l`    | Resume last search                    |
| `<Space>s p`    | Colorscheme with Preview              |
| `<Space>g`      | Git                                   |
| `<Space>g g`    | Lazygit                               |
| `<Space>g j`    | Next Hunk                             |
| `<Space>g k`    | Prev Hunk                             |
| `<Space>g l`    | Blame                                 |
| `<Space>g L`    | Blame Line (full)                     |
| `<Space>g p`    | Preview Hunk                          |
| `<Space>g r`    | Reset Hunk                            |
| `<Space>g R`    | Reset Buffer                          |
| `<Space>g s`    | Stage Hunk                            |
| `<Space>g u`    | Undo Stage Hunk                       |
| `<Space>g o`    | Open changed file                     |
| `<Space>g b`    | Checkout branch                       |
| `<Space>g c`    | Checkout commit                       |
| `<Space>/`      | Comment current line                  |
| `<Space>P`      | Plugins                               |
| `<Space>P i`    | Install                               |
| `<Space>P s`    | Sync                                  |
| `<Space>P S`    | Status                                |
| `<Space>P c`    | Clean                                 |
| `<Space>P u`    | Update                                |
| `<Space>P p`    | Profile                               |
| `<Space>P l`    | Log                                   |
| `<Space>P d`    | Debug                                 |
| `<Space>p`      | Projects                              |
| `<Space>r`      | Recent Files                          |
| `<Space>a`      | Open AI                               |
| `<Space>a c`    | ChatGPT                               |
| `<Space>a e`    | Edit with instruction                 |
| `<Space>a g`    | Grammar Correction                    |
| `<Space>a t`    | Translate                             |
| `<Space>a k`    | Keywords                              |
| `<Space>a d`    | Docstring                             |
| `<Space>a a`    | Add Tests                             |
| `<Space>a o`    | Optimize Code                         |

### Java which-key Mappings

| Key Combination | Description                    |
|-----------------|--------------------------------|
| `<Space>j o`    | Organize Imports               |
| `<Space>j v`    | Extract Variable               |
| `<Space>j c`    | Extract Constant               |
| `<Space>j t`    | Test Method                    |
| `<Space>j T`    | Test Class                     |
| `<Space>j u`    | Update Config                  |
| `<Space>j d t`  | Debug - Toggle Breakpoint      |
| `<Space>j d b`  | Debug - Step Back              |
| `<Space>j d c`  | Debug - Continue               |
| `<Space>j d C`  | Debug - Run To Cursor          |
| `<Space>j d d`  | Debug - Disconnect             |
| `<Space>j d g`  | Debug - Get Session            |
| `<Space>j d i`  | Debug - Step Into              |
| `<Space>j d o`  | Debug - Step Over              |
| `<Space>j d u`  | Debug - Step Out               |
| `<Space>j d p`  | Debug - Pause                  |
| `<Space>j d r`  | Debug - Toggle Repl            |
| `<Space>j d s`  | Debug - Start                  |
| `<Space>j d q`  | Debug - Quit                   |
| `<Space>j d U`  | Debug - Toggle UI              |
| `<Space>j v`    | Extract Variable (Visual Mode) |
| `<Space>j c`    | Extract Constant (Visual Mode) |
| `<Space>j m`    | Extract Method (Visual Mode)   |

## Docker Container
You can use the [Docker container](https://hub.docker.com/r/israiloff/jvim) configured in a separate 
[project](https://github.com/Israiloff/jvim-docker) in a few simple steps.

- Pull the image
```bash
docker pull israiloff/jvim:latest
```

- Run the container with all ports exposed and with full access to your local docker
```bash
docker run -it -d --network host --name jvim -v /var/run/docker.sock:/var/run/docker.sock -v /usr/local/bin/docker:/usr/local/bin/docker israiloff/jvim
```

- Enter the container
```bash
docker exec -it jvim /bin/zsh
```

## Gallery

### Welcome Screen
![Welcome](https://github.com/Israiloff/jvim-gallery/blob/master/welcome.png)

### Nvim-Tree
![Nvim-Tree](https://github.com/Israiloff/jvim-gallery/blob/master/nvim-tree_and_java_code.png)

### Which-Key Menu
![Which-Key](https://github.com/Israiloff/jvim-gallery/blob/master/which-key.png)

### File search with Telescope
![Telescope](https://github.com/Israiloff/jvim-gallery/blob/master/telescope.png)

### Built-in Terminal (horizontal)
![Terminal](https://github.com/Israiloff/jvim-gallery/blob/master/toggleterm_horizontal.png)
