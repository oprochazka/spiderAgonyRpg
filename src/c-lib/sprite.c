#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <png.h>
#include"main.h"
#include"core.h"
#include"list.h"
#include"lua_func.h"
#include"sprite.h"
#include"rectangle.h"
//dovolit změnit nastavit paletu
//ještě zkusit o vytvoření většího surfacu z několika obrazku a zakomponovat to do engine

ERPG_Sprite* ERPG_create_target_texture(SDL_Texture * texture)
{
	int tmp_w = 0;
	int tmp_h = 0;
	ERPG_Window * win = ERPG_get_Window();

	ERPG_Sprite * s = (ERPG_Sprite*)malloc(sizeof(ERPG_Sprite));
	s->src.x = 0;
	s->src.y = 0;
	s->duplicite = SDL_FALSE;
	s->destination.x = 0;
	s->destination.y = 0;
	s->act_clip_x = 0;
	s->act_clip_y = 0;
	s->count_clips_x = 1;
	s->count_clips_y = 1;
	s->path = "tempt";
	s->rectangles = NULL;
	s->texture = texture;
	s->surface_clip_rect = NULL;
	SDL_QueryTexture(s->texture, NULL, NULL, &tmp_w,&tmp_h);
	s->src.w = tmp_w;
	s->src.h = tmp_h;
	s->destination.w = tmp_w;
	s->destination.h = tmp_h;
	s->color_modulate.r = 255;
	s->color_modulate.g = 255;
	s->color_modulate.b = 255;
	s->alpha = 255;
	s->mode = 1;
	s->compose = SDL_TRUE;
	s->angle = 0;

	SDL_SetRenderTarget(win->renderer, NULL);

	return s;
}

void ERPG_prepare_target_texture(SDL_Texture* texture)
{
	ERPG_Window * win = ERPG_get_Window();

	SDL_SetRenderTarget(win->renderer, texture);

	SDL_RenderFillRect(win->renderer,NULL);
	SDL_RenderCopy(win->renderer,texture,NULL,NULL);
	SDL_SetRenderDrawColor(win->renderer, 0,0, 0,255);
}

SDL_Surface * load_surface(char * path)
{
  SDL_Surface* loadedSurface = NULL;
  loadedSurface = IMG_Load( path );
   if( loadedSurface == NULL )
   {
        printf( "Unable to load image %s! SDL_image Error: %s\n", path, IMG_GetError() );
	return NULL;
   }

  return loadedSurface;
}

///vytvořit funkci set_pixel
void ERPG_set_pixel_color(SDL_Surface * surface, int x, int y, SDL_Color * color)
{
  SDL_PixelFormat *fmt;
  int width = surface->w;
  int n = (y*width)+x;

  fmt = surface->format;
  SDL_LockSurface(surface);
  
  ((Uint8*)surface->pixels)[n*fmt->BytesPerPixel] = color->r;
  ((Uint8*)surface->pixels)[n*fmt->BytesPerPixel+1] = color->g;
  ((Uint8*)surface->pixels)[n*fmt->BytesPerPixel+2] = color->b;
  
  if(fmt->BytesPerPixel == 4)
    ((Uint8*)surface->pixels)[n*fmt->BytesPerPixel] = color->a;
  
  SDL_UnlockSurface(surface);
}



SDL_Surface * create_clip_surface(SDL_Surface * surface, SDL_Rect * clip)
{
    Uint32 rmask, gmask, bmask, amask;

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
    rmask = 0xff000000;
    gmask = 0x00ff0000;
    bmask = 0x0000ff00;
    amask = 0x000000ff;
#else
    rmask = 0x000000ff;
    gmask = 0x0000ff00;
    bmask = 0x00ff0000;
    amask = 0xff000000;
#endif

    SDL_Surface * out = SDL_CreateRGBSurface(0,clip->w,clip->h,32,rmask,gmask,bmask,amask);
    
    if(surface){
      SDL_BlitSurface(surface,clip, out,NULL);
    }
    return out;
}

//To DO! vybrani si ze surface vyhřez
//set rectangle structure ---- actual rectangle manual set
//if surface null -> image load else choose surface from list
int load_texture_to_sprite(ERPG_Sprite * sprite, SDL_Texture * surface, char * path,
				     SDL_Color * color, SDL_Rect * clip_rect)
{
  ERPG_Window * win = get_window();

  SDL_Texture* newTexture = NULL;
  SDL_Surface* loadedSurface = NULL;

  if(surface){    
    sprite->texture = surface;
  }
  else {
    loadedSurface = load_surface(path);
    
    if(!loadedSurface){
      return 0;
    }
    if(clip_rect)
      loadedSurface = create_clip_surface(loadedSurface, clip_rect);
    if( color)
      SDL_SetColorKey( loadedSurface, SDL_TRUE, SDL_MapRGB( loadedSurface->format, color->r,
							    color->g, color->b ) );
        
    newTexture = SDL_CreateTextureFromSurface( win->renderer, loadedSurface );

    if( !newTexture )
      printf( "Unable to create texture from %s! SDL Error: %s\n", path, SDL_GetError() );
	    
    sprite->texture = newTexture;
    if(newTexture){
      ERPG_List_img * save = (ERPG_List_img*)malloc(sizeof(ERPG_List_img));
      char * path_alloc = (char*)malloc(sizeof(char)*strlen(path)+1);
      strcpy(path_alloc, path);
      save->surface = loadedSurface;
      save->texture = newTexture;
      save->path = path_alloc;
      add_node(win->list_of_sprite, path_alloc, save);
      sprite->path = path_alloc;	
    }

  }
    
  return 1;
}

