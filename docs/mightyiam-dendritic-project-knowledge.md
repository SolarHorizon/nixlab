# Project Knowledge: mightyiam/dendritic

**Source:** https://github.com/mightyiam/dendritic
**Author:** Shahar "Dawn" Or (@mightyiam)
**Purpose:** The original definition and annotated example of the Dendritic Pattern — a Nixpkgs module system usage pattern for structuring Nix configurations.

---

## What This Repo Is

The canonical definition of the Dendritic Pattern, written by its author. It contains:

- A `README.md` with the formal pattern definition, motivation, benefits, anti-patterns, and links to real-world adoptions
- An `example/` directory with a minimal but annotated working example

This is the *origin* repo. Doc-Steve's guide (see separate project knowledge) is the extended practical guide built on top of it. When the two differ in emphasis, this repo's definitions take precedence for correctness.

---

## The Pattern — Formal Definition

### Core Statement

> In the dendritic pattern every Nix file except for entry points such as `default.nix` and `flake.nix` is a module of the top-level configuration.

Every non-entry-point file is a Nixpkgs module system module imported directly into the top-level configuration evaluation. Additionally, every top-level module:

1. **Implements a single feature**
2. **...across all configurations that feature applies to**
3. **Is at a path that serves to name that feature**

### The Top-Level Configuration

The pattern introduces a *top-level configuration* (usually a flake-parts configuration) that wraps lower-level configurations (NixOS, home-manager, nix-darwin). Lower-level modules are stored as option values — typically using `deferredModule` type — inside this top-level configuration, which gives them value merge semantics.

