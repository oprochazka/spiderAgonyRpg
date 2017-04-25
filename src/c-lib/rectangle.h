#ifndef RECTANGLE_H
#define RECTANGLE_H

typedef struct ERPG_Rectangle{
  SDL_Rect destination;
  SDL_Color color;
  int move_x;
  int move_y;
  char empty;
}ERPG_Rectangle;


void ERPG_copy_rect_to_renderer(ERPG_Rectangle * rect);
int luaopen_ERPG_Rectangle(lua_State * L);

#endif
