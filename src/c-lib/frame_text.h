#ifndef FRAME_TEXT_H
#define FRAME_TEXT_H
#include "text.h"

typedef struct ERPG_Frame_text{
  CList * line_list;
  SDL_Rect * clip_rect;
  SDL_Texture * texture;
  int max_w;
  int max_h;
  int x;
  int y;
  int max_w_line;
}ERPG_Frame_text;

typedef struct ERPG_Line_text{
  SDL_Texture * texture;
}ERPG_Line_text;

void get_max_size_of_elements(ERPG_Frame_text * f, CList * elements, int* max_w, int * max_h);
void get_max_size_of_elements_element(ERPG_Frame_text * f, CList * elements, ERPG_Text_Element *
				      element, int * max_w, int *max_h);

ERPG_Line_text * ERPG_text_make_line(CList * text_elements, int x, int y, int w, int h);
void ERPG_format_text(ERPG_Frame_text * f,const char * string, ERPG_Text_Element * element);

ERPG_Frame_text * ERPG_create_frame_text(int x, int y,
					 const char * string, int max_w_line,
					 SDL_Rect *rect, char * path_font, SDL_Color color,
					 int style, int font_size);

void ERPG_Frame_text_set_max_clip(ERPG_Frame_text * f);
void ERPG_Frame_text_move(ERPG_Frame_text * f, int x, int y);
void ERPG_Frame_text_set_clip_rect(ERPG_Frame_text * f, SDL_Rect * rect);
SDL_Rect * ERPG_Frame_text_get_clip_rect(ERPG_Frame_text * f);
int ERPG_Frame_text_get_max_width(ERPG_Frame_text * f);
int ERPG_Frame_text_get_max_height(ERPG_Frame_text * f);
void ERPG_copy_block_text_to_renderer( ERPG_Frame_text * frame);

void ERPG_Destroy_frame_text(ERPG_Frame_text * f);

ERPG_Frame_text * Lua_check_frame_text(lua_State * L, int i);
int luaopen_ERPG_Frame_text(lua_State *L);

#endif
