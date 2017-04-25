#ifndef CORE_H
#define CORE_H
#include "window.h"
#include "network.h"
#include "server_network.h"

typedef struct{
  ERPG_Window * window;
  ERPG_Audio * audio;
  char exit;
	SDL_Thread * thread;
	ERPG_Network_server * network_server;
	ERPG_Network * network;
}ERPG_CORE;

ERPG_Audio * ERPG_get_Audio();
ERPG_Window * ERPG_get_Window();
ERPG_Network * ERPG_get_Network();
ERPG_Network_server * ERPG_get_Network_server();

int Lua_set_exit();
int get_exit();

int luaopen_core(lua_State * L);
int ERPG_Destroy_core();

ERPG_CORE * ERPG_CREATE_CORE();
ERPG_CORE * ERPG_get_CORE();
#endif
