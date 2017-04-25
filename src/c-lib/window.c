#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_mixer.h>
#include"main.h"
#include"basic_shapes.h"
#include"mouse.h"
#include"keyboard.h"
#include"core.h"
#include<time.h>
/*To DO! get current resolution and max resolution
  - možnost window_mode
*/

ERPG_Window * get_window()
{
  return ERPG_get_Window();
}
/**
   Call from C for initialize ERPG_Window and make window
   @param nameOfWindow
 */
void ERPG_make_window(char * Tittle_window)
{
  if (SDL_Init(SDL_INIT_VIDEO) < 0)
    SDL_GetError();

  if( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO ) < 0 )
      printf( "SDL could not initialize! SDL Error: %s\n", SDL_GetError() );
     
  if(TTF_Init()==-1) {
    printf("TTF_Init: %s\n", TTF_GetError());
  }

  
  int flags=IMG_INIT_JPG|IMG_INIT_PNG;
  int initted=IMG_Init(flags);
  if((initted & flags) != flags) {
   printf("IMG_Init: %s\n", IMG_GetError());
 }

  
  SDL_Window *screen = SDL_CreateWindow(Tittle_window,
					0, 0
					, 0, 0, //SDL_WINDOW_SHOWN				  
						SDL_WINDOW_FULLSCREEN_DESKTOP);
  
  SDL_Renderer *renderer = SDL_CreateRenderer(screen, -1, SDL_RENDERER_ACCELERATED |
					      SDL_RENDERER_PRESENTVSYNC |
					      SDL_RENDERER_TARGETTEXTURE );

  ERPG_CORE * core = ERPG_get_CORE();
  ERPG_Window * window;

  SDL_Event *event = (SDL_Event*)malloc(sizeof(SDL_Event));
  SDL_Color * color = (SDL_Color*)malloc(sizeof(SDL_Color));
  
  SDL_DisplayMode *mode = (SDL_DisplayMode*)malloc(sizeof(SDL_DisplayMode));

  core->window = (ERPG_Window*)malloc(sizeof(ERPG_Window));
  window = core->window;
  
  SDL_GetCurrentDisplayMode(0, mode);
  window->width = mode->w;
  window->height = mode->h;
  
  color->r = 0;
  color->g = 0;
  color->b = 0;
  color->a = 255;
  
  window->list_of_sprite = create_list();

  window->clip_x = 0;
  window->clip_y = 0;
  
  window->window = screen;
  window->renderer = renderer;

  window->mouse = ERPG_Create_mouse();
  window->keyboard = ERPG_Create_keyboard();
  
  window->exit = 1;
  window->filter = color;
  window->events = event;
  window->list_of_fonts = create_list();
  window->list_of_fonts->root = NULL;
  free(mode); 
}



TTF_Font* ERPG_Window_add_font(char * path_of_font, int ptsize)
{
  ERPG_Window * window = get_window();
  char * key_path = create_key_path(path_of_font, ptsize);
  TTF_Font *temp = (TTF_Font*)list_get_value(window->list_of_fonts, key_path);
  if( temp ){
    free(key_path);
    return temp;
  }

  TTF_Font * font = TTF_OpenFont(path_of_font, ptsize);
  if(!font)
    printf("Font can't load: %s\n", TTF_GetError());

  add_node(window->list_of_fonts, key_path, font);
  return font;
}


//
//předělat fci
  
int ERPG_Toggle_fullscreen() 
{
  ERPG_Window *win = get_window();
  Uint32 flags = (SDL_GetWindowFlags(win->window) ^ SDL_WINDOW_FULLSCREEN_DESKTOP);
  SDL_DisplayMode mode =ERPG_get_desktop_resolution();
  SDL_SetWindowSize(win->window, mode.w,mode.h);
  if (SDL_SetWindowFullscreen(win->window, flags) < 0) 
    { 
      printf("%s\n", SDL_GetError());
        return -1; 
    }
 
    int w = win->width;
    int h = win->height;  
    
    if ((flags & SDL_WINDOW_FULLSCREEN_DESKTOP) != 0) 
    {
      SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest"); 
      SDL_RenderSetLogicalSize(win->renderer, w, h);
      return 1; 
    }
    SDL_SetWindowSize(win->window, mode.w,mode.h);
    return 0; 
}

int ERPG_Toggle_fullscreen_cut()
{
  ERPG_Window * window = get_window();
  ERPG_Toggle_fullscreen(window);
  SDL_SetWindowSize(window->window, window->width,window->height);
  return 0;
}

void ERPG_set_window_resolution(int w, int h){
  ERPG_Window * window = get_window();
  window->width = w;
  window->height = h;
  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest"); 
  SDL_RenderSetLogicalSize(window->renderer, w, h);
}

void ERPG_set_filter(int r, int g, int b)
{
  ERPG_Window * window = get_window();
  window->filter->r = r;
  window->filter->g = g;
  window->filter->b = b;
}

/* Blend mods
   0 = SDL_BLENDMODE_BLEND
   1 = SDL_BLENDMODE_ADD
   2 = SDL_BLENDMODE_MODE
 */
