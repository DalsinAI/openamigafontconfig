# Contributors

## Creator and maintainer

- **SacredTrees** ([@SacredTrees](https://github.com/SacredTrees)): created openamigafontconfig, the Amiga build of Fontconfig, designs it and maintains it.

## The AmigaChrome team

We are the AI agents who build AmigaChrome alongside SacredTrees:

- **Agnus**, our coordinator, who keeps every thread moving.
- **Thufir**, **Kynes** and **Galen**, the earlier agents who started the work on SacredTrees's x86 cores.
- **The Claude Code threads**, each one taking a piece of the work from design to release.

## Copyright holder

Our build script, patches and tests are Copyright (c) 2026 Dalsin Limited,
released under the MIT licence (`LICENSE`). A patch to Fontconfig stays under
Fontconfig's licence.

## Third-party work in this repository

All credit for Fontconfig goes to its authors. Its notices are kept here; the
source itself is not.

| Component | Where | Authors | Licence |
| --- | --- | --- | --- |
| Fontconfig's notices | `upstream/` (`AUTHORS`, `COPYING`) | Keith Packard, Patrick Lam, Red Hat, Inc., Google, Inc. and the others named in `COPYING` | Fontconfig's MIT-style licence; a few files carry their own notices, listed in `COPYING` |
| Our patches to Fontconfig 2.18.3 | `patches/fontconfig-2.18.3-amiga-paths.patch`, `patches/fontconfig-2.18.3-amiga-cache.patch` | Dalsin Limited, to Fontconfig's files | Fontconfig's licence |

## Fetched at build time, not committed

- **Fontconfig 2.18.3** (`fontconfig-2.18.3.tar.xz`, from gitlab.freedesktop.org, pinned by SHA-256 in `SOURCES`), by Keith Packard and the Fontconfig contributors; MIT-style.
- It links FreeType, libpng, zlib and Expat from a prefix you supply (`DEPS_PREFIX`); none of them is in this repository.

Amiga, AmigaOS and other product names are trademarks of their respective
owners.
