#ifdef __SWITCH__

// Optional post-processing on Switch, run as passes of the engine's post chain
// in a fixed order: edge blur first, CRT on top (scanlines over the blur).
//   Edge blur (port/shaders/post/edgeblur_*.shader.glsl): tilt-shift style,
//     sharp centre, blur growing towards the top/bottom (less on the sides).
//   CRT (port/shaders/post/crt_*.shader.glsl): scanlines, aperture mask,
//     vignette, slight curvature on Strong.

#include "port/ShipInit.hpp"
#include "port/ui/cvar_prefixes.h"

#include <libultraship/libultraship.h>

extern "C" int GameEngine_RegisterPostPass(const char* o2rShaderPath);
extern "C" void GameEngine_UnregisterPostPass(int id);

static int sBlurPass = -1;
static int sCrtPass = -1;
// Settings changed (or the game just started): register on the next frame.
// At startup the renderer doesn't exist yet when ShipInit runs, so the
// registration is retried every frame until it succeeds.
static bool sDirty = true;

static void Unregister(int& pass) {
    if (pass >= 0) {
        GameEngine_UnregisterPostPass(pass);
        pass = -1;
    }
}

void RegisterPostFilters_Init() {
    sDirty = true;
}

extern "C" void PostFilters_Update(void) {
    if (!sDirty) {
        return;
    }
    Unregister(sCrtPass);
    Unregister(sBlurPass);
    const int blur = CVarGetInteger(CVAR_SETTING("Switch.EdgeBlur"), 0);
    const int crt = CVarGetInteger(CVAR_SETTING("Switch.CrtFilter"), 0);

    switch (blur) {
        case 1:
            sBlurPass = GameEngine_RegisterPostPass("shaders/post/edgeblur_light.shader");
            break;
        case 2:
            sBlurPass = GameEngine_RegisterPostPass("shaders/post/edgeblur_strong.shader");
            break;
        default:
            break;
    }
    switch (crt) {
        case 1:
            sCrtPass = GameEngine_RegisterPostPass("shaders/post/crt_subtle.shader");
            break;
        case 2:
            sCrtPass = GameEngine_RegisterPostPass("shaders/post/crt_strong.shader");
            break;
        default:
            break;
    }
    // -1 means the renderer isn't up yet: try again next frame.
    sDirty = (blur != 0 && sBlurPass < 0) || (crt != 0 && sCrtPass < 0);
}

static RegisterShipInitFunc initPostFiltersFunc(RegisterPostFilters_Init,
                                                { CVAR_SETTING("Switch.CrtFilter"), CVAR_SETTING("Switch.EdgeBlur") });

#endif
