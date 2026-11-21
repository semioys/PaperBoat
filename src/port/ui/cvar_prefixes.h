#pragma once

#define CVAR_RANDOMIZER_ENHANCEMENT(var) CVAR_PREFIX_RANDOMIZER_ENHANCEMENT "." var
#define CVAR_RANDOMIZER_SETTING(var) CVAR_PREFIX_RANDOMIZER_SETTING "." var
#define CVAR_COSMETIC(var) CVAR_PREFIX_COSMETIC "." var
#define CVAR_AUDIO(var) CVAR_PREFIX_AUDIO "." var
#define CVAR_CHEAT(var) CVAR_PREFIX_CHEAT "." var
#define CVAR_ENHANCEMENT(var) CVAR_PREFIX_ENHANCEMENT "." var
#define CVAR_SETTING(var) CVAR_PREFIX_SETTING "." var
#define CVAR_WINDOW(var) CVAR_PREFIX_WINDOW "." var
#define CVAR_TRACKER(var) CVAR_PREFIX_TRACKER "." var
#define CVAR_TRACKER_ITEM(var) CVAR_TRACKER("ItemTracker." var)
#define CVAR_TRACKER_CHECK(var) CVAR_TRACKER("CheckTracker." var)
#define CVAR_TRACKER_ENTRANCE(var) CVAR_TRACKER("EntranceTracker." var)
#define CVAR_DEVELOPER_TOOLS(var) CVAR_PREFIX_DEVELOPER_TOOLS "." var
#define CVAR_GENERAL(var) CVAR_PREFIX_GENERAL "." var
#define CVAR_REMOTE(var) CVAR_PREFIX_REMOTE "." var
#define CVAR_REMOTE_CROWD_CONTROL(var) CVAR_REMOTE("CrowdControl." var)
#define CVAR_REMOTE_SAIL(var) CVAR_REMOTE("Sail." var)
#define CVAR_REMOTE_ANCHOR(var) CVAR_REMOTE("Anchor." var)
#define CVAR_GAMEPLAY_STATS(var) CVAR_PREFIX_GAMEPLAY_STATS "." var
#define CVAR_TIME_DISPLAY(var) CVAR_PREFIX_TIME_DISPLAY "." var
#define CVAR_2D_TEXTURE_FILTER CVAR_SETTING("2DTextureFilter")
#define CVAR_DIALOGUE_TEXT_FILTER CVAR_SETTING("DialogueTextFilter")
// Sharp (point-filtered) dialogue text by default on Switch: the bilinear-filtered
// font is hard to read on the handheld screen and on TVs.
#ifdef __SWITCH__
#define DIALOGUE_TEXT_FILTER_DEFAULT 1
#else
#define DIALOGUE_TEXT_FILTER_DEFAULT 0
#endif