flake-parts exposes this via [`flake.modules`](https://flake.parts/options/flake-parts-modules.html).

The top-level configuration does **not** have to be flake-parts. Alternatives include using `lib.evalModules` directly, or `vic/dendritic-unflake` for non-flake setups.

### Background — Why It Exists

Managing multi-configuration Nix codebases runs into several compounding problems:

- Multiple configurations
- Sharing modules across configurations
- Multiple configuration classes (`nixos`, `home-manager`, etc.)
- Configuration nesting (home-manager within NixOS, within nix-darwin)
- Cross-cutting concerns spanning multiple classes
- Accessing values (functions, constants, packages) across files

The dendritic pattern addresses all of these by making every file a top-level module. Top-level modules can both contribute to and read from the top-level `config`, making cross-file value sharing trivial.

---

## Benefits

### Type of Every File Is Known

The common question "what's in that Nix file?" becomes irrelevant. Every non-entry-point file contains a Nixpkgs module system module of the same class as the top-level configuration. No guessing whether a file is a NixOS module, a helper, a package, or something else.

### Automatic Importing

Since all non-entry-point files are top-level modules and their paths convey meaning only to the author, they can all be automatically imported using a trivial expression or `vic/import-tree`. No manual import lists to maintain.

### File Path Independence

In traditional patterns, file paths often carry semantic meaning — the type of expression a file contains, or which configuration it belongs to. In the dendritic pattern, **a file path represents a feature**. Each file can be freely renamed, moved, or split when it grows too large, with no other impact than the capabilities provided to the system.

---

## Anti-Patterns

### `specialArgs` Pass-Through

In non-dendritic configs, files that are lower-level modules (NixOS, home-manager) often need values defined outside their evaluation — a package defined elsewhere, a constant, a function. These are typically passed in via `specialArgs` (or `extraSpecialArgs` for nested home-manager). This creates tight coupling and indirection.

**The dendritic solution:** since every file is a top-level module, every file can *add* values to the top-level `config` and *read* values from it. Sharing values between files requires no injection machinery — it's just reading from the shared top-level config.

**Example of the problem:**
```nix
# Non-dendritic: scripts/foo.nix defines a package
# nixos/laptop.nix needs it → passed via specialArgs → passed again via extraSpecialArgs into HM
```

**Dendritic approach:** `scripts/foo.nix` defines a top-level option value. `nixos/laptop.nix` reads it from `config`. No `specialArgs` needed.

---

## The Example (`example/`)

The example is explicitly incomplete and does not prescribe a particular file tree layout. Its purpose is to annotate and demonstrate the pattern mechanics.

### `flake.nix` — Entry point

```nix
# In this example the top-level configuration is a flake-parts one.
# Therefore, every Nix file (other than this) is a flake-parts module.
{
  inputs = {
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/25.11";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      # Imports all of the top-level modules (files under ./modules)
      (inputs.import-tree ./modules);
}
```

The entire output logic is a single call to `import-tree ./modules`. Every file in `modules/` is automatically loaded as a flake-parts module.

### `modules/flake-parts.nix` — Enables `flake.modules`

```nix
{ inputs, ... }: {
  imports = [
    # https://flake.parts/options/flake-parts-modules.html
    inputs.flake-parts.flakeModules.modules
  ];
}
```

This one import is what enables the `flake.modules.<class>.<name>` option tree across all other modules.

### `modules/systems.nix` — Declares target systems

```nix
{
  systems = [ "x86_64-linux" "aarch64-linux" ];
}
```

A plain flake-parts module. No lower-level aspect, just a flake-level setting.

### `modules/meta.nix` — Declares a top-level shared option

```nix
# Declares a top-level option that is used in other modules.
{ lib, ... }: {
  options.username = lib.mkOption {
    type = lib.types.singleLineStr;
    readOnly = true;
    default = "iam";
  };
}
```

This is the canonical demonstration of cross-file value sharing. `username` is defined once at the top-level and consumed by any module that needs it via `config.username` — no `specialArgs` required. The option is `readOnly` to make it a constant.

### `modules/nixos.nix` — Declares a custom option for NixOS configurations

```nix
# Provides an option for declaring NixOS configurations.
# These configurations end up as flake outputs under `#nixosConfigurations."<n>"`.
# A check for the toplevel derivation of each configuration also ends
# under `#checks.<s>."configurations:nixos:<n>"`.
{ lib, config, ... }: {
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.configurations.nixos (
      name: { module }: lib.nixosSystem { modules = [ module ]; }
    );

    checks =
      config.flake.nixosConfigurations
      |> lib.mapAttrsToList (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "configurations:nixos:${name}" = nixos.config.system.build.toplevel;
          };
        }
      )
      |> lib.mkMerge;
  };
}
```

Key observations:
- Uses `deferredModule` type, which gives merge semantics — multiple files can contribute to the same configuration
- Automatically derives `flake.checks` from configurations, one check per nixosConfiguration
- Uses the `|>` pipe operator (Nix 2.24+)
- This is a **custom approach** to building nixosConfigurations rather than using helpers like `lib.mkNixos` from Doc-Steve's repo — the pattern is flexible, this is just one way

### `modules/shell.nix` — A cross-cutting feature

```nix
# Default shell for the user across NixOS and Android
{ config, lib, ... }: {
  flake.modules = {
    nixos.pc = nixosArgs: {
      programs.fish.enable = true;
      users.users.${config.username}.shell = nixosArgs.config.programs.fish.package;
    };

    nixOnDroid.base =
      { pkgs, ... }:
      {
        user.shell = lib.getExe pkgs.fish;
      };
  };
}
```

Key observations:
- Uses `config.username` from `meta.nix` — demonstrates cross-file value sharing without `specialArgs`
- Defines aspects for two classes (`nixos` and `nixOnDroid`) in a single file — this is the core of the pattern
- The `nixos.pc` value is a function `nixosArgs: { ... }` rather than an attrset — this is valid module syntax (a module can be a function)
- `nixosArgs.config` is the NixOS-level config (not the flake-parts top-level `config`)

### `modules/admin.nix` — Another cross-cutting feature

```nix
# Provides the user with high permissions cross-platform.
{ config, ... }: {
  flake.modules = {
    nixos.pc = {
      users.groups.wheel.members = [ config.username ];
    };

    darwin.pc.system.primaryUser = config.username;
  };
}
```

Key observations:
- Again reads `config.username` from the top-level config
- Defines both a `nixos` and `darwin` aspect in one file
- `darwin.pc.system.primaryUser = config.username` is shorthand attribute path notation — the module system expands it

### `modules/desktop.nix` — A configuration definition

```nix
# Uses the option in ./nixos.nix to declare a NixOS configuration.
{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in {
  configurations.nixos.desktop.module = {
    imports = [
      nixos.admin
      nixos.shell
      # ...other nixos modules
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
```

Key observations:
- Accesses `config.flake.modules.nixos` at the top-level — this is reading other aspects defined elsewhere
- Sets the `configurations.nixos.desktop.module` option defined in `nixos.nix`
- The module value imports specific named aspects by reading them from the top-level config — this is how host/configuration assembly works in the dendritic pattern
- `deferredModule` merge semantics mean this `module` value can be contributed to by multiple files

---

## Key Design Insights from the Example

### Two Distinct Uses of `config`

Inside a dendritic module, `config` refers to the **top-level** (flake-parts) config. Inside a lower-level module (the value assigned to `flake.modules.nixos.pc`, for example), the argument named `config` (or named differently — `nixosArgs` in `shell.nix`) refers to the **NixOS-level** config. This distinction is important and the example demonstrates it explicitly in `shell.nix`.

### `deferredModule` Is Central

The `configurations.nixos` option uses `deferredModule` type. This is what makes it possible to have multiple files contribute to the same configuration's module value and have those contributions merged — not overwritten. The Doc-Steve repo uses `flake.modules` (which flake-parts provides using `deferredModule` internally) for the same reason.

### Configurations as Options, Not Direct Outputs

Rather than calling `lib.nixosSystem` directly in each module, the example defines a *custom option* (`configurations.nixos`) to accumulate configuration declarations, then derives `flake.nixosConfigurations` from it in one place. This is more flexible than the simpler `lib.mkNixos` helper in Doc-Steve's repo — it also auto-derives CI checks.

### Named Modules Are Not Required

The example note in `mightyiam/infra` (linked in the README) makes an important point: named modules (`flake.modules.nixos.fonts`, `flake.modules.nixos.audio`) should only be created when that set of option values needs to be imported in *some* configurations and not others. If every configuration would import it anyway, it's often cleaner to just define `flake.modules.nixos.pc` directly in the relevant file rather than creating a separately named module.

---

## Required Skills

The README explicitly lists what you need to know before using this pattern:

- [Nix language](https://nix.dev/tutorials/nix-language)
- [Nixpkgs module system](https://nix.dev/tutorials/module-system/)
- [`deferredModule` type](https://nixos.org/manual/nixos/stable/#sec-option-types-submodule)

---

## Real-World Adoptions (from README)

- **mightyiam/infra** — the author's own config, where the pattern was originally discovered
- **vic/vix** — Victor Borja's personal config (same @vic who wrote `import-tree` and `flake-file`)
- **drupol/nixos-x260** — Pol Dellaiera's config, with an accompanying blog post on the migration

---

## Related Tools and Resources

- **`vic/import-tree`** — auto-imports all `.nix` files in a directory tree; the standard companion tool
- **`vic/den`** — aspect-oriented dendritic framework built on top of the pattern
- **`vic/dendritic-unflake`** — non-flake, non-flake-parts examples of the pattern
- **`Doc-Steve/dendritic-design-with-flake-parts`** — the extended practical guide (see separate project knowledge)
- **`vic/dendrix`** — community-driven distribution of dendritic Nix configurations
- **Community:** GitHub Discussions at mightyiam/dendritic, Matrix `#dendritic:matrix.org`

---

## Notes for AI Assistant

- This repo is the **origin definition** of the dendritic pattern. Doc-Steve's guide is a practical extension — defer to this repo for authoritative definitions of the pattern itself.
- The example is intentionally minimal and does **not** prescribe file tree layout. It demonstrates mechanics, not conventions.
- The `configurations.nixos` custom option approach (in `nixos.nix`) is one valid way to build `nixosConfigurations`. Doc-Steve's `lib.mkNixos` helper is another. Neither is more "correct."
- `specialArgs` and `extraSpecialArgs` are explicitly called out as anti-patterns. The alternative is always: define values as top-level options and read them via `config`.
- Named modules (`flake.modules.nixos.foo`) should only be created if that set of config will be imported in *some* configurations but not all. If it applies everywhere, just write it directly to a broader named module (e.g. `flake.modules.nixos.pc`).
- The pattern does **not** require flake-parts. It only requires a top-level module system evaluation. flake-parts is the most common choice.
- `deferredModule` type is what enables merge semantics for lower-level modules. Understanding why this is used is key to understanding the pattern.
- The `nixOnDroid` class in `shell.nix` shows the pattern is not limited to nixos/darwin/homeManager — any module class can be used.