//count clips x and y are count of clips in image for x, y 
ERPG_Sprite * ERPG_make_sprite(char * path ,SDL_Color * color,
			       SDL_Rect *clip_rect)
{
  ERPG_Sprite * s = (ERPG_Sprite*) malloc(sizeof(ERPG_Sprite));
  
  ERPG_Window * win = get_window();
  // SDL_Surface * surface = (SDL_Surface*)list_get_value( win->list_of_sprite, path );
  ERPG_List_img * surface = (ERPG_List_img*)list_get_value( win->list_of_sprite, path );
  int tmp = 1;
  
  if(surface)
    load_texture_to_sprite(s,surface->texture, path,color,clip_rect);
  else
    tmp = load_texture_to_sprite(s,NULL, path,color,clip_rect);
  
  if(!tmp){
    free(s);
    return NULL;
  }

  SDL_Rect destination;
  int w, h;

  SDL_QueryTexture(s->texture, NULL, NULL,&w,&h);
  
  destination.x = 0;
  destination.y = 0;
  destination.w = w;
  destination.h = h;

  s->destination = destination;
  s->angle = 0;
  s->act_clip_x = 0;
  s->act_clip_y = 0;

  s->count_clips_x = 1;
  s->count_clips_y = 1;
  s->rectangles = NULL;

    SDL_Rect rect;// = (SDL_Rect*)malloc(sizeof(SDL_Rect));
    
  rect.x = 0;
  rect.y = 0;  
  rect.w = w;
  rect.h = h;

  s->compose = SDL_FALSE;
  
  s->src = rect;      
  s->surface_clip_rect = clip_rect;

  s->color_modulate.r = 255;
  s->color_modulate.g = 255;
  s->color_modulate.b = 255;

  if( surface )
    s->path = surface->path;
  
  s->alpha = 255;

  s->mode = 1;
    
  return s;
}

void  ERPG_sprite_set_texture(ERPG_Sprite * sprite, SDL_Texture * texture)
{
  int ac = 20;
  //  SDL_DestroyTexture(sprite->texture);
  sprite->texture = texture;
  SDL_QueryTexture(texture,
		   NULL,
                   &ac,
                   &sprite->src.w,
                   &sprite->src.h);
  
}

void  ERPG_set_clips_sprite(ERPG_Sprite * sprite, int count_clips_x,int count_clips_y)
{
  int w,h;
  
  SDL_QueryTexture(sprite->texture,NULL,NULL,&w,&h);
  
  sprite->rectangles = NULL;
  
  sprite->count_clips_x = count_clips_x;
  sprite->count_clips_y = count_clips_y;

  sprite->src.w = w/count_clips_x;
  sprite->src.h = h/count_clips_y;
  
  if( count_clips_y != 0)
    sprite->destination.h = h / count_clips_y;
  
  if( count_clips_x != 0 )
  sprite->destination.w = w/ count_clips_x;
}

void ERPG_set_clips_rect_sprite(ERPG_Sprite * sprite, SDL_Rect * rectangles, int n)
{
  sprite->rectangles = rectangles;
  sprite->count_clips_x = n;
  sprite->count_clips_y = -1;
  sprite->act_clip_x = 0;
  sprite->destination.w = rectangles[0].w;
  sprite->destination.h = rectangles[0].h;
}

void ERPG_set_current_clip_rect_sprite(ERPG_Sprite * sprite, int x)
{
  sprite->act_clip_x = 0;
  sprite->destination.w = sprite->rectangles[x].w;
  sprite->destination.h = sprite->rectangles[x].h;
}

void ERPG_move_sprite(ERPG_Sprite * sprite, int x, int y)
{
  sprite->destination.x += x;
  sprite->destination.y += y;
}

void ERPG_scale_sprite(ERPG_Sprite * sprite, int w, int h)
{
  sprite->destination.w += w;
  sprite->destination.h += h;
}
SDL_Rect ERPG_get_source_sprite(ERPG_Sprite * sprite )
{
  int cx = sprite->act_clip_x;
  int cy = sprite->act_clip_y;
  
  int w_scale = sprite->destination.w - sprite->src.w;
  int h_scale = sprite->destination.h - sprite->src.h;
  SDL_Rect out;
  int w=0,h=0;

  SDL_QueryTexture(sprite->texture, NULL, NULL, &w,&h);

  int size_w = w/sprite->count_clips_x;
  int size_h = h/sprite->count_clips_y;
  
  out.x = cx * size_w;
  out.y = cy * size_h;
  out.w = w_scale + sprite->src.w;
  out.h = h_scale + sprite->src.h;

  return out;
}
void ERPG_set_current_clip_sprite(ERPG_Sprite * sprite, int cx, int cy)
{
  sprite->act_clip_x = cx;
  sprite->act_clip_y = cy;
}



