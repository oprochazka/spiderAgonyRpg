#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include"main.h"
#include"basic_shapes.h"
#include"lua_func.h"

ERPG_Geometry_shape * create_basic_shape(Sint16 *x, Sint16 * y, int n,
					 SDL_Color * draw_color, int blend_mode)
{
  ERPG_Geometry_shape * out = (ERPG_Geometry_shape*) malloc(sizeof(ERPG_Geometry_shape));
  out->color = draw_color;
  out->blend_mode = blend_mode;
  out->x = x; 
  out->y = y;
  out->move_x = 0;
  out->move_y = 0;
  out->count = n;
  return out;
}

ERPG_Geometry_shape * ERPG_make_empty_circle(Sint16 x, Sint16 y,
				       SDL_Color * draw_color, int blend_mode, Sint16 rad)
{
  Sint16 * mx = (Sint16*)malloc(sizeof(Sint16));
  Sint16 * my = (Sint16*)malloc(sizeof(Sint16));
  
  ERPG_Geometry_shape * out = create_basic_shape(mx, my, 1, draw_color, blend_mode);
  out->type = "circle_empty";

  out->radian = rad;

  return out;
}
//very slow
ERPG_Geometry_shape* ERPG_make_fill_circle(Sint16 x, Sint16 y,
					   SDL_Color * draw_color, int blend_mode, Sint16 rad)
{
  ERPG_Geometry_shape * out = ERPG_make_empty_circle(x, y, draw_color, blend_mode, rad);

  out->type = "circle_fill";

  return out;
}

ERPG_Geometry_shape * ERPG_make_rectangle(Sint16 *x, Sint16 * y,
					  SDL_Color * draw_color, int blend_mode)
{
    ERPG_Geometry_shape * out = create_basic_shape(x, y, 4, draw_color, blend_mode);
    
    out->type = "rect_fill";
    /* out->type->src.x = x[0];
    out->type->src.w = x[1];
    out->type->src.y = y[0];
    out->type->src.h = y[1];*/
    return out;
 }

ERPG_Geometry_shape * ERPG_make_empty_rectangle(Sint16 *x, Sint16 * y,
						SDL_Color * draw_color, int blend_mode)
{
  ERPG_Geometry_shape * out = create_basic_shape(x, y, 4, draw_color, blend_mode);
  
  out->type = "rect_empty";
  /*  out->type->src.x = x[0];
  out->type->src.w = x[1];
  out->type->src.y = y[0];
  out->type->src.h = y[1];*/
  return out;
}

ERPG_Geometry_shape * ERPG_make_point(Sint16 x, Sint16 y,
					 SDL_Color * draw_color, int blend_mode)
{
  Sint16 * mx = (Sint16*)malloc(sizeof(Sint16));
  Sint16 * my = (Sint16*)malloc(sizeof(Sint16));
  *mx = x;
  *my = y;
  ERPG_Geometry_shape * out = create_basic_shape(mx, my, 1, draw_color, blend_mode);
  out->type = "point";
  
  return out;
}

/*ERPG_Geometry_shape * ERPG_make_line(Sint16* x, Sint16* y,
				      SDL_Color * draw_color, int blend_mode)
{
  ERPG_Geometry_shape * out = create_basic_shape(x, y, 2, draw_color, blend_mode);
  
  out->type = "line";
  
  return out;
  }*/
//very slow
ERPG_Geometry_shape * ERPG_make_polygon(Sint16 *x, Sint16 * y, int n,
					SDL_Color * draw_color, int blend_mode)
{
  ERPG_Geometry_shape * out = create_basic_shape(x, y, n, draw_color, blend_mode);
  
  out->type = "polygon";

  return out;
}

ERPG_Geometry_shape * ERPG_make_empty_polygon(Sint16 *x, Sint16 * y, int n,
					SDL_Color * draw_color, int blend_mode)
{
  ERPG_Geometry_shape * out = create_basic_shape(x, y, n, draw_color, blend_mode);
  
  out->type = "polygon_empty";

  return out;
}

//for rectangle line point
void ERPG_move_geometry_shape(ERPG_Geometry_shape * geom, int x, int y)
{
  geom->x[0] = (Sint16)x;
  geom->y[0] = (Sint16)y;
}

//rectangle line
void ERPG_scale_geometry_shape(ERPG_Geometry_shape * geom, int w, int h)
{
  if(!strcmp(geom->type,"point"))
    return;
  geom->x[1] = (Sint16)w;
  geom->y[1] = (Sint16)h;
}
//set color

void ERPG_set_color_geometry_shape(ERPG_Geometry_shape * geom, SDL_Color * color)
{
  geom->color = color;
}

void ERPG_change_color_geometry_shape(ERPG_Geometry_shape * geom, SDL_Color *color)
{
  geom->color = color;
}

