# AGENTS.md

NixOS infrastructure repository using the **dendritic pattern** with **flake-parts**. Every `.nix` file except `flake.nix` is a top-level flake-parts module. Lower-level NixOS/Home Manager modules are *values defined inside* these top-level modules, not standalone files.

## Build & Verify

```bash
# Check the full flake evaluates
nix flake check

# Build a specific host without deploying
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Deploy to a host (uses deploy-rs, NOT nixos-rebuild)
nix run .#deploy -- .#<hostname>

# Evaluate a single attribute to check for errors
nix eval .#nixosConfigurations.<hostname>.config.<option> --json

# Format all nix files (alejandra)
nix fmt

# Enter dev shell (includes claude-code)
nix develop

# Build a package
nix build .#<package>

# Run a package without installing
nix run .#<package>
```

## Architecture

### Dendritic Pattern

Code is organized **by feature, not by host**. A feature file defines configuration across all classes it applies to. Hosts compose features via imports.

```
# Traditional (DON'T):  host -> lists everything it needs
# Dendritic (DO):       feature -> defines config for all classes -> hosts import it
```

### Configuration Classes

Values live under `flake.modules.<class>.<name>`:

- `nixos` — NixOS system modules
- `homeManager` — Home Manager user modules
- `generic` — cross-class modules (constants)

### File Layout

```
flake.nix                          # hand-written, inputs declared directly
modules/
  flake-parts/                     # flake-parts bootstrap, devShells, formatter
  lib.nix                          # mkNixos, mkHomeManager, allowPkgs
  constants.nix                    # generic class constants
  factory/                         # factory option definition + user factory
  profiles/                        # inheritance chain (see below)
    desktop/                       # desktop + kde profiles
  hosts/
    framework/                     # laptop: configuration, hardware, per-host users
    floodgate/                     # VPS: configuration, hardware, disks, per-host users
  users/                           # per-user definitions (factory usage + HM imports)
  services/                        # service features (ssh, tailscale, caddy, minecraft, etc.)
  programs/                        # program features (git, zsh, nixvim, sops, 1password)
  nixos/                           # NixOS-specific (networking, bootloaders, deployment, VMs)
```

All files under `modules/` are auto-imported by `import-tree`. The module system merges all contributions to the same `flake.modules.<class>.<name>` automatically.

### Profile Hierarchy

Hosts pick an entry point. Each level imports the previous. Both `nixos` and `homeManager` classes have parallel profile chains:

```
profile-minimal  ->  profile-default  ->  profile-cli  ->  profile-server
                                                       ->  profile-desktop  ->  profile-kde
```

- `profile-minimal` — locale, timezone, unfree, latest kernel
- `profile-default` — adds home-manager, networking, sops, test-vm
- `profile-cli` — adds 1password, ssh, tailscale, yubikey, zsh, firmware
- `profile-server` — adds yubikey-server, deployment (deploy-rs user/config)
- `profile-desktop` — adds 1password-gui, yubikey-desktop, firefox, printing, audio, fonts
- `profile-kde` — adds SDDM, Plasma 6

### Secrets

In-repo model using `sops-nix` with age keys. Secrets stored under `secrets/`:

```
secrets/
  hosts/framework.yaml             # per-host NixOS secrets
  hosts/floodgate.yaml
  users/matt.yaml                  # per-user Home Manager secrets
  services/minecraft.yaml          # per-service secrets
```

Key configuration in `.sops.yaml`. NixOS modules decrypt via host SSH key (`/etc/ssh/ssh_host_ed25519_key`). Home Manager modules decrypt via user key (`~/.ssh/id_ed25519_sops`).

### Deployment

Uses `deploy-rs`. Deploys over SSH as a `deploy` user with passwordless sudo. Only hosts with a `deploy` user get deploy nodes (auto-detected via `lib.filterAttrs`). Hosts are connected via Tailscale.

## Code Conventions

### Always

- Every `.nix` file (except `flake.nix`) is a flake-parts top-level module.
- Use `flake.modules.<class>.<name>` to define lower-level module values.
- Use `lib.mkMerge` to combine attribute sets in module code.
- Use `lib.mkIf` for conditional content inside modules.
- Use proper Nix module options over `extraConfig`/`initExtra` escape hatches.
- Split large features across multiple files — `import-tree` handles merging.
- Prefix disabled/WIP files or directories with `_` so `import-tree` ignores them.
- Format with `alejandra` (configured as `nix fmt`).
- Commit messages: `<scope>: summary` (e.g. `framework: add wireless`, `nixvim: update keymaps`, `floodgate: fix caddy config`).
- Run `nix fmt` and `nix flake check` before committing.

### Never

