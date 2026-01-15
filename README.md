# JVIM - Neovim Configuration for Java Development

[![Latest Release](https://img.shields.io/github/v/release/Israiloff/jvim)](https://github.com/Israiloff/jvim/releases/latest)
[![License](https://img.shields.io/github/license/Israiloff/jvim)](https://github.com/Israiloff/jvim/blob/master/LICENSE)

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Docker Container](#docker-container)
- [Core Plugins](#core-plugins)
- [Configuration](#configuration)
- [Key Mappings](#key-mappings)
- [Features in Detail](#features-in-detail)
- [Troubleshooting](#troubleshooting)
- [Gallery](#gallery)
- [Contributing](#contributing)
- [License](#license)

## Introduction

**JVIM** is a comprehensive, production-ready Neovim configuration specifically optimized for Java development. Built with modern development workflows in mind, it provides a complete IDE experience with advanced LSP support, debugging capabilities, intelligent code completion, and a rich plugin ecosystem.

### Key Features

- 🚀 **Full Java Development Suite**: JDTLS integration with debugging, testing, and refactoring
- 🎨 **Modern UI**: Beautiful interface with custom Java colorscheme, statusline, and buffer management
- 🔍 **Powerful Search**: Telescope fuzzy finder with file history and live grep
- 🔄 **Git Integration**: Gitsigns for hunks, lazygit integration, and comprehensive git operations
- 🤖 **AI-Powered**: GitHub Copilot and ChatGPT-4 support for intelligent code assistance
- 📝 **Enhanced Editing**: Auto-save, smart commenting, snippets, and format-on-save
- 🐛 **Advanced Debugging**: Full DAP (Debug Adapter Protocol) support with UI
- 🔧 **LSP Excellence**: Multiple language server support with Mason package manager
- 📦 **Plugin Management**: Lazy.nvim for fast, declarative plugin management
- 🎯 **Efficient Navigation**: Which-key menu system, nvim-tree explorer, and quick jumps

---

## Requirements

### System Requirements

To use JVIM effectively, ensure the following software is installed on your system:

| Software | Purpose | Required |
|----------|---------|----------|
| **Neovim** | Version 0.9.0+ | ✅ Required |
| **Java JDK** | Java Development Kit (JDK 11+) | ✅ Required |
| **Git** | Version control operations | ✅ Required |
| **Node.js & npm** | Language server and plugin support | ✅ Required |
| **curl** | Downloading plugins and resources | ✅ Required |
| **unzip** | Extracting plugin archives | ✅ Required |
| **ripgrep** | Fast text search (for Telescope) | ⭐ Recommended |
| **fd** | Fast file finder (for Telescope) | ⭐ Recommended |
| **yarn** | Markdown preview UI | ⚙️ Optional |
| **lazygit** | Terminal UI for git | ⚙️ Optional |

### Font Requirements

For proper icon display, install a [Nerd Font](https://www.nerdfonts.com/). Popular choices:
- JetBrains Mono Nerd Font
- Fira Code Nerd Font
- Hack Nerd Font

---

## Installation

### Quick Start

1. **Backup your existing Neovim configuration** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   mv ~/.local/state/nvim ~/.local/state/nvim.backup
   mv ~/.cache/nvim ~/.cache/nvim.backup
   ```

2. **Clone the JVIM repository**:
   ```bash
   git clone https://github.com/Israiloff/jvim.git ~/.config/nvim
   ```

3. **Launch Neovim**:
   ```bash
   nvim
   ```
   
   On first launch, Lazy.nvim will automatically install all plugins. Wait for the installation to complete.

4. **Verify installation**:
   - Check Mason status: `:Mason`
   - Check LSP status: `:LspInfo`
   - Check installed plugins: `:Lazy`

### Post-Installation Setup

#### Markdown Preview (Optional)

If you need Markdown preview functionality:

```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim && yarn install
```

#### Mason Tools

JVIM automatically installs essential tools via Mason:
- `java-debug-adapter` - Java debugging support
- `java-test` - Java testing framework
- `stylua` - Lua code formatter
- `prettier` - Multi-language formatter

Additional language servers will be installed automatically when you open files of supported types.

### AI Integration Setup

#### GitHub Copilot

GitHub Copilot provides AI-powered code completions and suggestions.

**Setup:**
1. Run `:Copilot setup` in Neovim
2. Follow the authentication process
3. Enable with `:Copilot enable`

**Usage:**
- Completions are available in insert mode with `Alt+L`
- Additional suggestions available in normal mode via which-key menu

#### OpenAI ChatGPT-4

ChatGPT integration enables AI-powered code assistance, refactoring, and more.

**Setup:**
1. Get an [OpenAI API key](https://platform.openai.com/api-keys)
2. Set the environment variable:
   ```bash
   echo 'export OPENAI_API_KEY=YOUR_PERSONAL_OPENAI_API_KEY' >> ~/.zshrc
   # or for bash:
   echo 'export OPENAI_API_KEY=YOUR_PERSONAL_OPENAI_API_KEY' >> ~/.bashrc
   ```
3. Reload your shell configuration

**Usage:**
All ChatGPT features are accessible via the which-key menu (`Space + a`):
- Code editing with instructions
- Grammar correction
- Translation
- Docstring generation
- Test generation
- Code optimization

> **Tip**: Press `Space` to open the which-key menu and explore all available features.

---

## Docker Container

For a containerized development environment, use the official JVIM Docker image.

**Pull the image:**
```bash
docker pull israiloff/jvim:latest
```

**Run the container:**
```bash
docker run -it -d \
  --network host \
  --name jvim \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/local/bin/docker:/usr/local/bin/docker \
  israiloff/jvim
```

**Access the container:**
```bash
docker exec -it jvim /bin/zsh
```

For more details, visit the [jvim-docker repository](https://github.com/Israiloff/jvim-docker).

---

## Core Plugins

JVIM includes a carefully curated collection of plugins organized by functionality:

### Language Support & LSP

| Plugin | Description |
|--------|-------------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Quickstart configurations for Neovim LSP client |
| [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) | Java LSP extensions and JDTLS integration |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | Portable package manager for LSP servers, DAP servers, linters, and formatters |
| [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Bridge between Mason and nvim-lspconfig |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Automatic installation of Mason tools |
| [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) | Use Neovim as a language server for linting and formatting |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Faster Lua development with proper LSP support |

### Completion & Snippets

| Plugin | Description |
|--------|-------------|
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine with multiple sources |
| [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP source for nvim-cmp |
| [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | Buffer words source for nvim-cmp |
| [cmp-path](https://github.com/hrsh7th/cmp-path) | File path source for nvim-cmp |
| [cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline) | Command line source for nvim-cmp |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | LuaSnip source for nvim-cmp |
| [lspkind.nvim](https://github.com/onsails/lspkind.nvim) | VSCode-like pictograms for completion |

### Syntax & Parsing

| Plugin | Description |
|--------|-------------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Advanced syntax highlighting and code manipulation |

### Debugging

| Plugin | Description |
|--------|-------------|
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client implementation |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | UI for nvim-dap with virtual text and enhanced debugging experience |
| [telescope-dap.nvim](https://github.com/nvim-telescope/telescope-dap.nvim) | Telescope integration for DAP |
| [vim-codelens](https://github.com/markwoodhall/vim-codelens) | CodeLens support for displaying code actions |

### File Navigation & Search

| Plugin | Description |
|--------|-------------|
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder over lists with previews |
| [telescope-file-history.nvim](https://github.com/dawsers/telescope-file-history.nvim) | Browse file history with Telescope |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer with icons and tree view |
| [lir.nvim](https://github.com/tamago324/lir.nvim) | Lightweight file browser |
| [project.nvim](https://github.com/ahmedkhalf/project.nvim) | Project management with auto root detection |

### Git Integration

| Plugin | Description |
|--------|-------------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations and hunk operations |

### User Interface

| Plugin | Description |
|--------|-------------|
| [darcula-java](https://github.com/israiloff/darcula-java) | Custom Java-optimized colorscheme based on JetBrains Darcula |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Fast and customizable statusline |
| [lualine-time](https://github.com/archibate/lualine-time) | Time component for lualine |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer line with tabs and IDE-like buffer management |
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | Fast and customizable greeter/dashboard |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | Shows code context in statusline |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides with scope highlighting |
| [nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar) | Scrollbar with diagnostic indicators |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File type icons |

### Terminal

| Plugin | Description |
|--------|-------------|
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Terminal management with multiple layouts (floating, vertical, horizontal) |

### Editing Enhancement

| Plugin | Description |
|--------|-------------|
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Displays available keybindings in popup |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Smart and powerful commenting |
| [auto-save.nvim](https://github.com/Pocco81/auto-save.nvim) | Automatic file saving |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search TODO comments |
| [formatter.nvim](https://github.com/mhartington/formatter.nvim) | Format runner for Neovim |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Search and replace with modern UI |

### AI & Productivity

| Plugin | Description |
|--------|-------------|
| [copilot.vim](https://github.com/github/copilot.vim) | GitHub Copilot integration for AI-powered code suggestions |

### Markdown

| Plugin | Description |
|--------|-------------|
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live markdown preview in browser |

### XML Support

| Plugin | Description |
|--------|-------------|
| [lemminx-compiled](https://github.com/Israiloff/lemminx-compiled) | Precompiled Eclipse Lemminx language server for XML |

### Utilities

| Plugin | Description |
|--------|-------------|
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utility functions used by many plugins |
| [lush.nvim](https://github.com/rktjmp/lush.nvim) | Colorscheme creation tool |
| [luvit-meta](https://github.com/Bilal2453/luvit-meta) | Meta type definitions for Lua |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio) | Async IO library for Neovim |
| [mason-registry](https://github.com/mason-org/mason-registry) | Registry for Mason packages |

---

## Configuration

### JDTLS (Java Language Server)

JVIM automatically configures JDTLS with:
- **Logger Setup**: Debug logging for troubleshooting
- **Maven Integration**: Automatic dependency resolution and updates
- **Debug Support**: Full DAP integration with Java Debug Adapter
- **Code Actions**: Extract variable/constant/method, organize imports
- **Test Runner**: JUnit and TestNG support via java-test
- **Spring Boot**: Profile support with `-Dspring.profiles.active=local`
- **IntelliJ-style**: Code lens for references and implementations

### Key Mappings

> **Tip**: Press `Space` to open the which-key menu for an interactive guide to all available commands.

#### General Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to lower window |
| `<C-k>` | Normal | Move to upper window |
| `<C-l>` | Normal | Move to right window |
| `<M-l>` | Normal | Next buffer |
| `<M-h>` | Normal | Previous buffer |
| `<M-j>` | Normal/Visual/Insert | Move line down |
| `<M-k>` | Normal/Visual/Insert | Move line up |

#### Terminal

| Key | Mode | Description |
|-----|------|-------------|
| `<M-1>` or `¡` | Normal/Terminal | Toggle horizontal terminal |
| `<M-2>` or `™` | Normal/Terminal | Toggle vertical terminal |
| `<M-3>` or `£` | Normal/Terminal | Toggle floating terminal |

> **macOS Note**: The special characters are Alt-key mappings that work on macOS keyboards.

#### LSP Operations

| Key | Mode | Description |
|-----|------|-------------|
| `gr` | Normal | Go to references |
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition |
| `gi` | Normal | Go to implementation |
| `gt` | Normal | Go to type definition |
| `<M-p>` | Normal | Show signature help |
| `<M-i>` | Normal | Show hover documentation |

#### Java Quick Actions

| Key | Mode | Description |
|-----|------|-------------|
| `<M-5>` | Normal | Refresh Maven dependencies |
| `<M-7>` | Normal | Toggle DAP UI |
| `<M-8>` | Normal | Debug step over |
| `<M-9>` | Normal | Debug continue |
| `<M-0>` | Normal | Debug stop |

#### which-key Mappings

Press `<Space>` to activate the which-key menu.

| Key Combination | Description                           |
| --------------- | ------------------------------------- |
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
| `<Space>s u`    | Search/Replace UI (grug-far)          |
| `<Space>s w`    | Search word (current file)            |
| `<Space>s W`    | Search word (all files)               |
| `<Space>s r`    | Replace word (current file)           |
| `<Space>s R`    | Replace word (all files)              |
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
| --------------- | ------------------------------ |
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

### Visual Mode Mappings

| Key Combination | Description                       |
| --------------- | --------------------------------- |
| `<Space>/`      | Comment selection                 |
| `<Space>f s`    | Search selection (current file)   |
| `<Space>f S`    | Search selection (all files)      |
| `<Space>f r`    | Replace selection (current file)  |
| `<Space>f R`    | Replace selection (all files)     |

---

## Features in Detail

### Java Development

JVIM provides a complete Java IDE experience:

- **Language Server**: JDTLS with full LSP capabilities
- **Code Navigation**: Go to definition, references, implementations
- **Refactoring**: Extract method/variable/constant, organize imports
- **Debugging**: Full DAP support with breakpoints, step through, watches
- **Testing**: Run individual tests or full test classes
- **Maven Support**: Automatic dependency management and updates
- **Spring Boot**: Profile configuration and running

### Search & Replace

Powered by grug-far.nvim for a modern search and replace experience:

- **Visual UI**: Modern, intuitive interface for find and replace operations
- **Context-aware**: Search in current file or entire project
- **Visual mode**: Search and replace selected text
- **Live Preview**: See changes before applying them
- **RegExp Support**: Full regular expression support for complex patterns

### Terminal Integration

Three terminal layouts available:

- **Floating Terminal** (`<M-3>` or `£`): Overlay terminal for quick commands
- **Vertical Terminal** (`<M-2>` or `™`): Side-by-side terminal and editor
- **Horizontal Terminal** (`<M-1>` or `¡`): Bottom terminal panel

All terminals:
- Persist across sessions
- Support full color and Unicode
- Auto-detect shell (bash/zsh/fish)
- Work seamlessly with tmux and screen

### File Explorer

**nvim-tree** provides a feature-rich file explorer:
- Toggle with `<Space>e`
- Icons for file types
- Git status indicators
- Create, delete, rename files/folders
- Open files in splits or tabs
- Bookmark system

### Project Management

Automatic project detection and management:
- Recent projects accessible via `<Space>p`
- Auto-detection of project root (git, Maven, etc.)
- Per-project settings and workspaces
- Quick switching between projects

### Auto-save

Files are automatically saved:
- On buffer leave
- On focus lost
- After idle time
- Configurable per file type

---

## Troubleshooting

### Common Issues

#### LSP not working for Java files

1. Check if JDTLS is installed: `:Mason`
2. Check LSP status: `:LspInfo`
3. View logs: `~/.local/state/nvim/lsp.log`
4. Ensure Java JDK is installed: `java --version`

#### Copilot not providing suggestions

1. Check auth status: `:Copilot status`
2. Re-authenticate: `:Copilot setup`
3. Enable if disabled: `:Copilot enable`

#### Plugins not loading

1. Update plugins: `<Space>P u`
2. Sync plugins: `<Space>P s`
3. Check for errors: `<Space>P l`
4. Clean and reinstall: `<Space>P c` then `<Space>P i`

#### Terminal not opening

1. Check toggleterm status: `:checkhealth toggleterm`
2. Verify shell is accessible: `echo $SHELL`
3. Try different terminal layout with different key binding

#### Mason tools not installing

1. Check network connectivity
2. Ensure curl, git, and unzip are installed
3. Check Mason log: `:Mason` then view log in Mason UI
4. Manually install: `:MasonInstall <tool-name>`

### Getting Help

- View Neovim health: `:checkhealth`
- Check plugin status: `<Space>P S`
- View messages: `<Space>n l`
- Open help: `<Space>s h`
- Browse keymaps: `<Space>s k`

---

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

---

## Contributing

Contributions are welcome! If you'd like to contribute to JVIM:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Reporting Issues

Please report bugs and feature requests on the [GitHub Issues](https://github.com/Israiloff/jvim/issues) page.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

JVIM is built on top of amazing open-source projects:

- [Neovim](https://neovim.io/) - The hyperextensible Vim-based text editor
- All plugin authors who make the Neovim ecosystem incredible
- JetBrains for the Darcula color scheme inspiration
- The Neovim community for continuous support and inspiration

---

## Support

If you find JVIM useful, please consider:

- ⭐ Starring the repository on GitHub
- 🐛 Reporting bugs and suggesting features
- 📖 Contributing to documentation
- 🔧 Submitting pull requests

**Happy Coding with JVIM! 🚀**
