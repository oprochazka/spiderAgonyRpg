#ifndef BASIC_SHAPES_H
#define BASIC_SHAPES_H

typedef struct Point{
  int x;
  int y;
}Point;

typedef struct ERPG_Geometry_shape{
  const char * type; /* rect_fill, rect_empty, point, line, polygon*/
  SDL_Color *color;
  int blend_mode;
  Sint16 radian;
  Sint16 *x;
  Sint16 *y;
  int move_x;
  int move_y;
  int count;
  SDL_Rect src;
}ERPG_Geometry_shape;
/*
ERPG_Geometry_shape * create_basic_shape(Sint16 *x, Sint16 * y, int n,
					 SDL_Color * draw_color, int blend_mode);

ERPG_Geometry_shape * ERPG_make_empty_circle(Sint16 x, Sint16 y,
				       SDL_Color * draw_color, int blend_mode, Sint16 rad);
ERPG_Geometry_shape* ERPG_make_fill_circle(Sint16 x, Sint16 y,
					   SDL_Color * draw_color, int blend_mode, Sint16 rad);
ERPG_Geometry_shape * ERPG_make_rectangle(Sint16 *x, Sint16 * y,
					  SDL_Color * draw_color, int blend_mode);

ERPG_Geometry_shape * ERPG_make_empty_rectangle(Sint16 *x, Sint16 * y,
						SDL_Color * draw_color, int blend_mode);

ERPG_Geometry_shape * ERPG_make_point(Sint16 x, Sint16  y,
				      SDL_Color * draw_color, int blend_mode);


ERPG_Geometry_shape * ERPG_make_polygon(Sint16 *x, Sint16 * y, int n,
					SDL_Color * draw_color, int blend_mode);
ERPG_Geometry_shape * ERPG_make_empty_polygon(Sint16 *x, Sint16 * y, int n,
SDL_Color * draw_color, int blend_mode);*/
//for rectangle line point
void ERPG_move_geometry_shape(ERPG_Geometry_shape * geom, int x, int y);
//rectangle line
void ERPG_scale_geometry_shape(ERPG_Geometry_shape * geom, int w, int h);
void ERPG_change_blendmode_geometry_shape(ERPG_Geometry_shape * geom, int blend_mode);
void ERPG_destroy_geometry_shape(ERPG_Geometry_shape * geom);
ERPG_Geometry_shape * Lua_check_geometry_shape(lua_State * L, int i);
void ERPG_copy_geom_shape_to_renderer( ERPG_Geometry_shape * geom);

int luaopen_ERPG_geometry_shape(lua_State * L);

#endif
