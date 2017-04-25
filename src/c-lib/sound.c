#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_mixer.h>
#include"main.h"
#include"basic_shapes.h"
#include"lua_func.h"
#include"list.h"
#include"window.h"
#include"core.h"
#include"audio.h"
#include "sound.h"
ERPG_Sound * ERPG_Sound_make( char * path)
{
  ERPG_Audio * audio = ERPG_get_Audio();
  ERPG_Sound * sound = (ERPG_Sound*)malloc(sizeof(ERPG_Sound));
  Mix_Chunk * sample = (Mix_Chunk*)list_get_value(audio->list_of_chunks, path);  
  
  if(!sample){
    sample = Mix_LoadWAV(path);
    add_node(audio->list_of_chunks,path, sample);
  }
  if(!sample) {
    free(path);
    free(sound);
    printf("Mix_LoadWAV_RW: %s\n", Mix_GetError());
    return NULL;
  }
  
  sound->sample =  sample;
  sound->repeat = 0;
  sound->fade = 0;
  sound->timed = 0;
  sound->channel = 0;
  
  Mix_VolumeChunk(sound->sample, MIX_MAX_VOLUME);
  //Mix_Volume(-1, MIX_MAX_VOLUME);  
  
  return sound;
}

void ERPG_Sound_pause(ERPG_Sound * sound)
{  
  Mix_Pause(sound->channel);
}
void ERPG_Sound_resume(ERPG_Sound * sound)
{
  Mix_Resume(sound->channel);
}
void ERPG_Sound_stop(ERPG_Sound * sound)
{
  Mix_HaltChannel(sound->channel);
}
void ERPG_Sound_set_volume(ERPG_Sound * sound, int volume)
{
  Mix_VolumeChunk(sound->sample, volume);
}
Uint8 ERPG_Sound_get_volume(ERPG_Sound * sound)
{
  return sound->sample->volume;
}
void ERPG_Sound_set_fade(ERPG_Sound * sound, int fade_in_ms)
{
  sound->fade = fade_in_ms;
}
void ERPG_Sound_set_fade_out(ERPG_Sound * sound, int fade_in_ms)
{
  Mix_FadeOutChannel(sound->channel, fade_in_ms);
}
void ERPG_Sound_set_timed(ERPG_Sound * sound, int timed_in_ticks)
{
  sound->timed = timed_in_ticks;
}
void ERPG_Sound_set_timed_out(ERPG_Sound * sound, int timed_in_ticks)
{
  Mix_ExpireChannel(sound->channel, timed_in_ticks);
}

void ERPG_Sound_set_distance(ERPG_Sound * sound, Uint8 distance)
{
  Mix_SetDistance(sound->channel,distance); 
}
void ERPG_Sound_set_position(ERPG_Sound * sound, Sint16 r, Uint8 distance)
{
  Mix_SetPosition(sound->channel, r, distance);
}

void ERPG_copy_sound_to_mixer(ERPG_Sound * sound)
{
  ERPG_Audio * audio = ERPG_get_Audio();
  add_cnode(audio->play_list, sound);
}

void ERPG_Destroy_sound(ERPG_Sound * sound)
{

}

/*----------------------------LUA_______________INTEGRACE------------------------

  ---------------------SOUND----------------------------

 */  
ERPG_Sound * Lua_check_sound(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Sound");
}


/**
 * Create sound(chunk)
 * @param pathToAudio
 * @return sound
*/
int Lib_Sound(lua_State * L)
{
  const char * path = luaL_checkstring(L,1);
  char * alloc_path = (char*)malloc(sizeof(char)*strlen(path)+1);
  strcpy(alloc_path, path);
  
  ERPG_Sound * tmp = ERPG_Sound_make(alloc_path);
    
  if(!tmp){
    lua_pushnil(L);
    return 1;
  }
  
  ERPG_Sound * sound = lua_newuserdata(L, sizeof(ERPG_Sound));  
  memcpy(sound, tmp, sizeof(ERPG_Sound));

  free(tmp);

  luaL_setmetatable(L,"ERPG_Sound");

  return 1;
}
/**
 * Sound to mixer
 * @param sound
*/
int Lua_copy_sound_to_mixer(lua_State * L)
{
  ERPG_copy_sound_to_mixer(Lua_check_sound(L,1));
  return 0;
}