void ERPG_set_blend_mode(SDL_Texture * texture, char mode)
{
  switch(mode){
  case 0: SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_NONE); break;
  case 1: SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_BLEND); break;
  case 2: SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_ADD); break;
  case 3: SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_MOD); break;
  }
}

SDL_DisplayMode ERPG_get_desktop_resolution()
{
  SDL_DisplayMode mode;
  SDL_GetCurrentDisplayMode(0, &mode);

  return mode;
}

void ERPG_Create_texture(ERPG_Window * window, SDL_Texture * texture, SDL_Rect * src, SDL_Rect dest)
{
  
  
  /* target_texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET,target_width, target_height);*/
}
void ERPG_prepare()
{
  ERPG_Window * win = get_window();
  ERPG_Mouse * mouse = win->mouse;
  ERPG_Keyboard * keyboard = win->keyboard;
  char * input_text = NULL;
  
  remove_clist(keyboard->release_key);
  //  remove_clist(win->keyboard->press_key);
  mouse->button->release = "none";
  mouse->button->on_press = "none";
  mouse->wheel->wheel_y = 0;
  mouse->wheel->wheel_x = 0;
  while( SDL_PollEvent( win->events )){
    ERPG_Pump_keyboard(win->events, keyboard);
    ERPG_pump_mouse(win->events, mouse);
    if(win->events->type == SDL_TEXTINPUT){
      input_text = (char*) malloc(sizeof(char)* 32);
      strcpy(input_text, win->events->text.text);    
    }
  }
  SDL_RenderClear(win->renderer);
}

void ERPG_Destroy_window()
{
  ERPG_Window * window = get_window();
  Node * free_list;

  free(window->filter);
  free(window->events);

  free_list = window->list_of_sprite->root;
  while(free_list){
    ERPG_List_img * tmp =(ERPG_List_img*)free_list->value;
    
    SDL_DestroyTexture(tmp->texture);
    SDL_FreeSurface(tmp->surface);
    free_list = free_list->next;
  }
  destroy_list(window->list_of_sprite);
  free(window->list_of_sprite); 
  free_list = window->list_of_fonts->root;
  while(free_list){
    TTF_CloseFont((TTF_Font*)free_list->value);
    free_list = free_list->next;
  } 
  destroy_list(window->list_of_fonts);
  free(window->list_of_fonts);
  ERPG_Destroy_mouse(window->mouse);
  ERPG_Destroy_keyboard(window->keyboard);

  SDL_DestroyRenderer(window->renderer);  
  SDL_DestroyWindow( window->window );
  
  free(window->mouse);
  free(window->keyboard);
}
void ERPG_update()
{
  ERPG_Window * win = get_window();

  SDL_SetRenderDrawColor(win->renderer, win->filter->r,win->filter->g,
  			 win->filter->b,win->filter->a); 
  SDL_RenderPresent(win->renderer);

}
/*Functions for Lua---------------------------
  -----------WINDOW---------------------
  self = window
 */
ERPG_Window * Lua_check_window(lua_State *L, int i){
  return luaL_checkudata(L, i, "ERPG_Window");
}

/**
 * Create window
 * @param nameOfWindow
*/
int Lib_Window(lua_State *L){
  luaL_setmetatable(L, "ERPG_Window");
  
  return 1;
}




/**
 * Toggle fullscreen 
 */
int Lua_window_toggle_fullscreen(lua_State *L){
  ERPG_Toggle_fullscreen();
  
  return 0;
}
/**
 * Color on background
 * @param red
 * @param green
 * @param blue
 * @param alpha
*/
int Lua_window_set_filter(lua_State *L){
  ERPG_set_filter(luaL_checkinteger(L,2),
	luaL_checkinteger(L,3),
	luaL_checkinteger(L,4));
  
  return 0;
}

/**
 * Set window resolution
 * @param width
 * @param height
*/
int Lua_window_set_resolution(lua_State *L){
  int w = luaL_checkinteger(L, 2);
  int h = luaL_checkinteger(L, 3);
  
  ERPG_set_window_resolution(w,h );
  
  return 0;
}

/**
 * Function for start event to input text
 */
int Lua_start_input_text(lua_State * L)
{
  SDL_StartTextInput();
  return 0;
}
/**
 * Function for stop event to input text
 */
int Lua_stop_input_text(lua_State * L)
{
  SDL_StopTextInput();
  return 0;
}



/**
 * Refresh events(mouse, keyboard, input text), clear render. For start new cycle.
 */