void ERPG_set_sprite_alpha(ERPG_Sprite * sprite, char alpha, char mode)
{
  sprite->alpha = alpha;
  sprite->mode = mode;
  

}

void ERPG_set_color_modulation(ERPG_Sprite * sprite, char r, char g, char b, char mode)
{
  sprite->color_modulate.r = r;
  sprite->color_modulate.g = g;
  sprite->color_modulate.b = b;
  sprite->mode = mode;

}

void ERPG_sprite_destroy(ERPG_Sprite * sprite)
{
  //  if (sprite->texture)
  // SDL_DestroyTexture(sprite->texture);     
  if(sprite->rectangles)
    free(sprite->rectangles);
  if(sprite->surface_clip_rect)
    free(sprite->surface_clip_rect);

  // free(sprite->path);
}


void ERPG_destroy_whole_sprite(ERPG_Sprite * sprite)
{
	SDL_DestroyTexture(sprite->texture);
	ERPG_sprite_destroy(sprite);
}

SDL_Color * ERPG_find_pixel_color(SDL_Surface *loadedSurface, int x, int y)
{
    SDL_PixelFormat *fmt;
    SDL_Color * out_color = (SDL_Color*)malloc(sizeof(SDL_Color));
    int width = loadedSurface->w;
    int n = (y*width)+x;
    fmt = loadedSurface->format;
    Uint8  * pixel8 = (Uint8*)malloc(sizeof(Uint8)*fmt->BytesPerPixel);


    out_color->a = 255;
    SDL_LockSurface(loadedSurface);

    for(int i = 0; i < fmt->BytesPerPixel; i++){
      pixel8[i] = ((Uint8*)loadedSurface->pixels)[n*fmt->BytesPerPixel+i];
    }    
    SDL_UnlockSurface(loadedSurface);

    memcpy(out_color, pixel8, sizeof(Uint8)*fmt->BytesPerPixel);
  
 return out_color;
}

SDL_Color * ERPG_get_pixel_color_sprite( ERPG_Sprite * sprite,
				    int x, int y, SDL_bool current_anim)
{
  ERPG_Window * window = get_window();
  List * list_of_surface = window->list_of_sprite;
  ERPG_List_img * img_l = (ERPG_List_img*)list_get_value(list_of_surface, sprite->path);
  SDL_Surface * surface = img_l->surface;
  SDL_Color *  color;

  int x2=0, y2=0;

  if(sprite->surface_clip_rect){
    x2 = sprite->surface_clip_rect->x;
    y2 = sprite->surface_clip_rect->y;
  }
  
  if(current_anim)
    color = ERPG_find_pixel_color(surface,x2+x + sprite->act_clip_x*sprite->src.w,
				  y2+ y + sprite->act_clip_y*sprite->src.h);
  else
    color = ERPG_find_pixel_color(surface,x2+x, y2+y );
  
  return color;
}

void ERPG_set_pixel_color_sprite(ERPG_Sprite * sprite, int x, int y,
				 SDL_Color * color)
{
  ERPG_Window * window = get_window();
  List * list_of_surface = window->list_of_sprite;
  SDL_Surface * surface = (SDL_Surface*)list_get_value(list_of_surface, sprite->path);
  int x2=0, y2=0;

  if(sprite->surface_clip_rect){
    x2 = sprite->surface_clip_rect->x;
    y2 = sprite->surface_clip_rect->y;
  }
  
  ERPG_set_pixel_color(surface,x2+x + sprite->act_clip_x*sprite->src.w,
		       y2+ y + sprite->act_clip_y*sprite->src.h, color);
}

