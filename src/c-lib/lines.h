#ifndef LINES_H
#define LINES_H

typedef struct {
  SDL_Rect destination;
  SDL_Color color;
}ERPG_Line;

int luaopen_ERPG_line(lua_State * L);

#endif
