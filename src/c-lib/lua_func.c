#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>

SDL_Rect * Lua_from_create_rect(lua_State * L, int index)
{
  int temp_array[4];

  SDL_Rect * rectangle;
  if(lua_istable(L,index)){

    rectangle= (SDL_Rect*)malloc(sizeof(SDL_Rect));
    lua_pushnil(L);
    for(int i = 0; lua_next(L, index) != 0; i++){
      temp_array[i] = luaL_checkinteger(L,-1);
      lua_pop(L,1);
    }
    rectangle->x = temp_array[0];
    rectangle->y = temp_array[1];
    rectangle->w = temp_array[2];
    rectangle->h = temp_array[3];
  }
  return rectangle;
}

SDL_Rect Lua_from_create_rect_static(lua_State * L, int index)
{
  int temp_array[4];

  SDL_Rect rectangle;
  if(lua_istable(L,index)){

    lua_pushnil(L);
    for(int i = 0; lua_next(L, index) != 0; i++){
      temp_array[i] = luaL_checkinteger(L,-1);
      lua_pop(L,1);
    }
    rectangle.x = temp_array[0];
    rectangle.y = temp_array[1];
    rectangle.w = temp_array[2];
    rectangle.h = temp_array[3];
  }
  return rectangle;
}

Sint16* Lua_get_sint16_from_table(lua_State * L,int index, int size_table)
{
  Sint16 * out = (Sint16*)malloc(sizeof(Sint16)*size_table);
  
  if(lua_istable(L,index)){
    lua_pushnil(L);
    for(int i = 0; lua_next(L, index) != 0; i++){
      out[i]= luaL_checkinteger(L,-1);
      lua_pop(L,1);
    }
  }
  return out;
}

SDL_Color *Lua_get_color(lua_State * L,int index)
{
  SDL_Rect * color_rect;
  SDL_Color * color = (SDL_Color*)malloc(sizeof(SDL_Color));;
  color_rect = Lua_from_create_rect(L,index);
  if (!color_rect)
    return NULL;
  
  
  color->r = color_rect->x;
  color->g = color_rect->y;
  color->b = color_rect->w;
  color->a = color_rect->h;

  free(color_rect);
  
  return color;
}


int setfield (lua_State *L, const char *index, int value) {
  lua_pushstring(L, index);
  lua_pushnumber(L, value);
  lua_settable(L, -3);
  return 1;
}

int rect_to_table(lua_State * L, SDL_Rect * rect)
{
  lua_createtable(L, 0, 4);
  setfield(L, "x",rect->x);
  setfield(L, "y",rect->y);
  setfield(L, "w",rect->w);
  setfield(L, "h",rect->h);

  return 1;
}
