#ifdef __SWITCH__

#include "port/switch/haptics.h"

#include <libultraship/libultraship.h>
#include "port/ui/cvar_prefixes.h"
#include "ship/port/switch/SwitchImpl.h"

// Short, distinct pulses: the low band (~160 Hz) reads as a thud, the high
// band (~320 Hz) as a click.
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
            Ship::Switch::PlayHaptic(0.10f * strength, 160.0f, 0.45f * strength, 320.0f, 35);
            break;
        case PB_HAPTIC_ACTION_SUPER:
            Ship::Switch::PlayHaptic(0.20f * strength, 180.0f, 0.70f * strength, 360.0f, 55);
            break;
        case PB_HAPTIC_PLAYER_HIT:
            Ship::Switch::PlayHaptic(0.80f * strength, 140.0f, 0.25f * strength, 280.0f, 110);
            break;
        case PB_HAPTIC_STOMP:
            Ship::Switch::PlayHaptic(0.45f * strength, 170.0f, 0.35f * strength, 300.0f, 45);
            break;
        case PB_HAPTIC_HAMMER_BATTLE:
            // Heavier and brighter than a stomp: a metallic clank.
            Ship::Switch::PlayHaptic(0.65f * strength, 160.0f, 0.60f * strength, 330.0f, 70);
            break;
        case PB_HAPTIC_HAMMER_FIELD:
            Ship::Switch::PlayHaptic(0.45f * strength, 180.0f, 0.55f * strength, 340.0f, 55);
            break;
        case PB_HAPTIC_COIN:
            // A light tick; counting many coins becomes a gentle patter.
            Ship::Switch::PlayHaptic(0.04f * strength, 160.0f, 0.22f * strength, 380.0f, 22);
            break;
        case PB_HAPTIC_STAR_POINT:
            Ship::Switch::PlayHaptic(0.03f * strength, 160.0f, 0.16f * strength, 420.0f, 18);
            break;
        case PB_HAPTIC_STAR_PIECE:
            Ship::Switch::PlayHaptic(0.10f * strength, 180.0f, 0.40f * strength, 400.0f, 45);
            break;
        case PB_HAPTIC_RECOVER_HP:
            // Soft and warm: mostly low band, a little longer.
            Ship::Switch::PlayHaptic(0.35f * strength, 120.0f, 0.12f * strength, 240.0f, 90);
            break;
        case PB_HAPTIC_RECOVER_FP:
            Ship::Switch::PlayHaptic(0.25f * strength, 130.0f, 0.20f * strength, 280.0f, 80);
            break;
        default:
            break;
    }
}

#endif
