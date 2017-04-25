#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_ttf.h>
#include"main.h"
#include"text.h"
#include"window.h"
#include"lua_func.h"
#include"frame_text.h"
#include"list.h"
#include"core.h"


typedef struct Format_func{
  char * c;
  int (*my_func)(ERPG_Text_Element*,CList*,ERPG_Frame_text*, char * string, int);
}Format_func;

SDL_Texture * ERPG_text_make_block(ERPG_Frame_text *f);
void ERPG_create_frame_text_texture(ERPG_Frame_text * text, int w);
ERPG_Line_text * ERPG_Text_next_line(ERPG_Frame_text * f, CList * element_list);

int change_color(ERPG_Text_Element  * element, CList * elements,
		 ERPG_Frame_text * f,char * string, int index)
{
  int color[3]= {0,0,0};
  char buffer[4]={'\0','\0','\0','\0'};
  int it=0;
  int it2 = 0;
  int shift = 0;


  for(int i = index; it < 3;i++){
    if(string[i] == ','){
      color[it] = atoi(buffer);
      buffer[0] = '\0';
      buffer[1] = '\0';
      buffer[2] = '\0';
      it++;
      it2 = 0;
    }
    else if(string[i] >= '0' && string[i] <= '9'){
      buffer[it2] = string[i];
      it2++;
    }
    else if(it == 2){
       color[2] = atoi(buffer);
       break;
    }
    else{
      printf("ERROR: bad value for color! cant change color: %c\n",string[i]);
      return shift;
    }
    shift++;
  }
  ERPG_Text_element_change_color(element, color[0],color[1],color[2],255);
  return shift;
}
int font_size(ERPG_Text_Element * element,CList * elements, ERPG_Frame_text * f,char * string, int index)
{
  char buffer[4]={'\0','\0','\0','\0'};
  int i;
  int it=0;
  for( i= index; i < 3+index; i++){
    if(string[i] >= '0' && string[i] <= '9'){
      buffer[it] = string[i];
      it++;
    }
    else
      break;
  }
  if(i-index!=0)
    ERPG_Text_element_change_size_font(element, atoi(buffer));
  else
    printf("ERROR bad number: %c\n", string[index]);


  return i-index;
}
int next_line(ERPG_Text_Element * element, CList * elements, ERPG_Frame_text * f,char * string, int index)
{
  if(elements->root)
    ERPG_Text_next_line(f, elements);
  return 0;
}
int bold_text(ERPG_Text_Element * element,CList * elements, ERPG_Frame_text * f,char * string, int index)
{

  ERPG_Text_element_set_style(element, 1);
  return 0;
}
int normal_text(ERPG_Text_Element * element,CList * elements, ERPG_Frame_text * f,char * string, int index)
{
  ERPG_Text_element_set_style(element,0);
  return 0;
}

int italic_text(ERPG_Text_Element * element,CList * elements, ERPG_Frame_text * f,char * string, int index)
{
  ERPG_Text_element_set_style(element, 2);
  return 0;
}
int count = 7;
Format_func  format_chars[] ={{"?c:", change_color},
			      {"?n:", next_line},
			      {"?b:", bold_text},
			      {"?s:", normal_text},
			      {"?i:", italic_text},
			      {"?f:", font_size},
			      {NULL,NULL}};

Format_func compare_char_format(char * c)
{
 
  for(int i = 0; i < count -1 ; i++){
    if(!strcmp(format_chars[i].c,c)){
      return format_chars[i];
    }
  }
  return format_chars[count];
}

ERPG_Line_text * ERPG_Text_next_line(ERPG_Frame_text * f, CList * element_list)
{
  int max_w, max_h;
  CNode * temp = element_list->root;
  ERPG_Line_text * line;
  int width,height;
  get_max_size_of_elements(f, element_list, &max_w, &max_h);
  line = ERPG_text_make_line(element_list,0,
			     0,
			     max_w,max_h);
  
  while(temp){
    ERPG_Destroy_text_element((ERPG_Text_Element*)temp->value);
    free((ERPG_Text_Element*)temp->value);
    temp->value = NULL;
    temp = temp->next;
  }
  remove_clist(element_list);
  
  element_list->root = NULL;
  SDL_QueryTexture(line->texture, NULL, NULL, &width,&height);
  
  if(width > f->max_w)    
    f->max_w = width;
  f->max_h += height;
      
  add_cnode(f->line_list, line);
      
  return line;
}


