#pragma once

// HD Rumble cues for gameplay moments (Nintendo Switch only; no-ops elsewhere).
// Strength and on/off live in Settings > Switch.

enum PaperboatHaptic {
    PB_HAPTIC_ACTION_NICE,  ///< Action command landed ("Nice").
    PB_HAPTIC_ACTION_SUPER, ///< Action command combo ("Super").
    PB_HAPTIC_PLAYER_HIT,   ///< Mario took damage in battle.
    PB_HAPTIC_STOMP,        ///< Mario's jump attack connected.
};

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __SWITCH__
void Paperboat_Haptic(int type);
#else
static inline void Paperboat_Haptic(int type) {
    (void)type;
}
#endif

#ifdef __cplusplus
}
#endif
