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

// Categories for sound-driven cues (sound_haptics.c / gen_sound_haptics.py).
enum PaperboatSfxHaptic {
    PB_SFX_PICKUP,      ///< Coins, Star Points: light tick.
    PB_SFX_HEAL,        ///< Hearts, flowers, recovery: soft and warm.
    PB_SFX_CELEBRATE,   ///< Got an item/badge/key, power up, game saved.
    PB_SFX_EXPLOSION,   ///< Bombs, blasts, POW block.
    PB_SFX_SHOCK,       ///< Electric shocks, lightning.
    PB_SFX_HAMMER,      ///< Hammer strikes, spin smash, quake hammer.
    PB_SFX_BREAK,       ///< Shattering glass/ice, breaking crates and floors.
    PB_SFX_PLAYER_HURT, ///< Mario gets hit.
    PB_SFX_BUMP,        ///< Bumping blocks from below, switches, pushed blocks.
    PB_SFX_THUD,        ///< Heavy landings, collapses, rumbling structures.
    PB_SFX_JUMP,        ///< Spin/tornado jumps, springs.
    PB_SFX_DOOR,        ///< Doors, gates, chests, pipes.
    PB_SFX_HIT,         ///< Attacks connecting in battle.
};

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __SWITCH__
void Paperboat_Haptic(int type);
// Called for every sound effect the game starts; volume 0 = default.
void Paperboat_SfxHaptic(int soundID, int volume);
void Paperboat_SfxCategoryHaptic(int category, float scale);
#else
static inline void Paperboat_Haptic(int type) {
    (void)type;
}
#define Paperboat_SfxHaptic(soundID, volume) ((void)0)
#endif

#ifdef __cplusplus
}
#endif