void ERPG_change_blendmode_geometry_shape(ERPG_Geometry_shape * geom, int blend_mode)
{
  geom->blend_mode = blend_mode;
}

void ERPG_destroy_geometry_shape(ERPG_Geometry_shape * geom)
{
  free(geom->color);
  free(geom->x);
  free(geom->y);
}

void ERPG_copy_geom_shape_to_renderer( ERPG_Geometry_shape * geom)
{
  ERPG_Window * window = get_window();
  Uint8 r = geom->color->r;
  Uint8 g = geom->color->g;
  Uint8 b = geom->color->b;
  Uint8 a = geom->color->a;
  
  SDL_SetRenderDrawBlendMode(window->renderer, geom->blend_mode);
  SDL_SetRenderDrawColor( window->renderer, r, g, b, a);
  
  if(!strcmp( geom->type, "rect_fill")){
    SDL_RenderFillRect( window->renderer,
			&(SDL_Rect){geom->x[0],geom->y[0],
			    geom->x[1] - geom->move_x,
			    geom->y[1] - geom->move_y});
    return;
  }
  if(!strcmp( geom->type, "rect_empty") ){
    SDL_RenderDrawRect( window->renderer,
			&(SDL_Rect){geom->x[0],geom->y[0],
			    geom->x[1],geom->y[1]});
    return;
  }
  if(!strcmp( geom->type, "line")){
    SDL_RenderDrawLine(window->renderer,geom->x[0],geom->y[0],geom->x[1],geom->y[1]);
    return;
  }
  if(!strcmp( geom->type, "polygon")){
    filledPolygonRGBA(window->renderer, geom->x, geom->y, geom->count, r,g,b,a);
    return;
  }
  if(!strcmp( geom->type, "polygon_empty")){
    polygonRGBA(window->renderer, geom->x, geom->y, geom->count, r,g,b,a);
    return;
  }
  if(!strcmp(geom->type,"circle_empty")){
    circleRGBA (window->renderer, *geom->x, *geom->y, geom->radian, r, g, b, a);
    return;
  }
  if(!strcmp(geom->type,"circle_fill")){
    filledCircleRGBA (window->renderer, *geom->x, *geom->y, geom->radian, r, g, b, a);
    return;
  }
  if(!strcmp( geom->type, "point"))
    SDL_RenderDrawPoint(window->renderer, *geom->x, *geom->y);
}

//---------------EXPORT TO LUA---------------------------------------------------------

ERPG_Geometry_shape * Lua_check_geometry_shape(lua_State * L, int i)
{
  ERPG_Geometry_shape * g = luaL_checkudata(L, i, "ERPG_Geometry_shape");
    
  return g;
}

int Lua_copy_shape_to_renderer(lua_State * L)
{
  ERPG_copy_geom_shape_to_renderer(Lua_check_geometry_shape(L,1));
  return 0;
}

int Lua_geometry_shape_init(lua_State * L, Sint16 * x, Sint16 * y, SDL_Color * color)
{
  SDL_Rect * color_rect;
  SDL_Rect * size_rect;
  size_rect = Lua_from_create_rect(L,1);
  color_rect = Lua_from_create_rect(L,2);
  
  color->r = color_rect->x;
  color->g = color_rect->y;
  color->b = color_rect->w;
  color->a = color_rect->h;

  x[0] = size_rect->x;
  x[1] = size_rect->w;
  y[0] = size_rect->y;
  y[1] = size_rect->h;

  free(size_rect);
  free(color_rect);
  
  return 0;
}

//create rect: {x,y,w,h},{r,g,b,a}, blend_mode
int Lua_Geometry_shape(lua_State * L,char * name)
{
  int blend_mode= luaL_checkinteger(L,3);
  Sint16 * x = (Sint16*)malloc(sizeof(Sint16)*2);
  Sint16 * y = (Sint16*)malloc(sizeof(Sint16)*2);
  SDL_Color * color = (SDL_Color*)malloc(sizeof(SDL_Color));
  int n = luaL_len(L,1);
  ERPG_Geometry_shape * shape;
  ERPG_Geometry_shape * lua_geometry = lua_newuserdata(L, sizeof(ERPG_Geometry_shape));
  
  Lua_geometry_shape_init(L,x,y,color);
  shape = create_basic_shape(x,y,n,color,blend_mode);
  shape->type = name;
  memcpy(lua_geometry,shape,sizeof(ERPG_Geometry_shape));
  free(shape);

  return 0;
}
// args : { x,y,w,h}, {r,g,b,a}, blend_mode
int Lua_Geometry_shape_rect(lua_State * L)
{
  Lua_Geometry_shape(L,"rect_fill");
  luaL_setmetatable(L, "ERPG_Geometry_shape");
  return 1;
}
int Lua_Geometry_shape_empty_rect(lua_State * L)
{
  Lua_Geometry_shape(L,"rect_empty");
  luaL_setmetatable(L, "ERPG_Geometry_shape");
  return 1;
}
int Lua_Geometry_shape_line(lua_State * L)
{
  Lua_Geometry_shape(L, "line");
  luaL_setmetatable(L, "ERPG_Geometry_shape");  
  return 1;
}
int Lua_Geometry_shape_point(lua_State * L)
{
  int blend_mode = luaL_checkinteger(L,4);
  SDL_Color * color = Lua_get_color(L, 3);
  ERPG_Geometry_shape * point = ERPG_make_point(luaL_checkinteger(L,1),luaL_checkinteger(L,2),
						color, blend_mode);
  ERPG_Geometry_shape * lua_geometry = lua_newuserdata(L, sizeof(ERPG_Geometry_shape));

  memcpy(lua_geometry,point,sizeof(ERPG_Geometry_shape));
  free(point);
  luaL_setmetatable(L, "ERPG_Geometry_shape");  
  return 1;
}

