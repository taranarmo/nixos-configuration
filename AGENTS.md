# AGENTS.md

This file provides essential information for AI coding agents (like Cursor, Copilot, or Antigravity) operating in this repository.

## 1. Build, Lint, and Test Commands

### Build & Switch
The configuration is Flake-based. Use `nixos-rebuild` to apply changes.
- **Build configuration:** `nixos-rebuild build --flake .#<host>` (where `<host>` is `nixos-ideapad` or `hp-gaming`)
- **Switch to configuration:** `sudo nixos-rebuild switch --flake .#<host>`
- **Build Home Manager only:** `home-manager build --flake .`
- **Switch Home Manager only:** `home-manager switch --flake .`
- **Build specific output:** `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`

### Update
- **Update all flake inputs:** `nix flake update`
- **Update to latest cached nixpkgs:** `./update-to-latest-cached-nixpkgs.sh`
  *This script fetches the latest revision from the nixos-unstable channel that has passed binary cache checks, avoiding long local recompilations.*

### Lint & Format
- **Format all Nix files:** `nixfmt .` or `nixfmt-tree .`
- **Check flake for errors:** `nix flake check`
- **Syntax check only:** `nix-instantiate --parse <file>`
- **Show configuration options:** `man configuration.nix` or search online at https://search.nixos.org/options

### Running Tests
This repository currently does not contain standard unit tests or NixOS VM tests.
- **Dry-run build:** `nixos-rebuild dry-build --flake .#<host>`
- **Trace evaluation:** Use `--show-trace` with any nix command to debug evaluation errors.

## 2. Code Style Guidelines

### General Principles
- **Modularity:** Keep files small and focused. Use `imports` extensively to compose configurations.
- **Reproducibility:** All dependencies should be managed via `flake.nix` inputs.
- **Declarative:** Prefer declarative options over `extraConfig` or shell scripts where possible.
- **Theming:** Use `stylix` and `catppuccin` for system-wide and application-specific theming (Mocha flavor).

### Nix Formatting & Imports
- **Indentation:** 2 spaces.
- **Imports:** Always use relative paths (e.g., `./modules/nixos/base.nix`).
- **Grouping:** Group related imports together. Common system-wide imports go in `configuration.nix`.
- **Argument Pattern:** Standard module header:
  ```nix
  { config, lib, pkgs, inputs, ... }:
  ```
- **Trailing Commas:** Prefer trailing commas in multi-line attribute sets and lists for cleaner git diffs.

### Naming Conventions
- **Files:** Use kebab-case for filenames (e.g., `system-services.nix`).
- **Directories:** Use kebab-case for directory names.
- **Variables:** Use camelCase for internal variables within Nix expressions.
- **Options:** Use kebab-case for custom NixOS options (if defined).

### Types and Structure
- **NixOS Modules:** System-level settings in `modules/nixos/`.
- **Home Manager Modules:** User-level settings in `modules/home-manager/`.
- **Host Configurations:** Hardware and host-specific settings in `hosts/`.
- **Hardware-specific:** Bootloader, kernel modules, and file systems go into `hosts/<host>.nix`.

## 3. Project Structure & Module Layout

### Key Files
- `flake.nix`: The source of truth. Defines inputs and system outputs.
- `configuration.nix`: The entry point for shared NixOS configuration.
- `home/home.nix`: The entry point for shared Home Manager configuration.
- `caches.nix`: Global binary cache settings (imports all caches from `caches/`).

### Host Roles
- `nixos-ideapad`: Lenovo laptop, Intel graphics, power management optimized (powersave).
- `hp-gaming`: Desktop gaming PC, Nvidia proprietary drivers, CUDA support, gaming optimizations.

## 4. Specific Component Rules

### Neovim (Nixvim)
- Managed via `modules/home-manager/nixvim.nix`.
- Plugins include: `lualine`, `fzf-lua`, `commentary`, `fugitive`, `which-key`, `cmp`, `lsp`.
- LSP servers: `nixd`, `pyright`, `terraformls`, `yamlls`, `jsonls`.
- Notebook support: `notebook-navigator`, `iron`, `jupytext`.

### Desktop & UI (Hyprland)
- Managed in `modules/home-manager/hyprland.nix`.
- Tooling: `waybar`, `hyprlock`, `hypridle`, `wofi`, `grimblast`.
- Theming is handled by Stylix; avoid hardcoding hex colors.

### Development Environments
- Common tools: `git`, `gcc`, `cmake`, `gnumake`, `jq`, `ripgrep`, `fzf`, `gh`.
- Python: Managed via `python3.withPackages` in `development.nix`. Includes `numpy`, `pandas`, `scipy`, `torch`, `tensorflow`, `transformers`, `jupyter`.
- Infrastructure: `terraform`, `awscli2`, `aws-vault`.

### Multimedia & Audio
- Audio is managed via Pipewire (configured in `modules/nixos/multimedia.nix`).
- Packages: `pwvucontrol`, `helvum` (patchbay), `pulseaudio` (utils).

### Security & Secrets
- `polkit` enabled for privilege escalation.
- `gpg-agent` with `pinentry-tty` for secret management.
- `pass` (Password Store) with OTP and file extensions.

### LLM Agents & Sandbox (`agent-box`)
- Managed in `modules/home-manager/agents/`.
- Available agents: `agy` (Antigravity CLI), `claude-code`, `opencode`, `rtk`.
- **Sandbox execution (`agent-box` / `agent-sandbox`)**: Runs agents inside a Bubblewrap container with access strictly restricted to the project directory and Nix (store + daemon socket).
- **Security**: Host `$HOME` (`~/.ssh`, `~/.aws`, personal dotfiles) is cloaked via `tmpfs`.
- **Auth Tokens**: Cloud/dev credentials are passed via environment variables (e.g. `GH_TOKEN=$(gh auth token) agent-box claude` or `aws-vault exec <profile> -- agent-box claude`).
- **Documentation**: See [`modules/home-manager/agents/README.md`](modules/home-manager/agents/README.md) for complete details.

## 5. Agentic Workflow Instructions

### Before Making Changes
1. **Identify Target:** Determine if the change is system-wide (NixOS) or user-specific (Home Manager).
2. **Locate Module:** Find the most relevant module or create a new one if it's a distinct feature.
3. **Check Inputs:** Verify if any new flake inputs are required (update `flake.nix` if so).

### Applying Changes
1. Edit the relevant `.nix` file.
2. Run `nixos-rebuild build --flake .#<host>` to verify the change evaluates and builds.
3. If successful, run `sudo nixos-rebuild switch --flake .#<host>`.

### Common Operations
- **Garbage Collection:** `nix-env --delete-generations old` and `nix-store --gc`.
- **Store Optimization:** `nix-store --optimise`.
- **Checking logs:** `journalctl -xe` or `systemctl status <service>`.

### Troubleshooting
- **Conflict with Determinate Nix:** Some `nix.*` options conflict with the `determinate` module.
- **SSL/SSH Issues:** See `modules/nixos/base.nix` for the `NIX_SSL_CERT_FILE` workaround.
- **HM Backups:** HM uses `backupFileExtension = "hmbackup"` to prevent collisions.

---
*This configuration is optimized for a Wayland/Hyprland environment with a focus on reproducibility and modularity.*
