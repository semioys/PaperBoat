#pragma once

// HD Rumble cues for gameplay moments (Nintendo Switch only; no-ops elsewhere).
// Strength and on/off live in Settings > Switch.

enum PaperboatHaptic {
    PB_HAPTIC_ACTION_NICE,  ///< Action command landed ("Nice").
    PB_HAPTIC_ACTION_SUPER, ///< Action command combo ("Super").
    PB_HAPTIC_PLAYER_HIT,   ///< Mario took damage in battle.
    PB_HAPTIC_STOMP,        ///< Mario's jump attack connected.
    PB_HAPTIC_HAMMER_BATTLE,///< Mario's hammer attack connected.
    PB_HAPTIC_HAMMER_FIELD, ///< Hammer struck something in the field (blocks, trees...).
    PB_HAPTIC_COIN,         ///< Coins gained.
    PB_HAPTIC_STAR_POINT,   ///< Star Points gained.
    PB_HAPTIC_STAR_PIECE,   ///< Star Piece collected.
    PB_HAPTIC_RECOVER_HP,   ///< HP restored (hearts, items, inns).
    PB_HAPTIC_RECOVER_FP,   ///< FP restored (flowers, items).
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