ERPG_Frame_text * ERPG_create_frame_text(int x, int y,
					 const char * string, int max_w_line,
					 SDL_Rect *rect, char * path_font, SDL_Color color,
					 int style, int font_size)
{
  ERPG_Frame_text * out = (ERPG_Frame_text*)malloc(sizeof(ERPG_Frame_text));
  char * al_path = (char*)malloc(sizeof(char)*strlen(path_font)+1);
  strcpy(al_path,path_font);
  out->line_list = create_clist();
  out->clip_rect = rect;
  out->max_h = 0;
  out->max_w = 0;
  out->max_w_line = max_w_line;
  out->x = x;
  out->y = y;
  ERPG_format_text(out,string, ERPG_make_text_element(NULL, 0, 0, font_size,color,
						      al_path, style));
   return out;
}

void ERPG_format_text(ERPG_Frame_text * f,const char * string, ERPG_Text_Element * element)
{
  char * temp_string = (char*)malloc(sizeof(char)* strlen(string)+1);
  char * buffer = (char*)malloc(sizeof(char)*4);
  char c;
  Format_func temp_format_char;
  ERPG_Text_Element * base_element = element;
  ERPG_Text_Element * temp;
  int shift = 1;
  int temp_i = 0;
  int w,h;
  CList * element_list = create_clist();
  SDL_Texture * completly;
  char * al_path = NULL;

  buffer[3] = '\0';
  buffer[2] = '\0';
  buffer[1] = '\0';
  for(int i=0; i < strlen(string); i++){
    c = string[i];
    for(int x = 1; x < 3; x++){
      buffer[x-1] = buffer[x];
    }
    buffer[2] = c;

    temp_format_char = compare_char_format(buffer);
    if(c == ' '){
      temp_string[temp_i] = c;
      temp_string[temp_i+1] = '\0';
      if(strlen(temp_string) != 0){
	ERPG_Text_element_change_string( base_element, temp_string);
	ERPG_Text_Element_refresh( base_element );
      }
      get_max_size_of_elements_element(f, element_list, base_element, &w , &h);
      if(w > f->max_w_line ){
	next_line(base_element, element_list, f,NULL,i);
      }
      add_cnode(element_list, base_element);
      al_path = (char*)malloc(sizeof(char)*strlen(base_element->key_path_font)+1);
      strcpy(al_path,base_element->key_path_font);
      temp = ERPG_make_text_element( NULL,0,0,base_element->size,
				    base_element->color, al_path,
				     base_element->style);
      base_element = temp;
      temp_i = -1;
    }
    else if(temp_format_char.c == NULL)
      temp_string[temp_i] = c;
    else {
      temp_string[temp_i-2] = '\0';
      if(strlen(temp_string) != 0){
	ERPG_Text_element_change_string( base_element, temp_string);
	ERPG_Text_Element_refresh( base_element );
	add_cnode(element_list, base_element);
      }
      al_path = (char*)malloc(sizeof(char)*strlen(base_element->key_path_font)+1);
      strcpy(al_path,base_element->key_path_font);
      temp = ERPG_make_text_element( NULL,0,0,base_element->size,
				    base_element->color, al_path,
				    base_element->style);
      base_element = temp;
      shift = temp_format_char.my_func(base_element, element_list, f, (char*)string, i+1);
      i += shift;
      temp_i = -1;
    }
  
    temp_i++;
  }
  if(c != ' ')
      add_cnode(element_list, base_element);
  temp_string[temp_i] = '\0';
  ERPG_Text_element_change_string( base_element, temp_string);
  ERPG_Text_Element_refresh( base_element );
  ERPG_Text_next_line(f, element_list);
  completly =  ERPG_text_make_block(f);
  CNode * node = element_list->root;

  while( node ){
    ERPG_Destroy_text_element((ERPG_Text_Element*)node->value);
    node = node->next;
  }
  remove_clist(element_list);
  free(element_list);
  free(buffer);
  free(temp_string);
  f->texture = completly;
}

void get_max_size_of_elements_element(ERPG_Frame_text * f, CList * elements, ERPG_Text_Element *
				      element, int * max_w, int *max_h)
{
  int w1, h1, w2,h2;
  get_max_size_of_elements(f, elements, &w1,&h1);

  if(element->string){  
    ERPG_get_font_size( element->key_path_font, element->string, element->size,
		       &w2, &h2);
  
  *max_w = w1 + w2;
  *max_h = h1 + h2;
  }else
    printf("problem \n");
}
void get_max_size_of_elements(ERPG_Frame_text * f, CList * elements, int* max_w, int * max_h)
{
  CNode * node = elements->root;
  int w,h;
  *max_w = 0;
  *max_h = 0;
  ERPG_Text_Element * temp_element;
  while(node){
    temp_element = (ERPG_Text_Element*) node->value;
    ERPG_get_font_size( temp_element->key_path_font, temp_element->string,
		       temp_element->size,&w, &h);
    
    *max_w += w;
    if(h > *max_h)
      *max_h = h;
    node= node->next;
  }
}
  
