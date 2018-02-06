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
#include"sound.h"

/**
 * @file   audio.c
 * @author Ondřej <ondrej@ondrej-HP-Compaq-6710b>
 * @date   Sat Apr 25 12:19:29 2015
 * 
 * @brief  
 * 
 * 
 */


void ERPG_Audio_create( int frequency , int chunksize, int channels)
{
  ERPG_Audio * audio_create = (ERPG_Audio*)malloc(sizeof(ERPG_Audio));
  ERPG_CORE * core = ERPG_get_CORE();
  //Mix_AllocateChannels(20);
  
  if( Mix_OpenAudio( frequency, MIX_DEFAULT_FORMAT, 2, chunksize) < 0 )
    printf( "SDL_mixer could not initialize! SDL_mixer Error: %s\n", Mix_GetError() );
  if(Mix_Init(MIX_INIT_OGG) != MIX_INIT_OGG)
    printf("OGG cant load: %s\n", Mix_GetError());
  
  audio_create->list_of_chunks = create_list();
  audio_create->play_list = create_clist();
  audio_create->list_of_music = create_list();
  
  printf("channels : %d \n", Mix_AllocateChannels(channels));
    
  core->audio = audio_create;
}
			     
void ERPG_play_audio()
{
  ERPG_Audio * audio = ERPG_get_Audio();
  ERPG_Sound  * sound;
  CNode * node = audio->play_list->root;
  while(node){
    sound = (ERPG_Sound*)node->value;
    if(sound->fade == 0 && sound->timed == 0)
      sound->channel = Mix_PlayChannel(-1, sound->sample, sound->repeat);
    else if( sound->timed != 0 && sound->fade == 0 )
      sound->channel = Mix_PlayChannelTimed(-1, sound->sample, sound->repeat, sound->timed);
    else if( sound->fade != 0 && sound->timed == 0)
      sound->channel = Mix_FadeInChannel(-1, sound->sample,sound->repeat, sound->fade);
    else
      sound->channel = Mix_FadeInChannelTimed(-1,sound->sample,sound->repeat, sound->fade,
					      sound->timed);
	
    if(sound->channel ==-1) 
      printf("Mix_PlayChannel: %s\n",Mix_GetError());
     node = node->next;
  }
  remove_clist(audio->play_list);  
}

void ERPG_Audio_set_background_music ( char * path)
{
  ERPG_Audio * audio = ERPG_get_Audio();
  Mix_Music * music = (Mix_Music*)list_get_value(audio->list_of_music, path);
  char * copy_path = (char*)malloc(sizeof(char)*strlen(path)+1);
  strcpy(copy_path, path);
  if(!music)
    music = Mix_LoadMUS(copy_path);
  if(!music) {
    free(copy_path);
    printf("Mix_Music error:: %s\n", Mix_GetError());
    return;
  }
  
  add_node(audio->list_of_music,copy_path, music);
  audio->music =  music;  
}
void ERPG_Audio_set_volume_music(int volume)
{
  Mix_VolumeMusic(volume);
}

void ERPG_Pause_music()
{
  Mix_PauseMusic();
}
void ERPG_Resume_music()
{
  Mix_ResumeMusic();
}
void ERPG_Rewind_music()
{
  Mix_RewindMusic();
}
int ERPG_Set_music_position(double position)
{
  return Mix_SetMusicPosition(position);
}
void ERPG_Music_stop()
{
  Mix_HaltMusic();
}
void ERPG_Music_fade_out(int ms)
{
  Mix_FadeOutMusic(ms);
}

void ERPG_Destroy_music()
{
  ERPG_Audio* audio = ERPG_get_Audio();
  Node * n = audio->list_of_music->root;

  while(n){
    Mix_FreeMusic((Mix_Music*)n->value);
    n = n->next;
  }

  destroy_list(audio->list_of_music);
}

void ERPG_Destroy_audio(ERPG_Audio * audio)
{
  ERPG_Music_stop();
  Node * node = audio->list_of_chunks->root;
  while(node){
    if(node->value)
      Mix_FreeChunk((Mix_Chunk*)node->value);
    
    node = node->next;
  }
  destroy_list(audio->list_of_chunks);
  free(audio->list_of_chunks);
  remove_clist(audio->play_list);
  free(audio->play_list);
  ERPG_Destroy_music(audio);
  free(audio->list_of_music);
}
//----------------------- LUa --- Integrace-------------------------------------
/*      
	------------AUDIO----------------------
*/