void ERPG_copy_sprite_to_renderer(ERPG_Sprite *sprite)
{ 
  SDL_Rect r_src;
  SDL_Rect r_dest;
  ERPG_Window * window = get_window();
  int w,h;
  SDL_QueryTexture(sprite->texture,NULL,NULL,&w,&h);
  if( !sprite->rectangles ){

    r_src = ERPG_get_source_sprite(sprite);
    r_src.x = r_src.x + sprite->src.x;
    r_src.y = r_src.y + sprite->src.y;
    r_src.w = sprite->src.w;
    r_src.h = sprite->src.h;

  }
  else{
    r_src = sprite->rectangles[sprite->act_clip_x];
  }

  SDL_QueryTexture(sprite->texture, NULL, NULL,  &w, &h);

  int size_x = w/sprite->count_clips_x;
  int size_y = h/sprite->count_clips_y;
  
  r_dest.x = sprite->destination.x;
  r_dest.y = sprite->destination.y;
  r_dest.w = sprite->destination.w - ((size_x-sprite->src.w) + sprite->src.x) +
    sprite->src.x; 
  r_dest.h = sprite->destination.h - ((size_y-sprite->src.h) + sprite->src.y) +
    sprite->src.y;
  
  if(!(sprite->color_modulate.r == 255 && sprite->color_modulate.g == 255 &&
       sprite->color_modulate.b == 255)){
      
    ERPG_set_blend_mode(sprite->texture, 1);
    SDL_SetTextureColorMod( sprite->texture, sprite->color_modulate.r,
			    sprite->color_modulate.g,
			    sprite->color_modulate.b );
  }

  if(sprite->alpha != 255){    
    ERPG_set_blend_mode(sprite->texture, 1);
    if(SDL_SetTextureAlphaMod( sprite->texture, sprite->alpha ))
      printf("ERROR: %s \n", SDL_GetError());
  }
  
  int tmp_time = SDL_GetTicks();
  
  if(sprite->texture){
    ERPG_set_blend_mode(sprite->texture, sprite->mode);

    if(sprite->angle)
    {
	    SDL_RendererFlip flip = SDL_FLIP_HORIZONTAL | SDL_FLIP_VERTICAL;
       SDL_Point point = {r_src.w /2, r_src.h /2};
       if(SDL_RenderCopyEx(window->renderer, sprite->texture, &r_src,
                        &r_dest, sprite->angle + 180 , &point, flip))
	       SDL_GetError();
    }
    else{
	    if(SDL_RenderCopy(window->renderer, sprite->texture, &r_src, &r_dest))
		    SDL_GetError();
    }
  }
  ERPG_set_blend_mode(sprite->texture, 1);
  SDL_SetTextureColorMod( sprite->texture, 255, 255, 255 );
  SDL_SetTextureAlphaMod( sprite->texture, 255 );
  
  int result = SDL_GetTicks() - tmp_time;

  if(result > 800)
    printf("%d RENDERRRREER SLOW \n", result);
  
}

/*-------------------------Functions for Lua---------------------------
  
  ---------------------SPRITE----------------------------------
  
*/

int set_correct_renderer(lua_State * L, int index)
{
  void * object;
  if((object = luaL_testudata(L,index,"ERPG_Sprite")))
    ERPG_copy_sprite_to_renderer(Lua_check_sprite(L, index));
  else if((object = luaL_testudata(L,index,"ERPG_Geometry_shape")))
    ERPG_copy_geom_shape_to_renderer( (ERPG_Geometry_shape*)object);
  else if((object = luaL_testudata(L,index,"ERPG_Text_Element")))
    ERPG_copy_text_to_renderer((ERPG_Text_Element*)object);
  else if((object = luaL_testudata(L,index,"ERPG_Frame_text")))
    ERPG_copy_block_text_to_renderer( (ERPG_Frame_text*)object);
  else if((object = luaL_testudata(L,index,"ERPG_Rectangle")))
    ERPG_copy_rect_to_renderer( (ERPG_Rectangle*)object);
  else
    printf("ERROR bad typename \n" );  

   return 0;
}

void set_correct_renderer_in_arguments(lua_State * L)
{
  if(!lua_istable(L,1)){
    set_correct_renderer(L, -1);
  }

  lua_pushnil(L);
  while (lua_next(L, 1) != 0) {

    if(lua_istable(L,-1)){
      lua_pushnil(L);
      while (lua_next(L, -2) != 0) {
        set_correct_renderer(L, -1);
        lua_pop(L, 1);
      }
      lua_pop(L,1);
    }
    else
    {
      set_correct_renderer(L, -1);
      lua_pop(L, 1);
    }
  }
}
/**
 * Create sprite from graphic objects
 * @param  GraphicObjects Array, width, height
 * @return sprite
*/
int Lua_create_new_texture(lua_State * L)
{
  ERPG_Window * win = ERPG_get_Window();

  int w = luaL_checkinteger(L,2);
  int h = luaL_checkinteger(L,3);
  SDL_SetRenderDrawBlendMode(win->renderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor( win->renderer, 0, 0, 0, 0);
 
  SDL_Texture * texture =  SDL_CreateTexture(win->renderer, SDL_PIXELFORMAT_RGBA8888,
					     SDL_TEXTUREACCESS_TARGET ,w,h);
  int tmp_w = 0;
  
  int tmp_h = 0;
  
  SDL_SetTextureAlphaMod(texture, 0);
  
  SDL_SetRenderTarget(win->renderer, texture);

  SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);

  
  SDL_RenderFillRect(win->renderer,NULL);
  SDL_RenderCopy(win->renderer,texture,NULL,NULL);
  
  SDL_SetRenderDrawColor(win->renderer, 0,0, 0,255); 
  
  set_correct_renderer_in_arguments(L);

 /* if(!lua_istable(L,1)){
    set_correct_renderer(L, -1);
  }
  else {
    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
       set_correct_renderer(L, -1);
       lua_pop(L, 1);
    }
  } 
*/ 
  ERPG_Sprite * s = (ERPG_Sprite*)malloc(sizeof(ERPG_Sprite));
  ERPG_Sprite * lua_sprite = lua_newuserdata(L, sizeof(ERPG_Sprite));

  s->src.x = 0;
  s->src.y = 0;
  s->duplicite = SDL_FALSE;
  s->destination.x = 0;
  s->destination.y = 0;
  s->act_clip_x = 0;
  s->act_clip_y = 0;  

  s->count_clips_x = 1;
  s->count_clips_y = 1;
  s->path = "tempt";
  s->rectangles = NULL;
  s->texture = texture;
  s->surface_clip_rect = NULL;
   SDL_QueryTexture(s->texture, NULL, NULL, &tmp_w,&tmp_h);
  s->src.w = tmp_w;
  s->src.h = tmp_h;
  s->destination.w = tmp_w;
  s->destination.h = tmp_h;

  s->color_modulate.r = 255;
  s->color_modulate.g = 255;
  s->color_modulate.b = 255;
	s->angle = 0;
  s->alpha = 255;
  
  s->mode = 1;
  s->compose = SDL_TRUE;
  
  memcpy(lua_sprite, s, sizeof(ERPG_Sprite));
  free(s);

  SDL_SetRenderTarget(win->renderer, NULL);

  luaL_setmetatable(L, "ERPG_Sprite");
  return 1;
}

