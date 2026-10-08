# openamigafontconfig

Fontconfig for AmigaOS 3.x on 68k, built as static link libraries for
GCC programs. Part of the [OpenAmiga](https://github.com/DalsinAI/openamiga)
ports, made for [OpenBrowser](https://github.com/DalsinAI/openamigabrowser),
the WebKit browser for AmigaOS 3.2.

**Status:** Working: builds, and the smoke test indexes and matches fonts on the bench.

This repository holds the Amiga build, not Fontconfig itself: a build script,
patches, a smoke test and the upstream licences.

## Upstream

| Library | Version | Licence | Home |
| --- | --- | --- | --- |
| Fontconfig | 2.18.3 | MIT-style (upstream/COPYING) | https://www.freedesktop.org/wiki/Software/fontconfig/ |

The exact files and their SHA-256 sums are in [SOURCES](SOURCES). All credit
for the library goes to its authors; see `upstream/` for their notices.

## What the Amiga port changes

- **AmigaDOS names** (`patches/fontconfig-2.18.3-amiga-paths.patch`, in `src/fcstr.c` and `src/fccfg.c`): a name with a volume or assign (`PROGDIR:Fonts`, `DH1:Fonts`) is absolute; joining `PROGDIR:` and `Fonts` gives `PROGDIR:Fonts` with no slash, since a slash after the colon would mean the parent directory; such names are not rewritten as POSIX paths; and a configuration file named with a volume (`PROGDIR:fontconfig/fonts.conf`) is opened as it is, not as `/PROGDIR:...`, which made AmigaDOS ask for a disk called `/PROGDIR`.
- **The font cache** (`patches/fontconfig-2.18.3-amiga-cache.patch`, in `src/fccompat.c` and `src/fcatomic.c`): without it the cache was never saved, so every program start scanned all its fonts again (about 25 seconds for 14 TrueType files on the test instance). libnix's `fcntl()` does not do `F_DUPFD_CLOEXEC`, which made the temporary file fail; the cache is locked with a directory, as libnix has no hard links; and the old cache file is deleted before the new one is renamed over it, which AmigaDOS refuses.
- **Null checks** (`patches/fontconfig-2.18.3-null-checks.patch`, in `src/fcinit.c` and `src/fcxml.c`): when the configuration fails and the built-in fallback cannot be made either (out of memory), `FcInitLoadOwnConfig` returns NULL instead of writing through a NULL fallback; and an `<alias>` whose test rule cannot be allocated reports "out of memory" instead of writing through a NULL rule. On an Amiga address 0 is memory, so such writes would corrupt it; GCC put `TRAP #7` there (Software Failure 80000027). The build also passes `-fno-delete-null-pointer-checks`.
- **libnix gaps:** `getprogname`, `vasprintf` and `mkostemp` are not declared, so the script turns them off in `config.h` and uses `vsnprintf`.
- **libpthread's macros:** `pthread.h` is included first, so its cancellation-point macros don't break FreeType's `stream->read`.

## Building

You need the os32-gcc16 compiler (bebbo's amiga-gcc on GCC 16.2 with libnix
and libpthread; see DalsinAI/openamigabrowser `stove/`) and the upstream
tarballs from [SOURCES](SOURCES) in `tarballs/`. Then:

```
./build.sh
```

The libraries and headers land in `out/` (set `PREFIX` to change that). The
script prints which other settings it needs, if any. Target: 68020 or better
with an FPU (`-m68020 -m68881`), libnix (`-mcrt=nix20`).

Link with: `-lfontconfig -lfreetype -lexpat -lpng -lz -lpthread -lm`

## Tested

`tests/fctest.c`, run on AmigaOS 3.2.3 on AmigaChrome's AC090 emulation (68040 with FPU, 256 MB), Instance-24, 4 October 2026, as `fctest DH1:OBFonts`:

```
FONTCONFIG 21803 add_dir=1
fonts=14
match 'Liberation Serif:bold:italic' -> DH1:OBFonts/LiberationSerif-BoldItalic.ttf (Liberation Serif)
match 'Liberation Mono' -> DH1:OBFonts/LiberationMono-Regular.ttf (Liberation Mono)
match 'DejaVu Sans:bold' -> DH1:OBFonts/DejaVuSans-Bold.ttf (DejaVu Sans)
FC_DONE
```

DH1:OBFonts held 14 TrueType files: Liberation Sans, Serif and Mono (4 styles each) and DejaVu Sans (2).

It has not yet been run on real Amiga hardware.

## Known issues

- No `fonts.conf` is shipped here; OpenBrowser ships its own (`PROGDIR:fontconfig/fonts.conf`, with its cache in `T:fontconfig`), and it works on the bench. Programs can also add font folders with `FcConfigAppFontAddDir()`.

## Licence

Dalsin Limited's Amiga changes (the build script, patches, configuration
headers and tests) are MIT, Copyright (c) 2026 Dalsin Limited: see
[LICENSE](LICENSE). Fontconfig keeps its own licence, in
[upstream/](upstream/); a patch to its source stays under that licence.

## Contributors

openamigafontconfig is created and maintained by [SacredTrees](https://github.com/SacredTrees) with the AmigaChrome agent team, copyright Dalsin Limited. Everyone whose work it includes is credited in [`CONTRIBUTORS.md`](CONTRIBUTORS.md).
