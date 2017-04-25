#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_mixer.h>
#include<SDL2/SDL_thread.h>
#include<time.h>
#include<SDL2/SDL_net.h>
#include"main.h"
#include"basic_shapes.h"
#include"mouse.h"
#include"keyboard.h"
#include"core.h"
#include"audio.h"
#include"list.h"



#define false 0
#define true 1

ERPG_CORE * ERPG_CORE_MAIN;

/**
 * Create core of ERPG
 */
ERPG_CORE * ERPG_CREATE_CORE()
{
  if(SDL_Init(0)==-1) {
      printf("SDL_Init: %s\n", SDL_GetError());
      exit(1);
  }
  if(SDLNet_Init()==-1) {
      printf("SDLNet_Init: %s\n", SDLNet_GetError());
      exit(2);
  }

  printf("Create core \n");
  ERPG_CORE_MAIN = (ERPG_CORE*)malloc(sizeof(ERPG_CORE));
  ERPG_CORE_MAIN->window = NULL;
  ERPG_CORE_MAIN->audio = NULL;
  ERPG_CORE_MAIN->exit = false;
	ERPG_CORE_MAIN->thread = NULL;
  ERPG_CORE_MAIN->network_server = NULL;
  ERPG_CORE_MAIN->network = NULL;

  return ERPG_CORE_MAIN;
}

ERPG_CORE * ERPG_get_CORE()
{
  return ERPG_CORE_MAIN;
}
ERPG_Audio * ERPG_get_Audio()
{
  return ERPG_CORE_MAIN->audio;
}
ERPG_Window * ERPG_get_Window()
{
  return ERPG_CORE_MAIN->window;
}
ERPG_Network * ERPG_get_Network()
{
  return ERPG_CORE_MAIN->network;
}
ERPG_Network_server * ERPG_get_Network_server()
{
    return ERPG_CORE_MAIN->network_server;
}
/**
 * Set flag to exit
 */
int Lua_set_exit()
{
  ERPG_CORE_MAIN->exit = true;
  return 0;
}
/**
 *Get flag of exit
 */
int get_exit()
{
  return ERPG_CORE_MAIN->exit;
}


/**
 * Destroy core of ERPG
 */
int ERPG_Destroy_core()
{
  if(ERPG_get_Audio())
    ERPG_Destroy_audio(ERPG_get_Audio());
  if(ERPG_get_Window())
    ERPG_Destroy_window(ERPG_get_Window());
  if(ERPG_CORE_MAIN->network_server)
  {
    ERPG_Network_server_destroy();
  }
  if(ERPG_CORE_MAIN->network)
  {
    ERPG_Network_destroy();
  }
  
  free(ERPG_CORE_MAIN->window);
  free(ERPG_CORE_MAIN->audio);
  free(ERPG_CORE_MAIN);



  SDLNet_Quit();
  IMG_Quit();
  TTF_Quit();
  Mix_Quit();
  SDL_Quit();

  printf("CORRECT END \n");
  return 0;
}

int luaopen_core(lua_State * L)
{
  struct luaL_Reg func[] = {
    {"set_exit", Lua_set_exit},
    {NULL, NULL}
  };

  luaL_newlib(L,func);
  return 1;
}
