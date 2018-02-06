#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_mixer.h>
#include<time.h>
#include"lua_func.h"
#include <dirent.h>
#include <errno.h>

int Lua_get_time(lua_State * L){
  int t =SDL_GetTicks();
  lua_pushnumber(L, t);
  
  return 1;
}

int Lua_delay(lua_State * L){
  if(lua_isnumber(L,1))
     SDL_Delay( lua_tonumber(L, 1) );

  return 0;
}

int print_num(lua_State * L)
{
  int i = 0;
  if( lua_isfunction(L,1) ){
    for(i=0 ; i < 20; i++){
      lua_pushvalue(L,1);
      lua_pushnumber(L,i);

      lua_call(L,1,0);
    }

  }    
  return 0;
}

/**
 * Get table of files
 * @param path
 * @return tableOfNameFiles
 */
int l_dir (lua_State *L) {
  DIR *dir;
  struct dirent *entry;
  int i;
  const char *path = luaL_checkstring(L, 1);
  /* open directory */
  dir = opendir(path);
  if (dir == NULL) { /* error opening the directory? */
    lua_pushnil(L); /* return nil */
    lua_pushstring(L, strerror(errno)); /* and error message */
    return 2; /* number of results */
  }
  /* create result table */
  lua_newtable(L);
  i = 1;
  while ((entry = readdir(dir)) != NULL) {
    lua_pushnumber(L, i++); /* push key */
    lua_pushstring(L, entry->d_name); /* push value */
    lua_settable(L, -3);
  }
  closedir(dir);
  return 1;
}

int Lua_get_current_user(lua_State * L)
{
  lua_pushstring(L, getenv("HOME"));
  return 1;
}

/**
 * Get Intersect rect
 * @param rect1
 * @param rect2
 * @return intersectRect
 * @return ifIntersect (0 or 1)
 */
  
int Lua_intersect_rect(lua_State * L)
{
  SDL_Rect * rect = Lua_from_create_rect(L, 1);
  SDL_Rect * rect2 = Lua_from_create_rect(L, 2);
  SDL_Rect * rect_out = (SDL_Rect*)malloc(sizeof(SDL_Rect));
  SDL_bool result = SDL_IntersectRect(rect,
				      rect2,
				      rect_out);

  rect_to_table(L, rect_out);
  lua_pushnumber(L, result);
    
  free(rect_out);
  free(rect);
  free(rect2);

  return 2;
}
/* NOvejší sdlx
int Lua_intersect_point(lua_State * L)
{
  SDL_Rect * r = Lua_from_create_rect(L,3);
  SDL_Point point;
  point.x = luaL_checkinteger(L,1);
  point.y = luaL_checkinteger(L,2);  
  SDL_bool b =SDL_PointInRect(&point, r);

  if(b == SDL_TRUE)
    lua_pushnumber(L,1);
  else
    lua_pushnil(L);
  
  free(r);
  
  return 1;
}
*/

int luaopen_ERPG_utils(lua_State *L) {
  struct luaL_Reg driver[] = {
    {"get_time", Lua_get_time},
    {"delay", Lua_delay},
    {"intersect_rect", Lua_intersect_rect},
    {"test_func", print_num},
    {"get_files_dir", l_dir},
    {"get_user", Lua_get_current_user},
    {NULL, NULL},
  };

  
  //  luaL_setfuncs(L, driver ,0);

  luaL_newlib (L, driver);
  //lua_settable(L, -3);
  
  return 1;
}