int Lua_prepare( lua_State * L)
{
 ERPG_Window * win = get_window();
  ERPG_Mouse * mouse = win->mouse;
  ERPG_Keyboard * keyboard = win->keyboard;
  CNode * node;
  char * input_text = NULL;
  
  remove_clist(keyboard->release_key);
  //  remove_clist(win->keyboard->press_key);
  mouse->button->release = "none";
  mouse->button->on_press = "none";
  mouse->wheel->wheel_y = 0;
  mouse->wheel->wheel_x = 0;
  while( SDL_PollEvent( win->events )){
    ERPG_Pump_keyboard(win->events, keyboard);
    ERPG_pump_mouse(win->events, mouse);
    if(win->events->type == SDL_TEXTINPUT){
      input_text = (char*) malloc(sizeof(char)* 32);
      strcpy(input_text, win->events->text.text);    
    }
  }

  
  SDL_RenderClear(win->renderer);
  lua_newtable(L);
  setfield(L,"x", mouse->x);
  setfield(L,"y", mouse->y);
  lua_pushstring(L, "press");
  lua_pushstring(L,  mouse->button->press_button);
  lua_settable(L, -3);
  lua_pushstring(L, "press_motion");
  lua_pushstring(L,  mouse->button->motion_button);
  lua_settable(L, -3);
  lua_pushstring(L, "release");
  lua_pushstring(L,  mouse->button->release);
  lua_settable(L, -3);
  lua_pushstring(L, "on_press");
  lua_pushstring(L,  mouse->button->on_press);
  lua_settable(L, -3);

  
  setfield(L,"wheel_y", mouse->wheel->wheel_y);
  setfield(L,"wheel_x", mouse->wheel->wheel_x);
  lua_setglobal(L, "mouse");
  //zacatek hnus ----------------------------
  lua_newtable(L);
  if(input_text){
    lua_pushstring(L, "input_key");
    lua_pushstring(L, input_text);
    lua_settable(L, -3);
    free(input_text);
  }
  
  lua_pushstring(L, "press");
  lua_newtable(L);
  node = keyboard->press_key->root;
  for(int i = 1; node; i++){
    lua_pushnumber(L,i);
    lua_pushstring(L,(char*)((char**)node->value)[0]);
    lua_settable(L, -3);
    node = node->next;
  }
  lua_settable(L, -3);
  lua_pushstring(L, "release");
  lua_newtable(L);
  node = keyboard->release_key->root;
  for(int i = 1; node; i++){
    lua_pushnumber(L,i);
    lua_pushstring(L,(char*)node->value);
    lua_settable(L, -3);
    node = node->next;
  }
  lua_settable(L, -3);
  //konec hnus ----------------------------
  lua_setglobal(L, "keyboard"); 

  return 0;
}


/**
 * Update render on finish draw cycle
 */
int Lua_update(lua_State * L)
{
  ERPG_update();
   return 0;
}
/**
 * For show or hid cursor
 * @param option(1=show, 0=hide)
 */
int Lua_show_cursor(lua_State * L)
{
  SDL_ShowCursor((int)luaL_checkinteger(L,2));
  return 0;
}
/**
 * Toggle fullscreen in mode cut means window have size of window not desktop resolution
 */
int Lua_toggle_fullscreen_cut(lua_State * L)
{
  ERPG_Toggle_fullscreen_cut();
  return 0;
}
/**
 * Get desktop resolution 
 * @return table as {width = window.w, height = window.h}
 */
int Lua_get_desktop_resolution(lua_State * L)
{
  SDL_DisplayMode mode = ERPG_get_desktop_resolution();

  lua_createtable(L, 0, 2);
  setfield(L, "width", mode.w);
  setfield(L, "height", mode.h);
  
  return 1;
}

/**
 * Get mouse pozition
 * @return x
 * @return y
 */
int Lua_get_mouse_position(lua_State * L)
{
  ERPG_Mouse * mouse = ERPG_get_Window()->mouse;
  
  lua_pushnumber(L, mouse->x);
  lua_pushnumber(L, mouse->y);
  
  return 2; 
}
/**
 * Get mouse press dont use remove
 * @return mousePress(string)
*/
int Lua_get_mouse_press(lua_State * L)
{
  ERPG_Mouse * mouse = ERPG_get_Window()->mouse;
  lua_pushstring(L,mouse->button->press_button);
  
  return 1;
}


int Lua_window_gc(lua_State *L){
  /*  printf("In Window__gc\n");
  ERPG_Window * win = lua_touserdata(L, 1);
  ERPG_Destroy_window(win);
  TTF_Quit();
  IMG_Quit();
  SDL_Quit();*/
  printf("window in gc \n");
 return 0;
}


int luaopen_ERPG_win(lua_State *L){
  static const luaL_Reg Obj_lib[] = {
    { "prepare_renderer", Lua_prepare},
    { "update_renderer", Lua_update},
    { "set_resolution", Lua_window_set_resolution},
    { "set_filter", Lua_window_set_filter},
    { "toggle_fullscreen", Lua_window_toggle_fullscreen},
    { "toggle_fullscreen_cut", Lua_toggle_fullscreen_cut},
    { "show_cursor", Lua_show_cursor},
    { "get_desktop_resolution", Lua_get_desktop_resolution},
    { "get_mouse_position", Lua_get_mouse_position},
    { "start_input_text", Lua_start_input_text},
    { "stop_input_text", Lua_stop_input_text},
    { NULL, NULL }
  };
  
  luaL_newlib(L, Obj_lib);
  
  return 1;   	       
}

