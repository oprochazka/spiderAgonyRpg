#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include"main.h"
#include"core.h"
#include"basic_shapes.h"
#include"rectangle.h"
#include"lua_func.h"


ERPG_Rectangle * ERPG_make_ERPG_rectangle_empty(SDL_Rect rect, SDL_Color draw_color)
{
  ERPG_Rectangle * rectangle = (ERPG_Rectangle*)malloc(sizeof(ERPG_Rectangle));

  rectangle->destination.x = rect.x;
  rectangle->destination.y = rect.y;
  rectangle->destination.w = rect.w;
  rectangle->destination.h = rect.h;

  rectangle->color.r = draw_color.r;
  rectangle->color.g = draw_color.g;
  rectangle->color.b = draw_color.b;
  rectangle->color.a = draw_color.a;

  rectangle->empty=1;
    
  rectangle->move_x = 0;
  rectangle->move_y = 0;
  
  return rectangle;
}

ERPG_Rectangle * ERPG_make_ERPG_rectangle(SDL_Rect rect, SDL_Color draw_color)
{
  ERPG_Rectangle * rectangle = ERPG_make_ERPG_rectangle_empty(rect, draw_color);

  rectangle->empty = 0;
  
  return rectangle;
}

void ERPG_move_rect(ERPG_Rectangle * rect, int x, int y)
{
  rect->destination.x += x;
  rect->destination.y += y;
}
void ERPG_scale_rect(ERPG_Rectangle * rect, int w, int h)
{
  rect->destination.w += w;
  rect->destination.h += h;
}

void ERPG_set_color_rect(ERPG_Rectangle * rect, SDL_Color color)
{
  rect->color.r = color.r;
  rect->color.g = color.g;
  rect->color.b = color.b;
  rect->color.a = color.a;
}

void ERPG_copy_rect_to_renderer(ERPG_Rectangle * rect)
{
  ERPG_Window * window = ERPG_get_Window();
  Uint8 r = rect->color.r;
  Uint8 g = rect->color.g;
  Uint8 b = rect->color.b;
  Uint8 a = rect->color.a;
  
  SDL_SetRenderDrawBlendMode(window->renderer, 1);
  SDL_SetRenderDrawColor( window->renderer, r, g, b, a);

  if( !rect->empty ){
    SDL_RenderFillRect( window->renderer,	&(SDL_Rect){rect->destination.x,rect->destination.y,
	  rect->destination.w - rect->move_x,
	  rect->destination.h - rect->move_y});
  }else{
     SDL_RenderDrawRect( window->renderer,	&(SDL_Rect){rect->destination.x,rect->destination.y,
	  rect->destination.w - rect->move_x,
	  rect->destination.h - rect->move_y});
  }
}

// ------------------ EXPORT LUA ----------

ERPG_Rectangle * Lua_check_rect(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Rectangle");
}

/**
 * Create Rect
 * @param Position as {x,y,w,h}
 * @param Color as {r,g,b,a}
 */
int Lua_make_ERPG_rect(lua_State * L)
{
  SDL_Rect * rect  = Lua_from_create_rect(L,1);
  SDL_Color * color = Lua_get_color(L,2);
  
  ERPG_Rectangle * rectangle = ERPG_make_ERPG_rectangle(*rect, *color);
  ERPG_Rectangle * userdata = lua_newuserdata(L, sizeof(ERPG_Rectangle));
  
  free(rect);
  free(color);


  
  memcpy(userdata,rectangle,sizeof(ERPG_Rectangle));
  free(rectangle);

  luaL_setmetatable(L, "ERPG_Rectangle");
  
  return 1;
}
/**
 * Empty Rect
 * @param Position as {x,y,w,h}
 * @param Color as {r,g,b,a}
 */
int Lua_make_ERPG_rect_empty(lua_State * L)
{
  SDL_Rect * rect  = Lua_from_create_rect(L,1);
  SDL_Color * color = Lua_get_color(L,2);
  
  ERPG_Rectangle * rectangle = ERPG_make_ERPG_rectangle_empty(*rect, *color);
  ERPG_Rectangle * userdata = lua_newuserdata(L, sizeof(ERPG_Rectangle));
  
  free(rect);
  free(color);


  
  memcpy(userdata,rectangle,sizeof(ERPG_Rectangle));
  free(rectangle);

  luaL_setmetatable(L, "ERPG_Rectangle");
  
  return 1;
}
/**
 * Copy rect to renderer
 * @param rect
 */
int Lua_ERPG_rect_to_renderer(lua_State * L)
{
  ERPG_copy_rect_to_renderer(Lua_check_rect(L,1));
  return 0;
}
/**
 * Rect move
 * @param rect
 * @param x
 * @param y
 */
