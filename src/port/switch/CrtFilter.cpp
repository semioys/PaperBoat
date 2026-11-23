#ifdef __SWITCH__

// CRT look as a post pass (port/shaders/post/crt_*.shader.glsl): scanlines,
// aperture mask, vignette, and on "Strong" a slight curvature. One extra
// fullscreen pass with a single texture fetch per pixel.

#include "port/ShipInit.hpp"
#include "port/ui/cvar_prefixes.h"

#include <libultraship/libultraship.h>

extern "C" int GameEngine_RegisterPostPass(const char* o2rShaderPath);
extern "C" void GameEngine_UnregisterPostPass(int id);

static int sCrtPass = -1;

void RegisterCrtFilter_Init() {
    if (sCrtPass >= 0) {
        GameEngine_UnregisterPostPass(sCrtPass);
        sCrtPass = -1;
    }
    switch (CVarGetInteger(CVAR_SETTING("Switch.CrtFilter"), 0)) {
        case 1:
            sCrtPass = GameEngine_RegisterPostPass("shaders/post/crt_subtle.shader");
            break;
        case 2:
            sCrtPass = GameEngine_RegisterPostPass("shaders/post/crt_strong.shader");
            break;
        default:
            break;
    }
}

static RegisterShipInitFunc initCrtFilterFunc(RegisterCrtFilter_Init, { CVAR_SETTING("Switch.CrtFilter") });

#endif