int Lua_set_target_sprite(lua_State * L)
{
 ERPG_Window * win = ERPG_get_Window();

  int w = luaL_checkinteger(L,1);
  int h = luaL_checkinteger(L,2);
  SDL_Texture * texture =  SDL_CreateTexture(win->renderer, SDL_PIXELFORMAT_RGBA8888,
					     SDL_TEXTUREACCESS_TARGET ,w,h);
  
  SDL_SetTextureAlphaMod(texture, 0);
  
  SDL_SetRenderTarget(win->renderer, texture);

  SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);

  
  SDL_RenderFillRect(win->renderer,NULL);
  SDL_RenderCopy(win->renderer,texture,NULL,NULL);
  
  SDL_SetRenderDrawColor(win->renderer, 0,0, 0,255);
  
  win->target_texture = texture;

  return 0;
}

int Lua_get_target_sprite(lua_State * L)
{
  ERPG_Window * win = ERPG_get_Window();
  SDL_Texture * texture = win->target_texture;
  ERPG_Sprite * s = (ERPG_Sprite*)malloc(sizeof(ERPG_Sprite));
  ERPG_Sprite * lua_sprite = lua_newuserdata(L, sizeof(ERPG_Sprite));

  int tmp_w = 0;  
  int tmp_h = 0;
  
  win->target_texture = NULL;
  
  s->src.x = 0;
  s->src.y = 0;
  s->duplicite = SDL_FALSE;
  s->destination.x = 0;
  s->destination.y = 0;
  s->act_clip_x = 0;
  s->act_clip_y = 0;  

  s->count_clips_x = 1;
  s->count_clips_y = 1;
  s->path = "tempt";
  s->rectangles = NULL;
  s->texture = texture;
  s->surface_clip_rect = NULL;
  SDL_QueryTexture(s->texture, NULL, NULL, &tmp_w,&tmp_h);
  s->src.w = tmp_w;
  s->src.h = tmp_h;
  s->destination.w = tmp_w;
  s->destination.h = tmp_h;

  s->color_modulate.r = 255;
  s->color_modulate.g = 255;
  s->color_modulate.b = 255;

  s->alpha = 255;
	s->angle = 0;

  s->mode = 1;
  s->compose = SDL_TRUE;
  
  memcpy(lua_sprite, s, sizeof(ERPG_Sprite));
  free(s);

  SDL_SetRenderTarget(win->renderer, NULL);

  luaL_setmetatable(L, "ERPG_Sprite");
  return 1;  
}

ERPG_Sprite * Lua_check_sprite(lua_State * L, int i)
{
  return luaL_checkudata(L, i, "ERPG_Sprite");
}

/**
 * Create sprite
 * @param  path,
 * @optional  ColorForAlpha{r, g, b}, countClipsX, countClipY
 * @return sprite
*/
int Lua_Sprite(lua_State * L)
{
  //  lua_State * L = (lua_State*)ptr;
  ERPG_Sprite * s = NULL;
  ERPG_Sprite * lua_sprite = lua_newuserdata(L, sizeof(ERPG_Sprite));
  
  if( !lua_istable(L,2) )
    s = ERPG_make_sprite( (char*)luaL_checkstring(L, 1),
			  NULL, NULL);
  else{
    SDL_Color * color = Lua_get_color(L,2);
    s = ERPG_make_sprite( (char*)luaL_checkstring(L, 1), color, NULL);
    free(color);    
  }
  if(!s){
    lua_pushnil(L);
    return 1;
  }
  memcpy(lua_sprite, s, sizeof(ERPG_Sprite));
  
  lua_sprite->duplicite = SDL_FALSE;
  
  free(s);
  
  luaL_setmetatable(L, "ERPG_Sprite");
  
  return 1;
}
/**
 * Duplicite sprite, same texture
 * @param  sprite,
 * @return sprite
*/
int Lua_duplicite_sprite(lua_State * L)
{
  ERPG_Sprite * sprite= Lua_check_sprite(L,1);
  ERPG_Sprite * lua_sprite = lua_newuserdata(L,sizeof(ERPG_Sprite));

  memcpy(lua_sprite,sprite,sizeof(ERPG_Sprite));
  lua_sprite->duplicite = SDL_TRUE;

  luaL_setmetatable(L,"ERPG_Sprite");
  //  Lua_create_new_texture(L);  
  return 1;
}


