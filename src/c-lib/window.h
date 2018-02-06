#ifndef WINDOW_H
#define WINDOW_H
#include<SDL2/SDL.h>
#include<SDL2/SDL_ttf.h>
#include"list.h"
#include"mouse.h"
#include"keyboard.h"
#include"audio.h"
typedef struct{
  SDL_Window * window;
  SDL_Renderer *renderer;
  int fullscreen;
  int clip_x;
  int clip_y;
  SDL_Color * filter;
  List * list_of_sprite;
  List * list_of_fonts;
  SDL_Event * events;
  ERPG_Mouse * mouse;
  ERPG_Keyboard * keyboard;
  int width;
  int height;
  char exit;
  SDL_Texture * target_texture;
}ERPG_Window;

#include"text.h"
#include"sprite.h"
#include"basic_shapes.h"
#include"frame_text.h"

void ERPG_make_window(char * Tittle_window);
TTF_Font * ERPG_Window_add_font( char * path_of_font, int ptsize);
int ERPG_Toggle_fullscreen();
void ERPG_set_window_resolution( int w, int h);
void ERPG_set_blend_mode(SDL_Texture * texture, char mode);

//void ERPG_copy_sprite_to_renderer(ERPG_Window * window, ERPG_Sprite *sprite);
//void ERPG_copy_geom_shape_to_renderer(ERPG_Window * window, ERPG_Geometry_shape * geom);
//void ERPG_copy_text_to_renderer(ERPG_Window * window, ERPG_Text_Element * element);
//void ERPG_copy_block_text_to_renderer(ERPG_Window * window, ERPG_Frame_text * frame);
ERPG_Window * get_window();
ERPG_Audio * get_audio();

void ERPG_prepare();
void ERPG_update();
void ERPG_set_filter( int r, int g, int b);
int luaopen_ERPG_win(lua_State *L);
ERPG_Window * Lua_check_window(lua_State * L, int i);
void ERPG_Destroy_window();
SDL_DisplayMode ERPG_get_desktop_resolution();
int Lua_update(lua_State * L);
int Lua_prepare( lua_State * L);

#endif
