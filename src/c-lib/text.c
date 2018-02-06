#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_ttf.h>
#include"main.h"
#include"core.h"
#include"list.h"
#include"text.h"
#include"window.h"
#include"lua_func.h"
//ptsize = basically translates to pixel height

char * create_key_path(char * path_font, int size)
{
  int len = strlen(path_font);
  char buf[4];
  char * key_path = (char*)malloc(sizeof(char)* len + 5);
  
  sprintf(buf, "%d", size);
  strcpy(key_path,buf);
  strcat(key_path,path_font);
  
  return key_path;
}
ERPG_Text_Element* ERPG_make_text_element( const char * string, int x, int y,
				      int size, SDL_Color color,
					  char * path_font, int style)
{
  ERPG_Window * window = get_window();
  ERPG_Text_Element * out = (ERPG_Text_Element*)malloc(sizeof(ERPG_Text_Element));
  SDL_Surface * surface = NULL;
  char * new_string = NULL;
  out->text_surface = NULL;

  SDL_Rect destination;
  SDL_Rect src;
  
  out->size = size;
  out->color.r = color.r;
  out->color.g = color.g;
  out->color.b = color.b;
  out->color.a = color.a;
  
  out->key_path_font = path_font;
  out->refresh = 0;
  out->style =  style;

  if( string && strlen(string) != 0 ){   
    new_string = (char*)malloc(sizeof(char)*strlen(string)+1);
    sprintf(new_string, "%s" , string);
    
    TTF_Font * font;
     
    font = ERPG_Window_add_font( path_font, size);
    
   
    if(font)
      surface = TTF_RenderUTF8_Blended(font,
				       new_string,
				       out->color);
    
    if(!surface)
      printf("ERROR font isn't load \n");

    src.x = 0;
    src.y = 0;
    src.w = surface->w;
    src.h = surface->h;
    
    destination.x = x;
    destination.y = y;
    destination.w = surface->w;
    destination.h = surface->h;
    
    out->text_surface = SDL_CreateTextureFromSurface(window->renderer, surface);
    out->destination = destination;
    out->src = src;
    
    SDL_FreeSurface(surface);
  }else{    
    src.x = 0;
    src.y = 0;
    src.w = 0;
    src.h = 0;
    
    destination.x = 0;
    destination.y = 0;
    destination.w = 0;
    destination.h = 0;
    
    out->destination = destination;
    out->src = src;
    
    out->text_surface = NULL;
  }
  
  out->string = new_string;
  out->surface = surface;
  
  return out;
}

void ERPG_Text_element_move(ERPG_Text_Element * element, int x, int y)
{
  element->destination.x += x;
  element->destination.y += y;
}

void ERPG_Text_element_change_color(ERPG_Text_Element * element, int r, int g, int b, int a)
{
  element->color.r = r;
  element->color.g = g;
  element->color.b = b;
  element->color.a = a;
  element->refresh = 1;
}

void ERPG_Text_Element_refresh(ERPG_Text_Element * element )
{
  ERPG_Window * window = ERPG_get_Window();
  SDL_Surface * surface;
  TTF_Font * font= ERPG_Window_add_font(element->key_path_font, element->size);
  TTF_SetFontStyle(font, element->style);
  surface = TTF_RenderUTF8_Blended(font, element->string, element->color);
  element->destination.w = surface->w + element->destination.w - element->src.w;
  element->destination.h = surface->h + element->destination.h - element->src.h;
  element->src.w = surface->w;
  element->src.h = surface->h;
  SDL_DestroyTexture(element->text_surface);
  element->text_surface = SDL_CreateTextureFromSurface(window->renderer, surface);
  SDL_FreeSurface(surface);
}

void ERPG_Text_element_change_string(ERPG_Text_Element * element, const char * string)
{
  if( strlen(string) == 0 ){
    if(element->string)
      free(element->string);
    element->string = NULL;
    SDL_DestroyTexture(element->text_surface);
    element->text_surface = NULL;
    return;
  }
  
  char * new_str = (char*)malloc(sizeof(char)*strlen(string)+1);
  if(!element){
    printf("Text element == NULL \n");
    return;
  }
  sprintf(new_str,"%s", string);
  if(element->string)
    free(element->string);
  
  element->string = new_str;
  element->refresh = 1;
}