/**
 * Not tested
 * Create sprite clip means you can load a piece of surface picture
 * @param  path
 * @param color as {red, green, blue(for alpha)}
 * @param clip as {x,y,w,h}
 * @return sprite
*/
int Lua_Sprite_clip(lua_State * L)
{
  SDL_Color * color = Lua_get_color(L,2);
  SDL_Rect * clip_rect = Lua_from_create_rect(L,3);
  ERPG_Sprite * lua_sprite = lua_newuserdata(L, sizeof(ERPG_Sprite));
  ERPG_Sprite * s = NULL;
  
  s = ERPG_make_sprite((char*)luaL_checkstring(L,1),color, clip_rect);

  free(color);
  if(!s){
    lua_pushnil(L);
    return 1;
  }
  memcpy(lua_sprite, s, sizeof(ERPG_Sprite));
  free(s);
  luaL_setmetatable(L, "ERPG_Sprite");
  
  return 1;
}

int Lua_copy_sprite_to_renderer(lua_State * L)
{
  ERPG_copy_sprite_to_renderer(Lua_check_sprite(L,1));
  return 0;
}

/**
 * Get position sprite
 * @param  sprite
 * @return x
 * @return y
 */
int Lua_get_pozition(lua_State * L)
{
  Lua_check_sprite(L, 1);
  ERPG_Sprite * sprite = lua_touserdata(L, 1);
  lua_pushnumber(L, sprite->destination.x);
  lua_pushnumber(L, sprite->destination.y);
  
  return 2;
}
/**
 * Get width, height current clip
 * @param  sprite
 * @return width
 * @return height
 */
int Lua_get_width_height(lua_State * L)
{
  Lua_check_sprite(L, 1);
  ERPG_Sprite * sprite = lua_touserdata(L, 1);
  lua_pushnumber(L, sprite->src.w);
  lua_pushnumber(L, sprite->src.h);
  
  return 2;
}

/**
 * Get color of sprite pixel current clip
 * @param sprite
 * @param pixelX
 * @param pixelY
 * @return color as {r,g,b,a}
 */
int Lua_get_color_of_sprite_pixel(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L, 1);
  int x = luaL_checkinteger(L,2);
  int y = luaL_checkinteger(L,3);

  SDL_Color * color = ERPG_get_pixel_color_sprite(sprite, x, y, SDL_TRUE);

  lua_createtable(L, 0, 4);
  setfield(L,"r", color->r);
  setfield(L,"g", color->g);
  setfield(L,"b", color->b);
  setfield(L,"a", color->a);

  free(color);
  return 1;
}

//lua_set pixel args: sprite, x, y, {color} Change this
/*
int Lua_set_color_pixel(lua_State * L)
{
  SDL_Color * color = Lua_get_color(L,4);
  ERPG_set_pixel_color_sprite(Lua_check_sprite(L,1),
			      luaL_checkinteger(L,2), luaL_checkinteger(L,3),
			      color);

  free(color);
  return 0;
}

int Lua_set_color_pixels(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  List * list_of_surface = window->list_of_sprite;
  SDL_Surface * surface = (SDL_Surface*)list_get_value(list_of_surface, sprite->path);
  SDL_Color * color;
}
*/

/*
  describe: set clips 
  args= self, int(x), int(y)
 */

/**
 * Set clips of image in sprite
 * @param sprite
 * @param clipsX
 * @param clipsY
 */
int Lua_set_clips_sprite(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L, 1);

  ERPG_set_clips_sprite(sprite, luaL_checkinteger(L,2), luaL_checkinteger(L,3));

  return 0;
}
/**
 * Not tested
 * Set rects for animation sprite
 * @param sprite
 * @param animationClips as {["1"]:{x,y,w,h}, ["2"]{x,y,w,h} ...}
 */
int Lua_set_rects_clips_sprite(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  int n;
  int temp_array[4];

  SDL_Rect * rectangles;
  if(lua_istable(L,2)){
    n = luaL_len(L,2);
    lua_pushnil(L);
    rectangles= (SDL_Rect*)malloc(sizeof(SDL_Rect)*n);
    
    for(int x = 0; lua_next(L,2) != 0; x++){
      lua_pushnil(L);
      for(int i = 0; lua_next(L, -2) != 0; i++){
	temp_array[i] = luaL_checkinteger(L,-1);
	lua_pop(L,1);
      }
      rectangles[x] = (SDL_Rect){temp_array[0],temp_array[1],temp_array[2],temp_array[3]};
      lua_pop(L,1);
    }
    ERPG_set_clips_rect_sprite(sprite, rectangles,n);
  }
  return 0;
}

