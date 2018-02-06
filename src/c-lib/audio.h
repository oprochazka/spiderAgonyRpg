#ifndef AUDIO_H
#define AUDIO_H
#include<SDL2/SDL_mixer.h>

typedef struct ERPG_Audio{
  List * list_of_chunks;
  List * list_of_music;
  CList * play_list;
  Mix_Music * music;
}ERPG_Audio;



#include"sound.h"

void ERPG_Audio_create(int frequency , int chunksize, int channels);
void ERPG_copy_sound_to_mixer(ERPG_Sound * sound);
void ERPG_play_audio();
ERPG_Audio * Lua_check_audio(lua_State * L, int i);
void ERPG_Destroy_audio();
int luaopen_ERPG_Audio(lua_State * L);
#endif
