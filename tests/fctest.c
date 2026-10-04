/* openamigafontconfig smoke test: index a font folder, list and match fonts. */
#include <stdio.h>
#include <fontconfig/fontconfig.h>
static void match(FcConfig *cfg, const char *pattern)
{
    FcPattern *p = FcNameParse((const FcChar8 *)pattern), *m; FcResult r; FcChar8 *file = NULL, *family = NULL;
    FcConfigSubstitute(cfg, p, FcMatchPattern); FcDefaultSubstitute(p);
    m = FcFontMatch(cfg, p, &r);
    if (m) { FcPatternGetString(m, FC_FILE, 0, &file); FcPatternGetString(m, FC_FAMILY, 0, &family); }
    printf("match '%s' -> %s (%s)\n", pattern, file ? (char *)file : "(none)", family ? (char *)family : "?");
    if (m) FcPatternDestroy(m);
    FcPatternDestroy(p);
}
/* ROM mathieeesingbas.library leaves the FPU in single precision (FPCR $40)
 * in every task that opens it; doubles need FPCR 0. */
static void resetFPCR(void) { __asm__ volatile ("fmove.l %0,%%fpcr" : : "d" (0)); }

int main(int argc, char **argv)
{
    resetFPCR();
    FcConfig *cfg = FcConfigCreate(); FcPattern *all = FcPatternCreate();
    FcObjectSet *os = FcObjectSetBuild(FC_FAMILY, FC_STYLE, NULL); FcFontSet *fs;
    const char *dir = argc > 1 ? argv[1] : "DH1:OBFonts";
    printf("FONTCONFIG %d add_dir=%d\n", FcGetVersion(), FcConfigAppFontAddDir(cfg, (const FcChar8 *)dir));
    FcConfigSetCurrent(cfg);
    fs = FcFontList(cfg, all, os);
    printf("fonts=%d\n", fs ? fs->nfont : -1);
    match(cfg, "Liberation Serif:bold:italic");
    match(cfg, "Liberation Mono");
    match(cfg, "DejaVu Sans:bold");
    if (fs) FcFontSetDestroy(fs);
    FcObjectSetDestroy(os); FcPatternDestroy(all);
    printf("FC_DONE\n");
    return 0;
}