/**
 * Move with sprite
 * @param sprite
 * @param x
 * @param y
 */
int Lua_move_sprite(lua_State * L)
{
  Lua_check_sprite(L, 1);
  ERPG_Sprite * sprite = lua_touserdata(L, 1);

  ERPG_move_sprite(sprite, luaL_checkinteger(L, 2), luaL_checkinteger(L, 3));

  return 0;
}
/**
 * Scale sprite
 * @param sprite
 * @param width
 * @param height
 */
int Lua_scale_sprite(lua_State * L)
{
  ERPG_scale_sprite( Lua_check_sprite(L, 1), luaL_checkinteger(L, 2), luaL_checkinteger(L, 3));

  return 0;
}

/**
 * Set current clip
 * @param sprite,clipX, clipY
 * @param
 * @param
 */
int Lua_set_current_clip_sprite(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  if(!sprite->rectangles){
    ERPG_set_current_clip_sprite(sprite, luaL_checkinteger(L, 2), luaL_checkinteger(L, 3));
  }
  else
    ERPG_set_current_clip_rect_sprite(sprite, luaL_checkinteger(L, 2));
  
  return 0;
}

/**
 * Sprite alpha
 * @param sprite
 * @param alpha (0-255)
 * @param colorMode (0-2)
 */
int Lua_set_sprite_alpha(lua_State * L)
{
  ERPG_set_sprite_alpha( Lua_check_sprite(L,1), luaL_checkinteger(L, 2), luaL_checkinteger(L,3));

  return 0;
}
/**
 * Sprite modulation color
 * @param sprite
 * @param red
 * @param green
 * @param blue
 * @param colorMode (0-2)
 */
int Lua_set_modulation_color_sprite(lua_State * L)
{

  ERPG_set_color_modulation(Lua_check_sprite(L,1), luaL_checkinteger(L, 2),luaL_checkinteger(L, 3),
			    luaL_checkinteger(L, 4),  luaL_checkinteger(L, 5));

  return 0;
}

int Lua_get_position_rect(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L, 1);

  rect_to_table(L, &sprite->destination);
  
  return 1;
}
/**
 * Sprite set position
 * @param sprite
 * @param posX
 * @param posY
 */
int Lua_set_position(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  sprite->destination.x = luaL_checkinteger(L,2);
  sprite->destination.y = luaL_checkinteger(L,3);
  return 0;
}
/**
 * Sprite add size
 * @param sprite
 * @param addSizeX
 * @param addSizeY
 */
int Lua_move_size(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);

  sprite->src.x += luaL_checkinteger(L,2);
  sprite->src.y += luaL_checkinteger(L,3);
  sprite->src.w += luaL_checkinteger(L,4);
  sprite->src.h += luaL_checkinteger(L,5);
  sprite->destination.w += sprite->src.w;
  sprite->destination.h += sprite->src.h;
  return 0;
}
/**
 * Sprite set size
 * @param sprite
 * @param addSizeX
 * @param addSizeY
 */
int Lua_set_size(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  int w = 0, h = 0;
  int plus_x;
  int plus_y;
  int plus_w;
  int plus_h;
  if(sprite->texture){
    SDL_QueryTexture(sprite->texture, NULL,NULL,&w,&h);
    plus_x = luaL_checkinteger(L,2);
    plus_y= luaL_checkinteger(L,3);
    plus_w = luaL_checkinteger(L,4)+
      (w/sprite->count_clips_x-sprite->destination.w);
    plus_h = luaL_checkinteger(L,5)
      +(h/sprite->count_clips_y-sprite->destination.h);
 
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
  
  return 0;
}
/**
 * Sprite get current size
 * @param sprite
 * @return size as {x=x,y=y,w=w,h=h}
 */
int Lua_get_current_size(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);

  return rect_to_table(L, &(SDL_Rect){sprite->src.x,sprite->src.y, sprite->src.w, sprite->src.h});
}
/**
 * Sprite get size of whole texture
 * @param sprite
 * @return size as {x=x,y=y,w=w,h=h}
 */
int Lua_get_size(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  int w = 0, h = 0;

  SDL_QueryTexture(sprite->texture, NULL,NULL,&w,&h);
  
  rect_to_table(L,&(SDL_Rect){sprite->src.x,sprite->src.y,
	w,
	h});
   
  return 1;
}

int Lua_set_rotate_sprite(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L, 1);
  float angle = luaL_checknumber(L, 2);

  sprite->angle = angle;

  return 0;
}

/**
 * Sprite get size of clip
 * @param  sprite
 * @return size as {x=x,y=y,w=w,h=h}
 */
