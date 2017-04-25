#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include <time.h>
#include "list.h"
#include<math.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include"frame_text.h"
#include"audio.h"
#include"core.h"
#include"sound.h"
#include"main.h"
#include"lines.h"
#include"rectangle.h"
#include"network.h"
#include"server_network.h"
/**
 * Open ERPG libraries
 */
int luaopen_main(lua_State *L) {    
  /*  struct luaL_Reg driver[] = {
    {"ERPG_Core", luaopen_core},
    {"ERPG_win", luaopen_ERPG_win},
    {"ERPG_utils", luaopen_ERPG_utils},
    {"ERPG_sprite", luaopen_ERPG_sprite},
    {"ERPG_Geometry_shape", luaopen_ERPG_geometry_shape},
    {"ERPG_Line", luaopen_ERPG_line},
    {"ERPG_Text_Element", luaopen_ERPG_Text_element},
    {"ERPG_Frame_text", luaopen_ERPG_Frame_text},
    {"ERPG_Audio", luaopen_ERPG_Audio},
    {"ERPG_Sound", luaopen_ERPG_Sound},
    {NULL, NULL}
    };
    
  luaL_newlib (L, driver);
  */
  luaL_requiref (L,"ERPG_Core",luaopen_core,1);
  luaL_requiref (L,"ERPG_Window",luaopen_ERPG_win,1);
  luaL_requiref (L,"ERPG_Utils",luaopen_ERPG_utils,1);
  luaL_requiref (L,"ERPG_Sprite",luaopen_ERPG_sprite,1);
  //luaL_requiref (L,"ERPG_Geometry_Shape",luaopen_ERPG_geometry_shape,1);
  luaL_requiref (L,"ERPG_Line",luaopen_ERPG_line,1);
  luaL_requiref (L,"ERPG_Text_Element",luaopen_ERPG_Text_element,1);
  luaL_requiref (L,"ERPG_Audio",luaopen_ERPG_Audio,1);
  luaL_requiref (L,"ERPG_Sound",luaopen_ERPG_Sound,1);
  luaL_requiref(L, "ERPG_Rectangle", luaopen_ERPG_Rectangle, 1);
  luaL_requiref(L, "ERPG_Network", luaopen_ERPG_Network, 1);
  luaL_requiref(L, "ERPG_Network_server", luaopen_ERPG_Network_server, 1);
		
  return 0;
}