int Lua_ERPG_rect_move(lua_State * L)
{
  ERPG_move_rect(Lua_check_rect(L,1), luaL_checkinteger(L,2), luaL_checkinteger(L,3));
  return 0;
}
/**
 * Rect scale
 * @param rect
 * @param width
 * @param height
 */
int Lua_ERPG_rect_scale(lua_State * L)
{
  ERPG_scale_rect(Lua_check_rect(L,1), luaL_checkinteger(L,2), luaL_checkinteger(L,3));
  return 0;
}
/**
 * Rect move
 * @param Rect
 * @param Color as {r,g,b,a}
 */
int Lua_ERPG_rect_set_color(lua_State * L)
{
  ERPG_Rectangle * g = Lua_check_rect(L,1);

  g->color.r = luaL_checkinteger(L,2);
  g->color.g = luaL_checkinteger(L,3);
  g->color.b = luaL_checkinteger(L,4);
  g->color.a = luaL_checkinteger(L,5);

  return 0;
}
/**
 * Set rect position
 * @param Rect
 * @param posX
 * @param posY
 */
int Lua_set_ERPG_rect_position(lua_State * L)
{
  ERPG_Rectangle * sprite = Lua_check_rect(L,1);
  sprite->destination.x = luaL_checkinteger(L,2);
  sprite->destination.y = luaL_checkinteger(L,3);
  return 0;
}
/**
 * Get rect 
 * @param Rect
 * @return rect as {x=x,y=y,w=w,h=h}
 */
int Lua_get_ERPG_rect(lua_State * L)
{
  ERPG_Rectangle * geom = Lua_check_rect(L, 1);

  rect_to_table(L, &geom->destination);
  
  return 1;
}
/**
 * Get rect position
 * @param Rect
 * @return posX
 * @return posY
 */
int Lua_ERPG_rect_get_position(lua_State * L)
{
  ERPG_Rectangle * g = Lua_check_rect(L,1);
  lua_pushnumber(L, g->destination.x);
  lua_pushnumber(L, g->destination.y);

  return 2;
}
/**
 * Get rect width, height
 * @param Rect
 * @return width
 * @return height
 */
int Lua_ERPG_rect_get_width_height(lua_State * L)
{
  ERPG_Rectangle * g = Lua_check_rect(L,1);

  lua_pushnumber(L,g->destination.w);
  lua_pushnumber(L,g->destination.h);
  
  return 2; 
}
/**
 * Get rect 
 * @param Rect
 * @return rect as {x=move_x,y=move_y,w=w,h=h}
 */
int Lua_get_size_ERPG_rect(lua_State * L)
{
  ERPG_Rectangle * geom = Lua_check_rect(L, 1);
  SDL_Rect  rect; //= (SDL_Rect*) malloc(sizeof(SDL_Rect));

  rect.x = geom->move_x;
  rect.y = geom->move_y;
  rect.w = geom->destination.w;
  rect.h = geom->destination.h;

  rect_to_table(L, &rect);
  
  return 1;
}
/**
 * Set rect size
 * @param Rect
 * @param x
 * @param y
 * @param width
 * @param height
 */
int Lua_set_shape_ERPG_rect(lua_State * L)
{
  ERPG_Rectangle * geom = Lua_check_rect(L, 1);

  geom->move_x = luaL_checkinteger(L,2);
  geom->move_y = luaL_checkinteger(L,3);
  geom->destination.w = luaL_checkinteger(L,4)+luaL_checkinteger(L,2);
  geom->destination.h = luaL_checkinteger(L,5)+luaL_checkinteger(L,3);
    
  return 0;
}

int luaopen_ERPG_Rectangle(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"move", Lua_ERPG_rect_move},
    {"copy_to_renderer", Lua_ERPG_rect_to_renderer},
    {"get_pozition", Lua_ERPG_rect_get_position},
    {"get_rect", Lua_get_ERPG_rect},
    {"set_color", Lua_ERPG_rect_set_color},
    {"scale",Lua_ERPG_rect_scale},
    {"set_size", Lua_set_shape_ERPG_rect},
    {"get_size", Lua_get_size_ERPG_rect},
    {"set_position", Lua_set_ERPG_rect_position},
    {"get_position", Lua_ERPG_rect_get_position},
    {"get_width_height", Lua_ERPG_rect_get_width_height},
    {NULL, NULL}
  };
  static const luaL_Reg geometry_lib[] = {
    {"make_rectangle", Lua_make_ERPG_rect},
    {"make_empty_rectangle", Lua_make_ERPG_rect_empty},
    {NULL, NULL}
  };
  
  luaL_newlib(L, geometry_lib);
  luaL_newmetatable(L, "ERPG_Rectangle");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");

  lua_pop(L,1);
  return 1;
}