- **Never use `specialArgs` or `extraSpecialArgs`.** Define shared values as top-level flake-parts options and read them via `config`.
- **Never use `//` (attribute merge operator) to combine module config.** Use `lib.mkMerge`.
- **Never put `lib.mkIf` inside `imports = [...]`.** Make the module content conditional, not the import list.
- **Never set options to their existing defaults.** Redundant config is noise.
- **Never use conditional imports.** The module system evaluates all imports; use `lib.mkIf` on config values instead.

### Ask First

- Adding new flake inputs (affects lock file and all downstream builds).
- Changing `system.stateVersion` or `home.stateVersion` on any host.
- Modifying the profile hierarchy (`profile-minimal` through `profile-kde`).
- Touching secrets paths or sops configuration.
- Any changes to the factory functions in `modules/factory/`.

## Coding Style

- 2-space indentation, no tabs.
- Pin sources with hashes; no network access at build time.

## Key Patterns

### Host Assembly

```nix
# modules/hosts/framework/configuration.nix
{self, ...}: {
  flake.modules.nixos.framework = {
    imports = with self.modules.nixos; [
      profile-kde            # picks profile level
      wireless               # opt-in features
      limine
    ];
    home-manager.sharedModules = with self.modules.homeManager; [
      profile-kde            # parallel HM profile
    ];
    system.stateVersion = "25.05";
  };

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework";
}
```

### User Factory

```nix
# modules/users/matt/matt.nix
{self, lib, ...}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "matt" true)    # generates nixos + homeManager aspects
    {
      nixos.matt = { /* extensions like SSH keys */ };
      homeManager.matt = {
        imports = with self.modules.homeManager; [ nixvim zsh git ];
      };
    }
  ];
  flake.homeConfigurations = self.lib.mkHomeManager "x86_64-linux" "matt";
}
```

### Feature Module (Dendritic)

```nix
# A feature defines aspects for each class it touches
{inputs, ...}: {
  flake.modules.nixos.sops = {config, ...}: {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.defaultSopsFile = ../../secrets/hosts/${config.networking.hostName}.yaml;
  };

  flake.modules.homeManager.sops = {config, pkgs, ...}: {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];
    sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519_sops"];
    sops.defaultSopsFile = ../../secrets/users/${config.home.username}.yaml;
  };
}
```

### Accessing Shared Values

```nix
# Define a top-level option, read it anywhere via config
{lib, ...}: {
  options.myConstant = lib.mkOption { type = lib.types.str; default = "value"; };
}
# In another file:
{config, ...}: {
  flake.modules.nixos.myhost = {
    some.setting = config.myConstant;
  };
}
```

### Builder Functions

`flake.lib` holds `mkNixos`, `mkHomeManager`, and `allowPkgs`. Access via `self.lib.*` or `inputs.self.lib.*`.

`flake.factory` holds factory functions. Access via `self.factory.*`.

## Packaging

When packaging custom software, follow these conventions:

### Builders

Prefer standard builders: `buildNpmPackage`, `rustPlatform.buildRustPackage`, `buildGoModule`, `stdenv.mkDerivation`.

### Metadata

Every package needs a `meta` block:

```nix
meta = with lib; {
  description = "Clear, concise description";
  homepage = "https://project-homepage.com";
  license = licenses.mit;
  mainProgram = "binary-name";
  platforms = platforms.all;
};
```

### Updates

Prefer `nix-update` for version bumps. Keep version and hash attributes inline in the derivation (not loaded from JSON) so `nix-update` can find and update them.

### Install Checks

Use `versionCheckHook` to verify packages report correct versions:

```nix
doInstallCheck = true;
nativeInstallCheckInputs = [ versionCheckHook ];
```

### Common Issues

- **Rust git dependencies**: May fail during cargo vendoring with workspace inheritance issues. Consider pre-built binaries as a workaround.
- **Binary packages**: Use `autoPatchelfHook` on Linux to handle dynamic library dependencies. Common missing library: `gcc-unwrapped.lib` for `libgcc_s.so.1`.
- **Single executables**: Use `dontUnpack = true` when the download is a single executable file.

## Gotchas

- **Two scopes**: Inside a flake-parts module, `config` is the top-level flake-parts config. Inside a value assigned to `flake.modules.nixos.foo`, arguments like `config` and `pkgs` refer to the NixOS-level evaluation. Don't confuse them.
- **`self` vs `inputs.self`**: At the flake-parts top level, use `self` (from module args). Inside lower-level module values, use `inputs.self` if you need flake self-reference — but prefer passing things through the module system instead.
- **The `generic` class** is the cross-class sharing mechanism. `constants.nix` defines a `generic` aspect importable by any class.
- **`home-manager.sharedModules`**: Hosts set HM profile levels via `home-manager.sharedModules` in their NixOS module, separate from the NixOS profile import.