ERPG_Line_text * ERPG_text_make_line(CList * text_elements, int x, int y, int w, int h)
{
  if(!(text_elements->root)){
    printf("ERRor make line NULL list \n");
    return NULL;
  }
  ERPG_Window * win = ERPG_get_Window();
  CNode* node = text_elements->root;
  ERPG_Text_Element * tmp_texture;
  int last_w = 0;
  ERPG_Line_text * line = (ERPG_Line_text*)malloc(sizeof(ERPG_Line_text));
  SDL_Texture * texture =  SDL_CreateTexture(win->renderer, SDL_PIXELFORMAT_RGBA8888,
					     SDL_TEXTUREACCESS_TARGET,w,h);
  int width, height;
  SDL_SetRenderTarget(win->renderer, texture);
  SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND); 
  SDL_SetRenderDrawColor(win->renderer, 0,0, 0,0); 

  while(node){
    tmp_texture = ((ERPG_Text_Element*)node->value);
    if( tmp_texture ){
      SDL_QueryTexture(tmp_texture->text_surface, NULL, NULL, &width, &height);

      SDL_RenderCopy(win->renderer,tmp_texture->text_surface, NULL, &(SDL_Rect){last_w,
	    h-height, width, height});
      
      last_w += width;
    }else
      printf("Texture ERROR \n");

    node = node->next;
  }  
  SDL_RenderPresent(win->renderer);
  SDL_SetRenderTarget(win->renderer, NULL);
  
  line->texture = texture;
  
  return line;
}

SDL_Texture * ERPG_text_make_block(ERPG_Frame_text * f)
{  
  CNode* node = f->line_list->root;
  int w = f->max_w;
  int h = f->max_h;
  ERPG_Line_text * line;
  int last_h = 0;
  int ac;
  ERPG_Window * win = ERPG_get_Window();
  SDL_Texture * texture =  SDL_CreateTexture(win->renderer, SDL_PIXELFORMAT_RGBA8888,
					     SDL_TEXTUREACCESS_TARGET,w,h);
  SDL_SetRenderTarget(win->renderer, texture);
  SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND); 
  SDL_SetRenderDrawColor(win->renderer, 0,0, 0,0);
  
  int width,height;
  while(node){
    line = (ERPG_Line_text*)node->value;
    SDL_QueryTexture(line->texture,
		     NULL,
		     &ac,
		     &width,
		     &height);   

    SDL_RenderCopy(win->renderer, line->texture, NULL, &(SDL_Rect){0, last_h, width,height});
    
    SDL_DestroyTexture(line->texture);

    last_h += height;
    node = node->next;
    free(line);
  }
  
  SDL_RenderPresent(win->renderer);
  SDL_SetRenderTarget(win->renderer, NULL);
  remove_clist(f->line_list);
  free(f->line_list);
  
  return texture;
}


void ERPG_Frame_text_set_clip_rect(ERPG_Frame_text * f, SDL_Rect * rect)
{
  free(f->clip_rect);
  f->clip_rect = rect;
}
SDL_Rect * ERPG_get_clip_rect(ERPG_Frame_text * f)
{
  return f->clip_rect;
}
int ERPG_Frame_text_get_max_width(ERPG_Frame_text * f)
{
  return f->max_w;
}
int ERPG_Frame_text_get_max_height(ERPG_Frame_text * f)
{
  return f->max_h;
}
void ERPG_Frame_text_set_max_clip(ERPG_Frame_text * f)
{
  f->clip_rect->w = f->max_w;
  f->clip_rect->h = f->max_h;
}
void ERPG_Frame_text_move(ERPG_Frame_text * f, int x, int y)
{
  f->x += x;
  f->y += y;
}
void ERPG_copy_block_text_to_renderer( ERPG_Frame_text * frame)
{
  ERPG_Window * window = get_window();
  SDL_RenderCopy(window->renderer, frame->texture,frame->clip_rect, &(SDL_Rect){frame->x, frame->y,
	  frame->clip_rect->w, frame->clip_rect->h} );
}
void ERPG_Destroy_frame_text(ERPG_Frame_text * f)
{
  
  free(f->clip_rect);
  SDL_DestroyTexture(f->texture);
}

/* ---------------------_EXPORT TO LUA----------------------------------

   ----------------------FRAME_TEXT----------------------------------
   
*/