/**
 * Pause
 * @param sound
*/
int Lua_Sound_pause(lua_State * L)
{
  ERPG_Sound_pause(Lua_check_sound(L,1));
  return 0;
}
/**
 * Set repeat
 * @param sound
 * @param countRepeat (-1 = inf)
*/
int Lua_Sound_set_repeat(lua_State * L)
{
  Lua_check_sound(L,1)->repeat = luaL_checkinteger(L,2);
  return 0;
}
/**
 * Resume
 * @param sound
*/
int Lua_Sound_resume(lua_State * L)
{
  ERPG_Sound_resume(Lua_check_sound(L,1));
  return 0;
}
/**
 * Stop
 * @param sound
*/
int Lua_Sound_stop(lua_State * L)
{
  ERPG_Sound_stop(Lua_check_sound(L,1));
  return 0;
}
/**
 * Set volume 
 * @param sound
 * @param volume (int min<=0- 128<=max)
*/
int Lua_Sound_set_volume(lua_State * L)
{
  ERPG_Sound_set_volume(Lua_check_sound(L,1),luaL_checkinteger(L,2));
  return 0;
}
/**
 * Get volume 
 * @param sound
 * @return volume
*/
int Lua_Sound_get_volume(lua_State * L)
{
  lua_pushnumber(L, ERPG_Sound_get_volume(Lua_check_sound(L,1)));
  return 1;
}
/**
 * Set fade in
 * @param sound
 * @param timeToFade
*/
int Lua_Sound_set_fade(lua_State * L)
{
  ERPG_Sound_set_fade(Lua_check_sound(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Set fade out
 * @param sound
 * @param timeToFadeOut
*/
int Lua_Sound_set_fade_out(lua_State * L)
{
  ERPG_Sound_set_fade_out(Lua_check_sound(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Set timed in
 * @param sound
 * @param time(milisecund)
*/
int Lua_Sound_set_timed(lua_State * L)
{
  ERPG_Sound_set_timed(Lua_check_sound(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Set timed out
 * @param sound
 * @param timedOut(milisecund)
*/
int Lua_Sound_set_timed_out(lua_State * L)
{
  ERPG_Sound_set_timed_out(Lua_check_sound(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Set distance
 * @param sound
 * @param distance
*/
int Lua_Sound_set_distance(lua_State * L)
{
  ERPG_Sound_set_distance(Lua_check_sound(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Set position
 * @param sound
 * @param right
 * @param left
*/
int Lua_Sound_set_position(lua_State * L)
{
  ERPG_Sound_set_position(Lua_check_sound(L,1), luaL_checkinteger(L,2),luaL_checkinteger(L,3));
  return 0;
}
int Lua_Sound_gc(lua_State * L)
{
  ERPG_Destroy_sound(Lua_check_sound(L, 1));
  return 0;
}

int luaopen_ERPG_Sound(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"pause", Lua_Sound_pause},
    {"resume", Lua_Sound_resume},
    {"stop", Lua_Sound_stop},
    {"copy_to_mixer", Lua_copy_sound_to_mixer},
    {"get_volume", Lua_Sound_get_volume},
    {"set_volume", Lua_Sound_set_volume},
    {"set_fade", Lua_Sound_set_fade},
    {"set_fade_out", Lua_Sound_set_fade_out},
    {"set_timed", Lua_Sound_set_timed},
    {"set_timed_out", Lua_Sound_set_timed_out},
    {"set_distance", Lua_Sound_set_distance},
    {"set_position", Lua_Sound_set_position},
    {"set_repeat", Lua_Sound_set_repeat},
      {NULL, NULL}
    };
  static const luaL_Reg sound_lib[] = {
    {"make", Lib_Sound},

    {NULL, NULL}
  };

  luaL_newlib(L, sound_lib);

  luaL_newmetatable(L,"ERPG_Sound");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");

  lua_pushstring(L, "__gc");
  lua_pushcfunction(L, Lua_Sound_gc);
  lua_settable(L, -3);
  lua_pop(L, 1);
  
  return 1;
}
