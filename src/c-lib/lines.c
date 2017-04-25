#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include"main.h"
#include"lua_func.h"
#include"lines.h"
#include"core.h"

ERPG_Line * ERPG_make_line(SDL_Rect point_line,SDL_Color draw_color)
{
  ERPG_Line * line = (ERPG_Line*)malloc(sizeof(ERPG_Line));
  
  line->destination.x = point_line.x;
  line->destination.y = point_line.y;
  line->destination.w = point_line.w;
  line->destination.h = point_line.h;
  line->color.r = draw_color.r;
  line->color.g = draw_color.g;
  line->color.b = draw_color.b;
  line->color.a = draw_color.a;
  
  return line;
}

void ERPG_move_line(ERPG_Line * line,int x, int y)
{
  line->destination.x += x;
  line->destination.y += y;
  line->destination.w += x;
  line->destination.h += y;
}

void ERPG_scale_line(ERPG_Line * line, int w, int h)
{
  line->destination.w += w;
  line->destination.h += h;
}

void ERPG_set_color_line(ERPG_Line * line, SDL_Color color)
{
  line->color.r = color.r;
  line->color.g = color.g;
  line->color.b = color.b;
  line->color.a = color.a;
}

void ERPG_copy_line_to_renderer(ERPG_Line * line)
{
  ERPG_Window * window = ERPG_get_Window();
  Uint8 r = line->color.r;
  Uint8 g = line->color.g;
  Uint8 b = line->color.b;
  Uint8 a = line->color.a;
  
  SDL_SetRenderDrawBlendMode(window->renderer, 1);
  SDL_SetRenderDrawColor( window->renderer, r, g, b, a);
  
  SDL_RenderDrawLine(window->renderer,line->destination.x, line->destination.y,
		     line->destination.w, line->destination.h);
}

// ----------- LUA ................
ERPG_Line * Lua_check_line(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Line");
}
/**
 * Create line
 * @param Position as {x1,y1,x2,y2}
 * @param Color as {r,g,b,a}
 */
int Lua_make_line(lua_State * L)
{
  SDL_Rect * rect  = Lua_from_create_rect(L,1);
  SDL_Color * color = Lua_get_color(L,2);
  
  ERPG_Line * line = ERPG_make_line(*rect, *color);
  ERPG_Line * userdata = lua_newuserdata(L, sizeof(ERPG_Line));
  
  free(rect);
  free(color);

  memcpy(userdata,line,sizeof(ERPG_Line));
  free(line);

  luaL_setmetatable(L, "ERPG_Line");
  
  return 1;
}

/**
 * Copy line to renderer
 * @param Line
 */
int Lua_line_to_renderer(lua_State * L)
{
  ERPG_copy_line_to_renderer(Lua_check_line(L,1));
  return 0;
}
/**
 * Line move
 * @param Line
 * @param x
 * @param y
 */
int Lua_line_move(lua_State * L)
{
  ERPG_move_line(Lua_check_line(L,1), luaL_checkinteger(L,2), luaL_checkinteger(L,3));
  return 0;
}
/**
 * Line scale
 * @param Line
 * @param width
 * @param height
 */
int Lua_line_scale(lua_State * L)
{
  ERPG_scale_line(Lua_check_line(L,1), luaL_checkinteger(L,2), luaL_checkinteger(L,3));
  return 0;
}
/**
 * Line move
 * @param Line
 * @param Color as {r,g,b,a}
 */
int Lua_line_set_color(lua_State * L)
{
  SDL_Color * color = Lua_get_color(L,2);
  
  ERPG_set_color_line(Lua_check_line(L,1), *color);

  free(color);
  return 0;
}
/**
 * Open library Line
 */
int luaopen_ERPG_line(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"copy_to_renderer", Lua_line_to_renderer},
    {"move", Lua_line_move},
    {"scale", Lua_line_scale},
    {"set_color",Lua_line_set_color},
    {NULL,NULL}
  };

  static const luaL_Reg line[] = {
    {"make_line", Lua_make_line},
    {NULL,NULL}
  };

  luaL_newlib(L,line);
  luaL_newmetatable(L,"ERPG_Line");
  luaL_newlib(L,method);
  lua_setfield(L, -2, "__index");
  lua_pop(L,1);
  return 1;
}
