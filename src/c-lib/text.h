#ifndef TEXT_H
#define TEXT_H

typedef struct ERPG_Text_Element{
  char * string;
  char * key_path_font;
  char refresh;
  int style;
  int size;
  SDL_Rect destination;
  SDL_Rect src;
  SDL_Color color;
  SDL_Surface * surface;
  SDL_Texture * text_surface;
}ERPG_Text_Element;

ERPG_Text_Element* ERPG_make_text_element(const char * string, int x, int y,
					  int size, SDL_Color color,
					  char * path_font, int style);
char * create_key_path(char * path_font, int size);
void ERPG_get_font_size(char * path_font, char * string, int size,
			int * w, int* h);
void ERPG_Text_element_move(ERPG_Text_Element * element, int x, int y);
void ERPG_Text_element_change_color(ERPG_Text_Element * element, int r, int g, int b, int a);
void ERPG_Text_element_change_string(ERPG_Text_Element * element, const char * string);
void ERPG_Text_element_change_render_size(ERPG_Text_Element * element, SDL_Rect src);
void ERPG_Text_element_change_size_font(ERPG_Text_Element * element, int size);
void ERPG_Text_element_change_font(ERPG_Text_Element * element, char * path_font);
void ERPG_Text_element_set_style(ERPG_Text_Element * element, int style);
void ERPG_Destroy_text_element(ERPG_Text_Element * element);
void ERPG_Text_Element_refresh(ERPG_Text_Element * element );
void ERPG_copy_text_to_renderer( ERPG_Text_Element * element);

int luaopen_ERPG_Text_element(lua_State * L);
ERPG_Text_Element * Lua_check_text_element(lua_State * L, int i);
#endif