void ERPG_Text_element_change_render_size(ERPG_Text_Element * element, SDL_Rect src)
{
  ERPG_Text_Element * sprite = element;
  int w = 0, h = 0;
  int plus_x;
  int plus_y;
  int plus_w;
  int plus_h;
  if(sprite->text_surface){
    SDL_QueryTexture(sprite->text_surface, NULL,NULL,&w,&h);
    plus_x = src.x;
    plus_y= src.y;
    plus_w =  src.w+(w-sprite->destination.w);
    plus_h =  src.h+(h-sprite->destination.h);
    if(w < plus_w)
      plus_w = w;
    if(h< plus_h)
      plus_h = h;
    if(0> plus_x)
      plus_x = 0;
    if(0 > plus_y)
      plus_y = 0;
    
    sprite->src.x = plus_x;
    sprite->src.y = plus_y;
    sprite->src.w = plus_w;
    sprite->src.h = plus_h;
  }  
}

void ERPG_Text_element_change_size_font(ERPG_Text_Element * element, int size)
{
  element->size = size;
  if(element->text_surface)
    element->refresh = 1;
}

void ERPG_Text_element_change_font(ERPG_Text_Element * element, char * path_font)
{
  element->key_path_font = path_font;
  element->refresh = 1;
}

void ERPG_Text_element_set_style(ERPG_Text_Element * element, int style)
{
  switch(style){
  case 0: element->style = TTF_STYLE_NORMAL;break;
  case 1: element->style = TTF_STYLE_BOLD; break;
  case 2: element->style = TTF_STYLE_ITALIC; break;
  case 3: element->style = TTF_STYLE_UNDERLINE; break;
  case 4: element->style = TTF_STYLE_STRIKETHROUGH; break;
  }
  element->refresh = 1;
}

void ERPG_get_font_size(char * path_font, char * string, int size,
			int * w, int* h)
{
  TTF_Font* font = ERPG_Window_add_font( path_font, size);
  
  TTF_SizeUTF8(font,string , w, h);

}

void ERPG_get_font_size_slow(/*ERPG_Window * window,*/ char * path_font, char * string, int size,
			int * w, int* h)
{
  TTF_Font* font; // = ERPG_Window_add_font(window, path_font, size);

  font = TTF_OpenFont(path_font, size);
  
  TTF_SizeUTF8(font,string , w, h);

  TTF_CloseFont(font);
}
void ERPG_Text_set_alpha(ERPG_Text_Element * element, char alpha, char mode)
{
  ERPG_set_blend_mode(element->text_surface, mode);
  SDL_SetTextureAlphaMod( element->text_surface, alpha );
}

void ERPG_Text_set_color_modulation(ERPG_Text_Element * element, char r, char g, char b, char mode)
{
  ERPG_set_blend_mode(element->text_surface, mode);
  SDL_SetTextureColorMod( element->text_surface, r, g, b );
}

void ERPG_Destroy_text_element(ERPG_Text_Element * element)
{
  if(element->string)
    free(element->string);  
  if(element->key_path_font)
    free(element->key_path_font);
  if(element->text_surface)
    SDL_DestroyTexture(element->text_surface);
}


void ERPG_copy_text_to_renderer( ERPG_Text_Element * element)
{
  ERPG_Window * window = ERPG_get_Window();
  SDL_Surface * surface;

  if(element->refresh){

    TTF_Font * font= ERPG_Window_add_font(element->key_path_font, element->size);
    TTF_SetFontStyle(font, element->style);
    surface = TTF_RenderUTF8_Blended(font, element->string, element->color);
    element->destination.w = surface->w + element->destination.w - element->src.w;
    element->destination.h = surface->h + element->destination.h - element->src.h;
    element->src.w = surface->w;
    element->src.h = surface->h;
    SDL_DestroyTexture(element->text_surface);
    element->text_surface = SDL_CreateTextureFromSurface(window->renderer, surface);
  }
  SDL_Rect r_dest;
  
  int w = 0,h = 0;

  SDL_QueryTexture(element->text_surface, NULL, NULL,  &w, &h);
 
  r_dest.x = element->destination.x;
  r_dest.y = element->destination.y;
  r_dest.w = element->src.w - (w - element->destination.w);
  r_dest.h = element->src.h - (h - element->destination.h);

  if( element->text_surface )
    SDL_RenderCopy(window->renderer, element->text_surface,&element->src,
		   &r_dest);
 
  element->refresh = 0;
}