/**
 * Create audio
 * @return libAudio
*/
int Lib_Audio(lua_State * L)
{
  ERPG_Audio_create(44100, 4096,16);
  
  luaL_setmetatable(L, "ERPG_Audio");

  return 1;
}
/**
 * Set background music
 * @param path
*/
int Lua_Audio_set_background_music(lua_State * L)
{
  ERPG_Audio_set_background_music( (char*)luaL_checkstring(L,1));
  return 0;
}
/**
 * Set volume music
 * @param volume (min<=0- 128<=max)
*/
int Lua_Audio_set_volume_music(lua_State * L)
{
  ERPG_Audio_set_volume_music(luaL_checkinteger(L,1));
  return 0;
}
/**
 * Pause music
*/
int Lua_Pause_music(lua_State * L)
{
  ERPG_Pause_music();
  return 0;
}
/**
 * Resume music
*/
int Lua_Resume_music(lua_State * L)
{
  ERPG_Resume_music();
  return 0;
}
/**
 * Rewind music
*/
int Lua_Rewind_music(lua_State * L)
{
  ERPG_Rewind_music();
  return 0;
}
/**
 * Position music
 * @param distance
*/
int Lua_Set_music_position(lua_State * L)
{
  ERPG_Set_music_position(luaL_checkinteger(L,1));
  return 0;
}
/**
 * Music stop
*/
int Lua_Music_stop(lua_State * L)
{
  ERPG_Music_stop();
  return 0;
}
/**
 * Music fade out
 * @param timeToFadeOut
*/
int Lua_Music_fade_out(lua_State * L)
{
  ERPG_Music_fade_out(luaL_checkinteger(L,1));
  return 0;
}
/**
 * Play music
 * @param  countRepeat
 * @optional  int(pozition left) int(pozition right)
 * @optional2  int(distance)
*/
int Lua_Play_Music(lua_State * L)
{
  ERPG_Audio * audio = ERPG_get_Audio();
  
  if(lua_isnumber(L, 3))    
    if(lua_isnumber(L, 4))
      Mix_FadeInMusicPos(audio->music, luaL_checkinteger(L,1),
			 luaL_checkinteger(L,2), lua_tonumber(L,3));
      else
	Mix_FadeInMusic(audio->music, luaL_checkinteger(L,1),
			   luaL_checkinteger(L,2));
  else
    Mix_PlayMusic(audio->music, luaL_checkinteger(L,1));
  
  return 0;
}

int Lua_stop_all_sound(lua_State * L)
{
  Mix_HaltChannel(-1);
  return 0;
}

int Lua_play_audio(lua_State * L)
{
  ERPG_play_audio();
  return 0;
}

/** 
 * 
 * 
 * @param L 
 * 
 */
int luaopen_ERPG_Audio(lua_State * L)
{  
  static const luaL_Reg method[] = {
    {"update_mixer", Lua_play_audio},
    {"set_background_music",Lua_Audio_set_background_music},
    {"set_volume_music", Lua_Audio_set_volume_music},
    {"set_pause_music", Lua_Pause_music},
    {"resume_music", Lua_Resume_music},
    {"rewind_music", Lua_Rewind_music},
    {"set_music_position", Lua_Set_music_position},
    {"music_stop", Lua_Music_stop},
    {"music_fade_out", Lua_Music_fade_out},
    {"play_music", Lua_Play_Music},
    {"stop_all_sound", Lua_stop_all_sound},
    {NULL, NULL}
  };
  /*   static const luaL_Reg audio_lib[] = {
    {"create", Lib_Audio},
    {NULL, NULL}
    };
  */

  luaL_newlib(L, method);
  
  /* luaL_newmetatable(L,"ERPG_Audio");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");*/

  /*  lua_pushcfunction(L, Lua_Audio_gc);
  lua_setfield(L, -2, "__gc");
  */
  //  lua_pop(L, 1);
  
  return 1;
}
/**
 * @brief Play_audio(sound(chunk)) in list mixer
 * @param sound 
*/