//argumenty x:{1,20,10....} y: {20, 30,10 ..} color:{color}, blend_mode
int Lua_Geometry_shape_polygon(lua_State * L,
			       ERPG_Geometry_shape* (*func)(Sint16*,Sint16*,int,SDL_Color*,int))
{
  int blend_mode = luaL_checkinteger(L,4);
  SDL_Color * color = Lua_get_color(L, 3);
  int table_len = luaL_len(L,1);
  Sint16 * x = Lua_get_sint16_from_table(L,1, table_len);
  Sint16 * y = Lua_get_sint16_from_table(L,2, table_len);
  
  ERPG_Geometry_shape * polygon = func(x,y,table_len,color,blend_mode);
  ERPG_Geometry_shape * lua_geometry = lua_newuserdata(L, sizeof(ERPG_Geometry_shape));

  memcpy(lua_geometry,polygon,sizeof(ERPG_Geometry_shape));
  free(polygon);
  luaL_setmetatable(L, "ERPG_Geometry_shape");
  return 0;
}

int Lua_Geometry_shape_empty_polygon(lua_State * L)
{
  Lua_Geometry_shape_polygon(L, ERPG_make_empty_polygon);
  return 1;
}
int Lua_Geometry_shape_fill_polygon(lua_State * L)
{
  Lua_Geometry_shape_polygon(L, ERPG_make_polygon);
  return 1;
}
// METHODS----------------------------------------
int Lua_scale_shape(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L,1);
  if(!strcmp(geom->type, "rect_fill") || !strcmp(geom->type, "rect_empty")){
    ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L,1);
    geom->x[1] += luaL_checkinteger(L,2);
    geom->y[1] += luaL_checkinteger(L,3);
  }
  return 0;
}

int Lua_Geometry_shape_move(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L,1);
  if(!strcmp(geom->type, "polygon") || !strcmp(geom->type, "empty_polygon")){
    for(int i = 0; i < geom->count; i++){
      geom->x[i] += luaL_checkinteger(L,2);
      geom->y[i] += luaL_checkinteger(L,3);
    }
    return 0;
  }
  geom->x[0] += luaL_checkinteger(L,2);
  geom->y[0] += luaL_checkinteger(L,3);
  return 0;
}
// return x, y rect line point in polygon return first x,y 
int Lua_Geometry_shape_get_pozition(lua_State * L)
{
  ERPG_Geometry_shape *g = Lua_check_geometry_shape(L, 1);
  
  lua_pushnumber(L, g->x[0]);
  lua_pushnumber(L, g->y[0]);

  return 2;
}
//arguments r,g,b,a
int Lua_set_color_geometry_shape(lua_State * L)
{
  ERPG_Geometry_shape * g = Lua_check_geometry_shape(L,1);
  g->color->r = luaL_checkinteger(L,2);
  g->color->g = luaL_checkinteger(L,3);
  g->color->b = luaL_checkinteger(L,4);
  g->color->a = luaL_checkinteger(L,5);

  return 0;
}
//set points to !!!!polygon only!!!! args: {x1,x2,x3 ...}, {y1,y2,y3 ...}
int Lua_set_polygon_points(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L, 1);
  int len =luaL_len(L,2);
  Sint16 * x = Lua_get_sint16_from_table(L, 2, len);
  Sint16 * y = Lua_get_sint16_from_table(L, 3, len);

  free(geom->x);
  free(geom->y);

  geom->x = x;
  geom->y = y;

  return 0;
}

