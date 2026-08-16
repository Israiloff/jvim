# JVIM - Neovim Configuration for Java Development

[![Latest Release](https://img.shields.io/github/v/release/Israiloff/jvim)](https://github.com/Israiloff/jvim/releases/latest)
[![License](https://img.shields.io/github/license/Israiloff/jvim)](https://github.com/Israiloff/jvim/blob/master/LICENSE)

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [AI Completion](#ai-completion)
- [Spring Boot](#spring-boot)
- [Docker Container](#docker-container)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [Gallery](#gallery)
- [Contributing](#contributing)
- [License](#license)

## Introduction

**JVIM** is a Neovim configuration built around Java development. It wires JDTLS,
debugging, testing and build-tool integration into a single setup that behaves
like an IDE, without giving up Neovim's startup time or keyboard-driven flow.

### Key Features

- 🚀 **Java, end to end** — JDTLS with debugging, tests, refactoring, and Maven/Gradle tasks
- ⚡ **Fast startup** — every plugin loads on demand; `nvim --startuptime` reports roughly 40 ms
- 👁 **Visible activity** — plugin loads and LSP progress are reported, so long operations are never silent
- 🤖 **Switchable AI completion** — GitHub Copilot or self-hosted Tabby, changed without editing code
- 🍃 **Optional Spring Boot tooling** — query-method completion from entity fields, `application.yml` support; off by default
- 🔍 **Search and replace** — Telescope for navigation, grug-far for project-wide replace, plus per-file history
- 🐛 **Full DAP debugging** — breakpoints, stepping, watches, and remote JVM attach
- 🔧 **Managed toolchain** — Mason installs language servers, formatters and debug adapters
- 🎨 **Darcula UI** — JetBrains-inspired colorscheme, breadcrumbs, statusline and buffer bar
- 🎯 **Discoverable keys** — every binding lives in a which-key menu instead of a cheatsheet

---

## Requirements

### System Requirements

| Software          | Purpose                            | Required       |
| ----------------- | ---------------------------------- | -------------- |
| **Neovim**        | Version 0.11+                      | ✅ Required    |
| **Java JDK**      | Java Development Kit (JDK 17+)     | ✅ Required    |
| **Git**           | Version control operations         | ✅ Required    |
| **Node.js & npm** | Language servers and plugin support| ✅ Required    |
| **curl**          | Downloading plugins and resources  | ✅ Required    |
| **unzip**         | Extracting plugin archives         | ✅ Required    |
| **ripgrep**       | Fast text search (for Telescope)   | ⭐ Recommended |
| **fd**            | Fast file finder (for Telescope)   | ⭐ Recommended |
| **yarn**          | Markdown preview UI                | ⚙️ Optional    |

> Neovim 0.11 is a hard minimum: the LSP setup uses `vim.lsp.config` /
> `vim.lsp.enable`, which do not exist in earlier versions.

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

   On first launch, Lazy.nvim installs all plugins. Wait for it to finish.

4. **Install the toolchain** — language servers, formatters and the Java debug
   adapter are installed on request rather than on every startup:

   ```vim
   :MasonToolsInstall
   ```

5. **Verify the installation**:

   ```vim
   :Mason      " toolchain status
   :LspInfo    " active language servers
   :Lazy       " plugin status
   :checkhealth
   ```

### Markdown Preview (Optional)

```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim && yarn install
```

---

## Configuration

All user-facing settings live in a single table in
`lua/io/github/israiloff/config/properties.lua`. To change anything without
touching the tracked file, create
`lua/io/github/israiloff/config/properties-local.lua` — it is gitignored and
deep-merged over the defaults:

```lua
return {
  gui = {
    -- Transparent background, so the terminal's own theme shows through.
    transparent = true,
    -- Bottom-right activity indicator.
    activity = {
      enabled = true,
      lazy = true, -- report plugin loads
      lsp = true,  -- report LSP progress
    },
  },
  ai = {
    provider = "tabby", -- copilot | tabby | none
  },
  spring = {
    enabled = false, -- Spring Boot tooling; costs a second language server
  },
  jdtls = {
    jvm = { xms = "256M", xmx = "1G" },
  },
  shell = {
    WINDOWS = "pwsh.exe",
    LINUX = "zsh",
    MACOS = "zsh",
  },
  logger = {
    enabled = false, -- turn on to trace the config's own startup
    enabled_loggers = { "*" },
  },
}
```

Only the keys you override need to be present.

---

## AI Completion

JVIM ships inline completion from either **GitHub Copilot** or **Tabby**, and only
loads the plugin for the provider you selected. Switching providers is a
configuration change, not a code change — pick one from the `AI` which-key menu
or set `ai.provider` directly, then restart Neovim.

```vim
:JvimAiStatus   " which provider is live now, and which is set for next start
:JvimAiSelect   " copilot | tabby | none
```

The selection is written to `properties-local.lua`, so it survives updates to the
repository.

### GitHub Copilot

1. Run `:Copilot setup` and complete the authentication flow.
2. Enable it with `:Copilot enable`.

The Copilot panel entry appears in the AI menu automatically while Copilot is the
active provider.

### Tabby

Self-hosted completion, sharing the same accept key as Copilot.

1. Install the agent: `npm install --global tabby-agent`
2. Configure `~/.tabby-client/agent/config.toml`
3. Select Tabby, then restart Neovim.

Ghost text is re-themed on every colorscheme change so it stays readable on a
transparent background.

---

## Spring Boot

Spring Boot tooling is **off by default**. It can be turned on from the `Spring`
entry of the Java which-key menu — which only exists inside a Java project — or
from the command line anywhere:

```vim
:JvimSpringStatus    " what is live now, and what is set for next start
:JvimSpringToggle    " flip it
:JvimSpringEnable
:JvimSpringDisable
```

Like the AI provider, the choice is written to `properties-local.lua` and applied
on the next start. It cannot take effect immediately: the tooling contributes
extension bundles that JDTLS only reads when the client starts.

Once enabled, `:MasonInstall vscode-spring-boot-tools` provides the server, and
you get:

- **Query-method completion** — typing `findBy` in a `Repository` interface completes from the entity's own fields, with parameter types filled in
- **Configuration files** — completion and navigation in `application.properties`, `application.yml` and their profile variants
- **Spring symbols** — beans and web endpoints exposed as workspace symbols, searchable through Telescope
- **Annotation hints** — inline information on Spring annotations

### What it costs

This is an add-on to JDTLS, not a replacement. `spring-boot-language-server`
starts as a **second LSP client** on Java and configuration buffers, and reaches
back into JDTLS over `workspace/executeCommand` for the type model — which is why
turning off JDTLS is not an option, and why disabling Spring support leaves
everything else untouched.

That second server is a separate JVM, roughly 300–600 MB in a real project on top
of JDTLS's own heap. On a large monorepo or a memory-constrained machine, leaving
it off is a reasonable default.

When the feature is disabled nothing is paid for it: the plugin is never
installed, the bundles are never collected, and the Mason package is dropped from
the tool list. Startup stays at roughly 40 ms either way.

---

## Docker Container

For a containerized development environment, use the official JVIM Docker image.

**Pull the latest image:**

```bash
docker pull israiloff/jvim:latest
```

**Pull a specific version:**

```bash
docker pull israiloff/jvim:0.4.14
```

> Available tags can be found on [Docker Hub](https://hub.docker.com/r/israiloff/jvim/tags).

**Run the container:**

```bash
docker run -it -d \
  --network host \
  --name jvim \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/local/bin/docker:/usr/local/bin/docker \
  israiloff/jvim:latest
```

> ⚠️ **Security Considerations**:
>
> - `--network host` removes network isolation between container and host
> - Mounting the Docker socket provides full access to the Docker daemon
> - These settings are intended for development environments only
> - For production or sensitive environments, use proper network isolation and avoid mounting the Docker socket

**Access the container:**

```bash
docker exec -it jvim /bin/zsh
```

For more details, visit the [jvim-docker repository](https://github.com/Israiloff/jvim-docker).

---

## Features

### Java Development

JDTLS is started per project rather than per editor session, with its workspace
keyed to the project root, so two checkouts of the same repository never share
state.

- **Project detection** — Maven and Gradle roots (`pom.xml`, `build.gradle`, wrappers) with a Git fallback
- **Navigation** — go to definition, references, implementations, type definitions
- **Refactoring** — extract method, variable and constant; organize imports
- **Code lenses** — reference and implementation counts, refreshed as you edit
- **Formatting** — Eclipse formatter driven by the bundled `java-style.xml`
- **Lombok** — `lombok.jar` is fetched on first use and attached as a `-javaagent`
- **Decompiled sources** — navigation works into dependencies without attached sources
- **Heap limits** — JDTLS JVM sizing is configurable, so large projects can be given more room

### Debugging and Testing

Full DAP support, wired to the Java debug adapter and test runner:

- Breakpoints, stepping, watches, scopes, stack frames and a REPL
- A dedicated DAP UI layout that opens on session start and closes on exit
- Run a single test method or an entire test class
- Spring Boot main classes are launched with the `local` profile active
- A ready-made **Attach to remote JVM :5005** configuration for debugging running services

### Build Tools

Maven and Gradle tasks run in an embedded terminal without leaving the editor —
compile, test, package, install, deploy, clean, dependency refresh, and local
repository purge.

### Startup and Feedback

Every plugin declares when it is needed, so nothing is loaded speculatively.
Telescope, DAP, the terminal and the formatter only appear once you reach for
them, and `nvim --startuptime` reports roughly **40 ms** to a usable editor.

Because work happens on demand, a small indicator in the bottom-right corner
reports what is going on:

- **Plugin loads** — which plugin was pulled in, how long it took, and what triggered it
- **LSP progress** — live progress with a spinner, which matters most for JDTLS, whose initial project indexing can run for half a minute

The indicator can be narrowed to one source or turned off entirely in
`properties.lua`.

### Language Servers

Mason manages the toolchain, and installed servers are enabled automatically with
shared defaults — completion capabilities, breadcrumbs and code lenses are applied
once, centrally, rather than repeated per server.

Out of the box: **Java**, **Lua**, **JSON**, **YAML**, **Dockerfile**, **Markdown**
and **XML**. XML is served from a pre-compiled LemMinX build, which avoids the slow
first-run download the Mason package performs.

A Spring Boot server can be layered on top of JDTLS as an opt-in extra — see
[Spring Boot](#spring-boot).

### Completion

`nvim-cmp` with LSP, buffer, path, command-line and LuaSnip sources, rendered with
type icons. Java snippet entries are filtered out of the LSP source, since JDTLS
duplicates most of them as regular completions.

### Search and Replace

- **Telescope** — files, live grep, buffers, help, keymaps, highlights, commands, registers, man pages
- **grug-far** — project-wide find and replace with live preview and full regular expressions; can be scoped to the current file, seeded from the word under the cursor, or driven from a visual selection
- **File history** — every save is journalled into a separate Git repository, so previous versions of a file can be browsed and restored independently of project history

### Git Integration

Gitsigns provides hunk signs, staging, resetting, blame and diff views. Hunk
markers are mirrored into the scrollbar, so changes elsewhere in a long file stay
visible. Branch and change counts are shown in the statusline, and Telescope
covers branches, commits and per-file history.

### User Interface

- **Darcula** — JetBrains-inspired colorscheme, with optional transparency that survives colorscheme switching
- **Breadcrumbs** — the current class/method path is shown in the winbar
- **Statusline** — Git branch, diagnostics, active language servers and formatters, AI provider, clock
- **Buffer bar** — open buffers with diagnostic counts and an explorer offset
- **Dashboard** — a start screen with quick access to files, projects and recent work
- **Diagnostics** — icons in the sign column, bordered floats, and both document- and workspace-wide lists

### Terminals

Three toggleable layouts — floating, vertical and horizontal — reusing persistent
terminal instances, so a session keeps its state and size between toggles. The
shell is chosen per operating system from `properties.lua`. Build-tool tasks reuse
the horizontal terminal instead of spawning a new one.

### File Explorer and Projects

nvim-tree provides the file tree, with type icons, Git status, diagnostics,
file operations and a window picker for opening into splits. The tree follows the
active buffer and keeps its root in step with the current project.

Projects are detected automatically from version control and build files, and
recent projects are reachable through Telescope.

### Editing

Treesitter-based highlighting and indentation with incremental selection,
comment toggling that follows the language, indentation guides, TODO comment
highlighting, and a live Markdown preview.

### Discoverable Keys

There is no cheatsheet to memorise. Press the leader key (`Space`) and which-key
shows every available binding, grouped and labelled with icons; groups expand as
you type. Java, debugging and build-tool menus appear only in the buffers where
they apply.

To search bindings as text instead, use Telescope's keymap picker.

---

## Troubleshooting

### LSP not working for Java files

1. Confirm JDTLS is installed: `:Mason`
2. Check active clients: `:LspInfo`
3. Read the log: `~/.local/state/nvim/lsp.log`
4. Verify the JDK: `java --version`
5. Watch the activity indicator — JDTLS reports its indexing progress there

### A language server is missing

Language servers are **not** installed automatically when you open an unfamiliar
file type. Install what you need explicitly:

```vim
:Mason                  " browse and install interactively
:MasonToolsInstall      " install everything this config declares
```

### Spring Boot completions not appearing

Check the toggle and the server package first:

```vim
:JvimSpringStatus       " must report On for the current session, package installed
:MasonInstall vscode-spring-boot-tools
:checkhealth lsp        " expect two clients on a Java buffer: jdtls and spring-boot
```

Enabling the feature only takes effect after a restart. If both clients are
attached but query methods still do not complete, JDTLS is most likely still
indexing — the Spring server resolves entity fields through it, and returns
nothing until the project is built. Watch the activity indicator in the
bottom-right corner and retry once it clears.

### Copilot not providing suggestions

1. Confirm Copilot is the active provider: `:JvimAiStatus`
2. Check authentication: `:Copilot status`
3. Re-authenticate: `:Copilot setup`

### Plugins not loading

```vim
:Lazy update
:Lazy sync
:Lazy log
:Lazy clean
```

Plugins are lazy-loaded, so a plugin showing as "not loaded" in `:Lazy` is
usually correct — it will load when its trigger fires.

### Terminal not opening

1. `:checkhealth toggleterm`
2. Verify the shell exists: `echo $SHELL`
3. Check the `shell` block in `properties.lua` matches your system

### Mason tools not installing

1. Check network connectivity
2. Ensure `curl`, `git` and `unzip` are available
3. Review the Mason log from the `:Mason` UI
4. Install manually: `:MasonInstall <tool-name>`

### Tracing the configuration itself

Set `logger.enabled = true` in `properties-local.lua` to make the config report
its own startup, then read the output with `:messages`.

### Getting Help

```vim
:checkhealth
:Lazy
:messages
```

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
