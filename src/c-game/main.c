#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_mixer.h>

#include"./../c-lib/erpg_engine.h"
#include "./../c-lib/network.h"
#include "testing.h"


static int TestThread(void *ptr)
{
  int cnt;
  lua_State* L = luaL_newstate();
  luaopen_main(L);
  luaL_openlibs(L); 
  luaL_dofile(L,"./src/lua-game/client.lua");
  ERPG_CORE * core = ERPG_get_CORE();

  while(!core->exit)
  {
    if(core->network)
    {

      ERPG_Network_recieve_string(500);
   //   ERPG_Network_send_string("");

      printf("%s \n", ERPG_Network_get_data());
    }
  }
  return cnt;
}

int main(int argc, char ** argv)
{
  ERPG_CREATE_CORE();

  lua_State * L = luaL_newstate ();

  int result = 0;
  int last_delay= 0;

  //  luaL_requiref (L,"ERPG_Engine",luaopen_main,1);
  luaopen_main(L);
  luaL_openlibs(L);  

  ERPG_Audio_create(44100, 4096, 16);
  ERPG_make_window("ENGINE RPG");



  if (argc == 2){
    lua_pushstring(L,"/usr/share/rpg/");
    lua_setglobal(L,"PREFIX");
    result =   luaL_dofile(L,"/usr/share/rpg/src/lua-game/start_game.lua");
  }
  else{
    lua_pushstring(L,"");
    lua_setglobal(L,"PREFIX");
    result =   luaL_dofile(L,"./src/lua-game/start_game.lua");
  }
  if(result != 0){
    printf("Error occurs when calling luaL_dofile() Hint Machine 0x%x\n",result);
    printf("Error: %s \n", lua_tostring(L,-1));
    // scanf("%d",&exit);
  }

  int delay = 30;
  ERPG_CORE * core = ERPG_get_CORE();
  int currenttime = 0;
  int set_delay =0;
  int * again = (int*)malloc(sizeof(int));
  *again = -1;

  currenttime = SDL_GetTicks();
  int count = 5;
  int iter = 0;
  int gc_step = 40;
  int mesure = 0;


  //SDL_Thread *thread = SDL_CreateThread(TestThread, "TestThread", (void *)NULL);
  int threadReturnValue;

  while(!core->exit){
    lua_getglobal(L, "_DELAY");
    if(lua_isnumber(L,-1))
      delay = lua_tonumber(L, -1);
    else
      delay= 31;
		
    lua_pop(L,1);
	
    lua_getglobal(L, "_GC_STEP");

    if(lua_isnumber(L,-1))
      gc_step = lua_tonumber(L, -1);
    else
      gc_step = 40;

    lua_pop(L,1);
    testing(L,again);

    int renderTime = SDL_GetTicks();
    Lua_update(L);

    if(SDL_GetTicks() - renderTime > 20)
      printf("time delay: %d \n", SDL_GetTicks() - renderTime);
 

    if (last_delay < 1000) {
      last_delay = 0;
    }

    delay = delay + last_delay;
    set_delay = delay-(SDL_GetTicks() - currenttime);    

    int timeProof = SDL_GetTicks();

    int time = 0;
    if(set_delay > 0){      
      time = SDL_GetTicks();
      int test_time = SDL_GetTicks() - time;
      while(test_time < (set_delay - 3))
      {
        lua_gc(L, LUA_GCSTEP, gc_step);
        test_time = SDL_GetTicks() - time;
      }
          
      last_delay = 0;
      time = set_delay - (SDL_GetTicks() - time);   
      if(time > 0 )
      {
				SDL_Delay(time);
      }
    }
    else{
      last_delay = 0;   
      set_delay = 0;      
      if(iter%count == 0) {	
	//
 
        lua_gc(L, LUA_GCSTEP, gc_step);	  
      }
      iter = iter + 1;       
    }
    if(SDL_GetTicks() - timeProof > 10)
      printf("time garbbage: %d \n", SDL_GetTicks() - timeProof);
    
    lua_pushnumber(L,time);
    lua_setglobal(L,"_LAST_DELAY");

    currenttime = SDL_GetTicks();  


  }  

  free(again);  
  lua_close(L);  
  ERPG_Destroy_core();
  
  return 0;
}