int Lua_get_clip_size(lua_State * L)
{
  ERPG_Sprite * sp = Lua_check_sprite(L,1);
  int w = 0, h = 0;

  SDL_QueryTexture(sp->texture, NULL,NULL,&w,&h);

  rect_to_table(L,&(SDL_Rect){sp->src.x ,sp->src.y,
	w/ sp->count_clips_x,
	h / sp->count_clips_y});
  
  return 1;
}
/**
 * Sprite get alpha 
 * @param sprite
 * @return alpha(0-255)
 */
int Lua_get_alpha_mode(lua_State * L)
{
  Uint8 color;  
  SDL_GetTextureAlphaMod(Lua_check_sprite(L,1)->texture,&color);

  lua_pushnumber(L,color);
  
  return 1;
}
/**
 * Sprite get size of whole texture
 * @param sprite
 * @return width
 * @return height
 */
int Lua_max_size(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);
  int w=0,h=0;
  if(sprite->texture)
    SDL_QueryTexture(sprite->texture, NULL,NULL,&w,&h);
    
  lua_pushnumber(L,w);
  lua_pushnumber(L,h);
  return 2;
}
/**
 * Sprite count clips
 * @param sprite
 * @return clipsX
 * @return clipsY
 */
int Lua_get_count_clips(lua_State * L)
{
  ERPG_Sprite * sprite = Lua_check_sprite(L,1);

  lua_pushnumber(L,sprite->count_clips_x);
  lua_pushnumber(L, sprite->count_clips_y);
  return 2;
}

//SDL_Texture * unloadTexture = NULL;
//SDL_mutex *mutex = SDL_CreateMutex();
/*
int destroyTexture(void * ptr)
{
  while(1){
    if( SDL_LockMutex(mutex)==0  ){
      if(unloadTexture){
	SDL_DestroyTexture(unloadTexture);
	unloadTexture=NULL;
      }      
    }
  }
  return 1;
  }*/

//SDL_Thread * thread= SDL_CreateThread(destroyTexture, "destroyTexture",NULL);

/**
 * Sprite unload texture. After that sprite cant copy to renderer texture.
 * @param sprite
 */
int Lua_unload_texture(lua_State * L)
{
  ERPG_Sprite * s = lua_touserdata(L,1);

  if(s->compose == SDL_TRUE){
    SDL_DestroyTexture(s->texture);
    s->compose = SDL_FALSE;
    s->texture = NULL;
  }
  return 0;
} 

/**
 * Sprite destroy.
 * @param sprite
 */
int Lua_sprite_gc(lua_State * L)
{
    ERPG_Sprite * s = lua_touserdata(L, 1);

    if(s->compose == SDL_TRUE)
      SDL_DestroyTexture(s->texture);
	
    if(s->duplicite == SDL_FALSE)
      ERPG_sprite_destroy(s);

    return 0;
}

int luaopen_ERPG_sprite(lua_State * L)
{
  static const luaL_Reg method[] = {
    {"move", &Lua_move_sprite},
    {"copy_to_renderer", Lua_copy_sprite_to_renderer},
    {"rotate", Lua_set_rotate_sprite},
    {"scale", &Lua_scale_sprite},
    {"set_clips", &Lua_set_clips_sprite},
    {"set_rects_clips", &Lua_set_rects_clips_sprite},
    {"set_clip", &Lua_set_current_clip_sprite},
    {"set_alpha", &Lua_set_sprite_alpha},
    {"get_alpha", Lua_get_alpha_mode},
    {"set_modulation_color", &Lua_set_modulation_color_sprite},
    /* {"set_pixel_color",Lua_set_color_pixel},*/
    {"get_pixel_color", &Lua_get_color_of_sprite_pixel},
    {"get_width_height", Lua_get_width_height},
    {"get_position_rect", Lua_get_position_rect},
    {"set_size", Lua_set_size},
    {"get_size", Lua_get_size},
    {"get_max_size", Lua_max_size},
    {"get_count_clips", Lua_get_count_clips},
    {"move_size", Lua_move_size},
    {"set_position", Lua_set_position},
    {"get_position", &Lua_get_pozition},
    {"get_clip_size", &Lua_get_clip_size},
    {"unload_texture", &Lua_unload_texture},
    {"get_current_size", &Lua_get_current_size},
    {NULL, NULL}
  };

  static const luaL_Reg sprite_lib[] = {
    {"make",Lua_Sprite},
    {"make_clip_sprite", Lua_Sprite_clip},
    {"compose_textures", Lua_create_new_texture},
    {"duplicite", Lua_duplicite_sprite},
    /*   {"set_target_sprite", Lua_set_target_sprite},
	 {"get_target_sprite", Lua_get_target_sprite},*/
    {NULL, NULL}
  };
  luaL_newmetatable(L, "ERPG_Sprite");
  luaL_newlib(L, method);
  lua_setfield(L, -2, "__index");

  lua_pushcfunction(L, Lua_sprite_gc);
  lua_setfield(L, -2, "__gc");

  luaL_newlib(L, sprite_lib);

  return 1;
}
