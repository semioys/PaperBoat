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
#include <fast/Fast3dWindow.h>
#include <fast/interpreter.h>

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

// The renderer can be replaced after start-up (and with it its post-pass
// list), so every half second check that our passes are still registered in
// the current one.
static Fast::Interpreter* sRegisteredOn = nullptr;

static bool PassesStillRegistered(Fast::Interpreter* interpreter) {
    if (interpreter == nullptr || interpreter != sRegisteredOn) {
        return false;
    }
    const auto passes = interpreter->GetPostPasses();
    auto has = [&](int id) {
        if (id < 0) {
            return true;
        }
        for (const auto& pass : passes) {
            if (pass.id == id) {
                return true;
            }
        }
        return false;
    };
    return has(sBlurPass) && has(sCrtPass);
}

extern "C" void PostFilters_Update(void) {
    auto window = std::dynamic_pointer_cast<Fast::Fast3dWindow>(Ship::Context::GetRawInstance()->GetWindow());
    auto interpreter = window != nullptr ? window->GetInterpreterWeak().lock() : nullptr;
    static int sFrames = 0;
    if (!sDirty && ++sFrames >= 30) {
        sFrames = 0;
        if ((sBlurPass >= 0 || sCrtPass >= 0) && !PassesStillRegistered(interpreter.get())) {
            sBlurPass = -1; // ids belong to the old renderer
            sCrtPass = -1;
            sDirty = true;
        }
    }
    if (!sDirty || interpreter == nullptr) {
        return;
    }
    sRegisteredOn = interpreter.get();
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