void ERPG_Text_Element_size_texture(ERPG_Text_Element * element, int *w, int * h)
{
  
}

/*--------------------------------EXPORT To LUA -------------

  ------------------------TEXT ELEMENT--------------------------

*/
ERPG_Text_Element * Lua_check_text_element(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Text_Element");
}
/*
 * type= Text_Element
 * describe= For managment with text
 */

/**
 * Create text element
 * @param fontPath
 * @param string
 * @param posX
 * @param posY
 * @param sizeText
 * @param color as {r,g,b,a}
*/
int Lua_make_text_element(lua_State * L)
{
  const char * path  = luaL_checkstring(L, 1);
  const char * string = luaL_checkstring(L, 2);
  int x = luaL_checkinteger(L,3);
  int y = luaL_checkinteger(L,4);
  int size = luaL_checkinteger(L, 5);
  SDL_Color * color = Lua_get_color(L, 6);
  char * new_path = (char*)malloc(sizeof(char)*strlen(path)+1);
  strcpy(new_path, path);
  
  
  ERPG_Text_Element * new_element = lua_newuserdata(L, sizeof(ERPG_Text_Element));
  ERPG_Text_Element * temp = ERPG_make_text_element(string, x, y, size, *color,
						    new_path, TTF_STYLE_NORMAL);


  free(color);

  memcpy(new_element, temp, sizeof(ERPG_Text_Element));

  free(temp);
  
  luaL_setmetatable(L, "ERPG_Text_Element");
  
  return 1;
}
/**
 * Text copy to renderer
 * @param textElem
 */
int Lua_copy_text_to_renderer(lua_State * L)
{
  ERPG_copy_text_to_renderer(Lua_check_text_element(L,1));
  return 0;
}
/**
 * Text move
 * @param textElem
 * @param x
 * @param y
 */
int Lua_text_move(lua_State * L)
{
  ERPG_Text_element_move(Lua_check_text_element(L,1), luaL_checkinteger(L,2),
			 luaL_checkinteger(L,3));
  return 0;
}
/**
 * Text change color
 * @param textElem
 * @param red
 * @param green
 * @param blue
 * @param alpha
 */
int Lua_text_change_color(lua_State * L)
{
  ERPG_Text_element_change_color(Lua_check_text_element(L, 1), luaL_checkinteger(L,2),
				 luaL_checkinteger(L,3), luaL_checkinteger(L,4),
				 luaL_checkinteger(L,5));
  return 0;
}
/**
 * Text change string
 * @param textElem
 * @param string
 */
int Lua_text_change_string(lua_State * L)
{
  const char * str = luaL_checkstring(L, 2); 
  ERPG_Text_element_change_string(Lua_check_text_element(L,1), str); 
  return 0;
}
/**
 * Text change font size
 * @param textElem 
 * @param fontSize
 */
