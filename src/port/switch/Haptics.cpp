#ifdef __SWITCH__

#include "port/switch/haptics.h"

#include <libultraship/libultraship.h>
#include "port/ui/cvar_prefixes.h"
#include "ship/port/switch/SwitchImpl.h"

#include <SDL2/SDL.h>

// Short, distinct pulses: the low band (~160 Hz) reads as a thud, the high
// band (~320 Hz) as a click.
//
// A weaker pulse never cuts off a stronger one that is still playing (a coin
// tick must not swallow an explosion); equal or stronger pulses replace it.
static uint32_t sPulseEndMs = 0;
static float sPulsePeak = 0.0f;

static void Pulse(float ampLow, float freqLow, float ampHigh, float freqHigh, uint32_t ms) {
    const uint32_t now = SDL_GetTicks();
    const float peak = ampLow > ampHigh ? ampLow : ampHigh;
    if (now < sPulseEndMs && peak < sPulsePeak * 0.8f) {
        return;
    }
    sPulseEndMs = now + ms;
    sPulsePeak = peak;
    Ship::Switch::PlayHaptic(ampLow, freqLow, ampHigh, freqHigh, ms);
}

extern "C" void Paperboat_SfxCategoryHaptic(int category, float scale) {
    if (!CVarGetInteger(CVAR_SETTING("Switch.Rumble.Enabled"), 1) ||
        !CVarGetInteger(CVAR_SETTING("Switch.Rumble.WorldEffects"), 1)) {
        return;
    }
    const float k = CVarGetFloat(CVAR_SETTING("Switch.Rumble.Strength"), 0.7f) * scale;
    if (k <= 0.0f) {
        return;
    }
    switch (category) {
        case PB_SFX_PICKUP:
            Pulse(0.04f * k, 160.0f, 0.22f * k, 380.0f, 22);
            break;
        case PB_SFX_HEAL:
            Pulse(0.35f * k, 120.0f, 0.12f * k, 240.0f, 90);
            break;
        case PB_SFX_CELEBRATE:
            Pulse(0.30f * k, 150.0f, 0.35f * k, 320.0f, 140);
            break;
        case PB_SFX_EXPLOSION:
            Pulse(0.90f * k, 90.0f, 0.40f * k, 200.0f, 220);
            break;
        case PB_SFX_SHOCK:
            // Buzz: high band, longer.
            Pulse(0.15f * k, 200.0f, 0.55f * k, 600.0f, 160);
            break;
        case PB_SFX_HAMMER:
            Pulse(0.55f * k, 170.0f, 0.60f * k, 340.0f, 60);
            break;
        case PB_SFX_BREAK:
            // Crunchy: bright high band.
            Pulse(0.35f * k, 200.0f, 0.70f * k, 450.0f, 70);
            break;
        case PB_SFX_PLAYER_HURT:
            Pulse(0.80f * k, 140.0f, 0.25f * k, 280.0f, 110);
            break;
        case PB_SFX_BUMP:
            Pulse(0.50f * k, 160.0f, 0.40f * k, 320.0f, 50);
            break;
        case PB_SFX_THUD:
            // Deep and slow: low band only.
            Pulse(0.70f * k, 100.0f, 0.15f * k, 200.0f, 120);
            break;
        case PB_SFX_JUMP:
            Pulse(0.25f * k, 180.0f, 0.30f * k, 300.0f, 40);
            break;
        case PB_SFX_DOOR:
            Pulse(0.25f * k, 130.0f, 0.10f * k, 260.0f, 50);
            break;
        case PB_SFX_HIT:
            Pulse(0.45f * k, 170.0f, 0.40f * k, 320.0f, 45);
            break;
        default:
            break;
    }
}

extern "C" void Paperboat_Haptic(int type) {
    if (!CVarGetInteger(CVAR_SETTING("Switch.Rumble.Enabled"), 1)) {
        return;
    }
    const float strength = CVarGetFloat(CVAR_SETTING("Switch.Rumble.Strength"), 0.7f);
    if (strength <= 0.0f) {
        return;
    }
    switch (type) {
        case PB_HAPTIC_ACTION_NICE:
            Pulse(0.10f * strength, 160.0f, 0.45f * strength, 320.0f, 35);
            break;
        case PB_HAPTIC_ACTION_SUPER:
            Pulse(0.20f * strength, 180.0f, 0.70f * strength, 360.0f, 55);
            break;
        case PB_HAPTIC_PLAYER_HIT:
            Pulse(0.80f * strength, 140.0f, 0.25f * strength, 280.0f, 110);
            break;
        case PB_HAPTIC_STOMP:
            Pulse(0.45f * strength, 170.0f, 0.35f * strength, 300.0f, 45);
            break;
        case PB_HAPTIC_HAMMER_BATTLE:
            // Heavier and brighter than a stomp: a metallic clank.
            Pulse(0.65f * strength, 160.0f, 0.60f * strength, 330.0f, 70);
            break;
        case PB_HAPTIC_HAMMER_FIELD:
            Pulse(0.45f * strength, 180.0f, 0.55f * strength, 340.0f, 55);
            break;
        case PB_HAPTIC_COIN:
            // A light tick; counting many coins becomes a gentle patter.
            Pulse(0.04f * strength, 160.0f, 0.22f * strength, 380.0f, 22);
            break;
        case PB_HAPTIC_STAR_POINT:
            Pulse(0.03f * strength, 160.0f, 0.16f * strength, 420.0f, 18);
            break;
        case PB_HAPTIC_STAR_PIECE:
            Pulse(0.10f * strength, 180.0f, 0.40f * strength, 400.0f, 45);
            break;
        case PB_HAPTIC_RECOVER_HP:
            // Soft and warm: mostly low band, a little longer.
            Pulse(0.35f * strength, 120.0f, 0.12f * strength, 240.0f, 90);
            break;
        case PB_HAPTIC_RECOVER_FP:
            Pulse(0.25f * strength, 130.0f, 0.20f * strength, 280.0f, 80);
            break;
        default:
            break;
    }
}

#endif
