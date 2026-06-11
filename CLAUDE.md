# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal fork of [dwl](https://codeberg.org/dwl/dwl) (dwm for Wayland, a wlroots-based compositor) customized for the user's machine and built with Nix. The upstream is a single C source file configured at compile time via `config.h`; this fork keeps that model and layers on machine-specific config plus a Nix build. Commits and comments are written in French.

## Building

The project is built with Nix (the system `wlroots` is not used directly):

```sh
nix build              # produces ./result -> dwl binary
nix run                # build and launch dwl
nix develop            # dev shell with all deps, then `make`
```

`flake.nix` pins `nixpkgs/nixos-26.05` and builds against `wlroots_0_19` (dwl 0.8). `src = ./.` so the local tree (including your edited `config.def.h`) is what gets compiled — the commented-out `fetchFromGitea` block is the alternative for building a pristine upstream tag.

The raw upstream build also works inside the dev shell: `make` (and `make clean`). `config.mk` expects `wlroots-0.19` via pkg-config. XWayland is off by default — uncomment its flags in `config.mk` to enable.

There is no test suite. Verification is launching dwl and exercising it.

## Configuration model

- `config.def.h` is the **tracked** config; `config.h` is git-ignored and is `cp`'d from `config.def.h` by the Makefile if missing. In this repo, real changes go into `config.def.h` (the Nix build compiles the tree directly, so editing `config.def.h` is what takes effect). There is no runtime config — every change requires a rebuild and a full restart of dwl.
- After editing config, rebuild with `nix build` (or `make`).

## Focus-color theming (the one non-trivial mechanism)

The window focus border color is **not** hardcoded. The chain is:

1. `~/.config/dwl/theme.sh` (outside this repo) defines `focuscolor` as a hex string.
2. `gen-color.sh` sources that file and regenerates `color.h` with `#define FOCUS_COLOR_HEX 0x<hex>FF`.
3. `config.def.h` does `#include "color.h"` and sets `focuscolor[] = COLOR(FOCUS_COLOR_HEX)`.

`color.h` is committed but is marked "generated — do not edit manually." To change the focus color, edit `theme.sh` and run `./gen-color.sh`, then rebuild.

## Key customizations vs. upstream dwl

These live in `config.def.h` and are the things most likely to matter when editing:

- **Keyboard**: French `ergol` layout (`xkb_rules.layout = "fr"`, `.variant = "ergol"`).
- **Modifiers**: `MODKEY` = Super/Logo (window management); `ALTKEY` = Alt (launching apps). Note the ergol layout means letter keys map to non-QWERTY positions, so keybind letters (`r`/`t` for focusstack, `w`/`f`/`b` for tile/float/monocle layouts, etc.) reflect physical ergol positions.
- **Spawned via external scripts** in `~/.config/dwl/`: `passmenu.sh` (Super+p), `appmenu.sh` (Super+a), `sysmenu.sh` (Super+s), `zwift.sh` (Alt+z). App launchers: `foot` terminal (Alt+t), a vimwiki/notes foot session (Alt+i), `firefox` (Alt+r).
- **Media keys**: volume/mic via `wpctl`, brightness via `brightnessctl`. The `XF86XK_*` keysyms are `#define`d manually at the top of `config.def.h` to avoid an X11 header dependency.
- **Gaps** enabled (`gaps`, `gappx = 10`) — from `patches/gaps.patch`.
- **Layouts**: tile `[]=`, float `><>`, monocle `[M]`.

## Patches directory

`patches/` holds the upstream patch sources (`bar.patch`, `gaps.patch`) that have been applied to this tree, kept for reference. They are already integrated into `dwl.c`/`config.def.h`; you generally edit the source directly rather than re-applying patches.

## Core source files

- `dwl.c` — the entire compositor (~105 KB, single file). Edit here for behavior changes.
- `client.h` — abstraction layer over XDG-shell vs. XWayland clients.
- `util.c` / `util.h` — small helpers (`die`, `ecalloc`).
- `protocols/` — Wayland protocol XML; `Makefile` runs `wayland-scanner` to generate `*-protocol.h` headers at build time.