int Lua_text_change_font_size(lua_State * L)
{
  ERPG_Text_element_change_size_font(Lua_check_text_element(L, 1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Text scale
 * @param textElem
 * @param scaleW
 * @param scaleH
 */
int Lua_text_change_render_size(lua_State * L)
{
  SDL_Rect  src;
  src.x = luaL_checkinteger(L,2);
  src.y = luaL_checkinteger(L,3);
  src.w = luaL_checkinteger(L,4);
  src.h = luaL_checkinteger(L,5);
  
  ERPG_Text_element_change_render_size(Lua_check_text_element(L,1), src);

  return 0;
}
/**
 * Text change font
 * @param textElem 
 * @param fontPath
 */
int Lua_text_change_font(lua_State * L)
{
  const char * path = luaL_checkstring(L,2);
  char * new_path = (char*)malloc(sizeof(char)*strlen(path)+1);
  
  ERPG_Text_element_change_font(Lua_check_text_element(L,1), new_path);
  return 0;
}

/**
 * Text set color modulation
 * @param textElem
 * @param red
 * @param green
 * @param blue
 * @param alpha
 */
int Lua_text_set_color_modulation(lua_State * L)
{
  ERPG_Text_set_color_modulation(Lua_check_text_element(L,1), luaL_checkinteger(L,2),
				 luaL_checkinteger(L,3), luaL_checkinteger(L,4),
				 luaL_checkinteger(L, 5));
  return 0;
}

/**
 * Text set alpha
 * @param textElem
 * @param alpha
 * @param colorMode(0-2)
 */
int Lua_text_set_alpha(lua_State * L)
{
  ERPG_Text_set_alpha(Lua_check_text_element(L,1), luaL_checkinteger(L,2),
		      luaL_checkinteger(L,3));
  
  return 0;
}
/**
 * Text set style, bold, italic
 * @param textElem
 * @param styleMode(0-2)
 */
int Lua_text_set_style(lua_State * L)
{
  ERPG_Text_element_set_style(Lua_check_text_element(L,1), luaL_checkinteger(L,2));
  return 0;
}
/**
 * Text get size
 * @param fontPath
 * @param string
 * @param sizeFont
 */
int Lua_get_font_size(lua_State * L)
{
  int w, h;
  ERPG_get_font_size((char*) luaL_checkstring(L,1),
		     (char*)luaL_checkstring(L,2), luaL_checkinteger(L,3), &w,&h);

  lua_pushnumber(L, w);
  lua_pushnumber(L,h);
  
  return 2;
}
/**
 * Text get position
 * @param textElem
 * @return posX
 * @return posY
 */
int Lua_get_text_pozition(lua_State * L)
{
  ERPG_Text_Element * text = Lua_check_text_element(L, 1);

  lua_pushnumber(L,text->destination.x);
  lua_pushnumber(L,text->destination.y);

  return 2;
}
/**
 * Text set scale
 * @param textElem
 * @param scaleW
 * @param scaleH
 */
int Lua_set_text_scale(lua_State * L)
{
  ERPG_Text_Element * sprite = Lua_check_text_element(L,1);

  sprite->destination.w += luaL_checkinteger(L,2);
  sprite->destination.h += luaL_checkinteger(L,3);
  return 0;
}
/**
 * Text get scale
 * @param textElem
 * @return scaleW
 * @return scaleH
 */
int Lua_get_text_scale(lua_State * L)
{
  ERPG_Text_Element * text = Lua_check_text_element(L,1);

  lua_pushnumber(L, text->destination.w);
  lua_pushnumber(L, text->destination.h);
  
  return 2;
}
int Lua_text_element_gc(lua_State * element)
{
  ERPG_Destroy_text_element(Lua_check_text_element(element, 1));
  return 0;
}
/**
 * Text set position
 * @param textElem
 * @param posX
 * @param posY
 */
int Lua_set_text_position(lua_State * L)
{
  ERPG_Text_Element * sprite = Lua_check_text_element(L,1);
  sprite->destination.x = luaL_checkinteger(L,2);
  sprite->destination.y = luaL_checkinteger(L,3);
  return 0;
}
/**
 * Text get size
 * @param textElem
 * @return size
 */
int Lua_text_get_size(lua_State * L)
{
  ERPG_Text_Element * sprite = Lua_check_text_element(L,1);
  int w = 0, h = 0;

  SDL_QueryTexture(sprite->text_surface, NULL,NULL,&w,&h);
  
  rect_to_table(L,&(SDL_Rect){sprite->src.x,sprite->src.y,
	sprite->src.w+ (w- sprite->destination.w),
	sprite->src.h+ (h- sprite->destination.h)});
   
  return 1;
}

int luaopen_ERPG_Text_element(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"move", Lua_text_move},
    {"scale", Lua_set_text_scale},
    {"copy_to_renderer", Lua_copy_text_to_renderer},
    {"change_color", Lua_text_change_color},
    {"change_string", Lua_text_change_string},
    {"change_font", Lua_text_change_font},
    {"change_size", Lua_text_change_font_size},
    {"set_style", Lua_text_set_style},
    {"get_position", Lua_get_text_pozition},
    {"set_color_modulation", Lua_text_set_color_modulation},
    {"set_alpha", Lua_text_set_alpha},
    {"set_size", Lua_text_change_render_size},
    {"set_position", Lua_set_text_position},
    {"get_size", Lua_text_get_size},
    {NULL, NULL}
  };

  static const luaL_Reg text_element_lib[] = {
    {"make_text", Lua_make_text_element},
    {"get_size", Lua_get_font_size},
    {NULL, NULL}
  };

  luaL_newlib(L, text_element_lib);

  luaL_newmetatable(L, "ERPG_Text_Element");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");
  
  //lua_pushstring(L, "__gc");
  lua_pushcfunction(L, Lua_text_element_gc);
  lua_setfield(L, -2, "__gc");
  //  lua_settable(L, -3);

  lua_pop(L,1);
  
  return 1;
}
