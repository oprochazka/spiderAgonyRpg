#ifndef SOUND_H
#define SOUND_H

typedef struct ERPG_Sound{
  int channel;
  Mix_Chunk * sample;
  int repeat;
  int fade;
  int timed;
}ERPG_Sound;

#include"audio.h"

ERPG_Sound * ERPG_Sound_make( char * path);
void ERPG_Sound_pause(ERPG_Sound * sound);
void ERPG_Sound_resume(ERPG_Sound * sound);
void ERPG_Sound_stop(ERPG_Sound * sound);
void ERPG_Sound_set_volume(ERPG_Sound * sound, int volume);
Uint8 ERPG_Sound_get_volume(ERPG_Sound * sound);
void ERPG_Sound_set_fade(ERPG_Sound * sound, int fade_in_ms);
void ERPG_Sound_set_fade_out(ERPG_Sound * sound, int fade_in_ms);
void ERPG_Sound_set_timed(ERPG_Sound * sound, int timed_in_ticks);
void ERPG_Sound_set_timed_out(ERPG_Sound * sound, int timed_in_ticks);
void ERPG_Sound_set_position(ERPG_Sound * sound, Sint16 r, Uint8 distance);
void ERPG_Sound_distance(ERPG_Sound * sound, Uint8 distance);

ERPG_Sound * Lua_check_sound(lua_State * L, int i);
int luaopen_ERPG_Sound(lua_State * L);
#endif