int Lua_get_rect(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L, 1);
  SDL_Rect  rect; //= (SDL_Rect*) malloc(sizeof(SDL_Rect));

  rect.x = (int)geom->x[0];
  rect.y = (int)geom->y[0];
  rect.w = (int)geom->x[1];
  rect.h = (int)geom->y[1];

  rect_to_table(L, &rect);
  
  return 1;
}
int Lua_get_size_rect(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L, 1);
  SDL_Rect  rect; //= (SDL_Rect*) malloc(sizeof(SDL_Rect));

  rect.x = geom->move_x;
  rect.y = geom->move_y;
  rect.w = (int)geom->x[1];
  rect.h = (int)geom->y[1];

  rect_to_table(L, &rect);
  
  return 1;
}
int Lua_set_shape_rect(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L, 1);
  if( strcmp(geom->type, "rect_fill") && strcmp(geom->type, "rect_empty")){
    printf("ERROR: set_size only for Rectangle! \n");
    return 0;
  }
  //  SDL_Rect * rect = (SDL_Rect*) malloc(sizeof(SDL_Rect));

  geom->move_x = luaL_checkinteger(L,2);
  geom->move_y = luaL_checkinteger(L,3);
  geom->x[1] = luaL_checkinteger(L,4)+luaL_checkinteger(L,2);
  geom->y[1] = luaL_checkinteger(L,5)+luaL_checkinteger(L,3);
    
  return 0;
}
int Lua_get_points(lua_State * L)
{
  ERPG_Geometry_shape * geom = Lua_check_geometry_shape(L, 1);
  char * str = (char*) malloc(sizeof(char) * 15);

 
  lua_createtable(L, 0, 2);
  lua_pushstring(L, "x");
  lua_createtable(L,0,geom->count);
  for(int i = 0; i < geom->count; i++){
    sprintf(str, "%d", i);
    setfield(L, str, geom->x[i]);
  }
  lua_settable(L, -3);
  lua_pushstring(L,"y");
  lua_createtable(L,0,geom->count);
  for(int i = 0; i < geom->count; i++){
    sprintf(str, "%d", i);
    setfield(L, str, geom->y[i]);
  }
  lua_settable(L, -3);
  free(str);
  return 1;
}
int Lua_set_shape_position(lua_State * L)
{
  ERPG_Geometry_shape * sprite = Lua_check_geometry_shape(L,1);
  sprite->x[0] = luaL_checkinteger(L,2);
  sprite->y[0] = luaL_checkinteger(L,3);
  return 0;
}

int Lua_rect_get_position(lua_State * L)
{
  ERPG_Geometry_shape * g = Lua_check_geometry_shape(L,1);
  lua_pushnumber(L, g->x[0]);
  lua_pushnumber(L, g->y[0]);

  return 2;
}

int Lua_rect_get_width_height(lua_State * L)
{
  ERPG_Geometry_shape * g = Lua_check_geometry_shape(L,1);

  lua_pushnumber(L,g->x[1]);
  lua_pushnumber(L,g->y[1]);
  
  return 2; 
}
int Lua_geometry_gc(lua_State * L)
{
  ERPG_Geometry_shape * g = Lua_check_geometry_shape(L, 1);

  ERPG_destroy_geometry_shape(g);

  return 0;
}

int luaopen_ERPG_geometry_shape(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"move", Lua_Geometry_shape_move},
    {"copy_to_renderer", Lua_copy_shape_to_renderer},
    {"get_pozition", Lua_Geometry_shape_get_pozition},
    {"get_points", Lua_get_points},
    {"get_rect", Lua_get_rect},
    {"set_points", Lua_set_polygon_points},
    {"set_color", Lua_set_color_geometry_shape},
    {"scale",Lua_scale_shape},
    {"set_size", Lua_set_shape_rect},
    {"get_size", Lua_get_size_rect},
    {"set_position", Lua_set_shape_position},
    {"get_position", Lua_rect_get_position},
    {"get_width_height", Lua_rect_get_width_height},
    {NULL, NULL}
  };
  static const luaL_Reg geometry_lib[] = {
    {"make_rectangle", Lua_Geometry_shape_rect},
    {"make_empty_rectangle", Lua_Geometry_shape_empty_rect},
    //  {"make_line", &Lua_Geometry_shape_line},
    {"make_point", Lua_Geometry_shape_point},
    {"make_polygon", Lua_Geometry_shape_fill_polygon},
    {"make_empty_polygon", Lua_Geometry_shape_empty_polygon},
    {NULL, NULL}
  };
  
  luaL_newlib(L, geometry_lib);
  luaL_newmetatable(L, "ERPG_Geometry_shape");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");

  lua_pushstring(L, "__gc");
  lua_pushcfunction(L, Lua_geometry_gc);
  lua_settable(L, -3);
  lua_pop(L,1);
  return 1;
}
