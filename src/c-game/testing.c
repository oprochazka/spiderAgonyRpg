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
#include"testing.h"
int traceback (lua_State *L);
typedef struct Vector{
  int x;
  int y;
}Vector;

	

void testing(lua_State * L, int * again)
{
  Lua_prepare(L);

  ERPG_Window * window =  ERPG_get_Window();
  CList* list1;
  if(window->keyboard)
    list1 = window->keyboard->release_key;

  if(list1->root){
    CNode * node = list1->root;

    if(!strcmp((char*)node->value,"F1")){
         char * string = (char*)malloc(sizeof(char)* 1000);

	 printf(">> ");
	 fgets(string,sizeof(char)*1000,stdin);
	 luaL_loadstring(L,string);
	 if( lua_pcall(L,0,0,0)){
	   printf("%s \n", string);
	   printf("runtime error: %s \n", lua_tostring(L, -1));      
	   lua_pop(L,1);
	 }	 
	 free(string);
    }
    
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_remove(L, -2);
    
    if(!strcmp((char*)node->value,"F2")){
      luaL_dofile(L,"./buffer.lua");      
      
      lua_getglobal(L,"buffer");
      if( lua_pcall(L,0,0,0)){
	printf("runtime error: %s \n", lua_tostring(L, -1));      
	lua_pop(L,1);
      }
    }
  }

  
  lua_getglobal(L, "debug");
  lua_getfield(L, -1, "traceback");
  lua_remove(L, -2);  

  lua_getglobal(L,"main");
  if(lua_pcall(L, 0, 0, -2)){
    printf("runtime error: %s \n", lua_tostring(L, -1));
    lua_pop(L,1); 
   
    char * string = (char*)malloc(sizeof(char)* 1000);

    printf(">> ");
    fgets(string,sizeof(char)*1000,stdin);
    printf("\n");
    luaL_loadstring(L,string);
    if( lua_pcall(L,0,0,0)){
      printf("runtime error: %s \n", lua_tostring(L, -1));      
      lua_pop(L,1);
    }

    free(string);	
  }

  if(*again > 0){
    *again = *again - 1;
  }


}
  