ERPG_Frame_text * Lua_check_frame_text(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Frame_text");
}
/*
  describe: create frame text = frame text use for text of large size 
  args= window, string(string to frame), string(path to font), int(size of line),
  table(color), int(style!!!!!!!!!!), int(font size)
 */
int Lua_make_frame_text(lua_State * L)
{
  const char * string = luaL_checkstring(L,1);
  const char * path_font = luaL_checkstring(L, 2);
  int max_w_line = luaL_checkinteger(L,3);
  SDL_Color * color = Lua_get_color(L,4);
  int style = luaL_checkinteger(L,5);
  int font_size = luaL_checkinteger(L,6);
  SDL_Rect * rect = (SDL_Rect*)malloc(sizeof(SDL_Rect));
  
  ERPG_Frame_text * out = lua_newuserdata(L, sizeof(ERPG_Frame_text));
  ERPG_Frame_text * tmp = ERPG_create_frame_text(0, 0,
						 string, max_w_line,rect,
						 (char*)path_font, *color, style,font_size);
  free(color);
  memcpy(out, tmp, sizeof(ERPG_Frame_text));
  
  rect->x = 0;
  rect->y = 0;
  rect->w = out->max_w;
  rect->h = out->max_h;
  
  free(tmp);

  luaL_setmetatable(L, "ERPG_Frame_text");
  
  return 1;
}

int Lua_copy_frame_to_renderer(lua_State * L)
{
  ERPG_copy_block_text_to_renderer(Lua_check_frame_text(L,1));
  return 0;
}

/*
  describe: set visible clip of frame (for example: scrolling)
  args= self, table(rect)
 */
int Lua_Frame_text_set_clip(lua_State * L)
{
  ERPG_Frame_text * f = Lua_check_frame_text(L, 1);
  SDL_Rect * r = Lua_from_create_rect(L,2);
  ERPG_Frame_text_set_clip_rect(f, r);
  return 0;
}
/*
  describe: move frame
  args= self, int(x), int(y)
 */
int Lua_Frame_text_move(lua_State * L)
{
  ERPG_Frame_text * f = Lua_check_frame_text(L,1);
  ERPG_Frame_text_move(f, luaL_checkinteger(L,2), luaL_checkinteger(L,3));
  return 0;
}
/*
  describe: get pozition frame
  args= self
  return int(x), int(y)
 */
int Lua_Frame_text_get_pozition(lua_State * L)
{
  ERPG_Frame_text * f = Lua_check_frame_text(L,1);

  lua_pushnumber(L, f->x);
  lua_pushnumber(L, f->y);

  return 2;
}
/*
  describe: get size of frame
  args= self
  return int(w), int(h)
 */
int Lua_Frame_text_get_max_w_h(lua_State * L)
{
  ERPG_Frame_text * f = Lua_check_frame_text(L,1);
  
  lua_pushnumber(L, f->max_w);
  lua_pushnumber(L, f->max_h);

  return 2;
}
/*
  describe: current visible rect
  args= self
  return table_rect{x=int,y=int,w=int,h=int}
 */
int Lua_Frame_text_get_clip_rect(lua_State * L)
{
  SDL_Rect * rect = (Lua_check_frame_text(L,1))->clip_rect;
  lua_createtable(L, 0, 4);
  setfield(L, "x", rect->x);
  setfield(L, "y", rect->y);
  setfield(L, "w", rect->w);
  setfield(L, "h", rect->h);
  
  return 1;
}

int Lua_Frame_text_gc(lua_State * L)
{
  ERPG_Destroy_frame_text(Lua_check_frame_text(L,1));
  return 0;
}



int luaopen_ERPG_Frame_text(lua_State *L)
{
  static const luaL_Reg method[] = {
    {"move", Lua_Frame_text_move},
    {"get_pozition", Lua_Frame_text_get_pozition},
    {"set_clip", Lua_Frame_text_set_clip},
    {"get_max_clip", Lua_Frame_text_get_max_w_h},
    {"get_current_clip",Lua_Frame_text_get_clip_rect},
    {"copy_to_renderer", Lua_copy_frame_to_renderer},
    {NULL, NULL}
  };

  static const luaL_Reg frame_text_lib[] = {
    {"make", Lua_make_frame_text},
    {NULL, NULL}};

  luaL_newlib(L, frame_text_lib);

  luaL_newmetatable(L, "ERPG_Frame_text");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");

  lua_pushstring(L, "__gc");
  lua_pushcfunction(L, Lua_Frame_text_gc);
  lua_settable(L, -3);

  lua_pop(L, 1);
  
  return 1;
}
