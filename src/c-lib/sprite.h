#ifndef SPRITE_H
#define SPRITE_H

#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>

#include<SDL2/SDL.h>
#include"list.h"

typedef struct {
	int count_clips_x;
	int count_clips_y;
	int act_clip_x;
	int act_clip_y;
	char *path;
	SDL_Rect destination;
	SDL_Rect src;
	SDL_Rect *surface_clip_rect;
	SDL_Rect *rectangles;
	SDL_Texture *texture;
	SDL_bool compose;
	SDL_bool duplicite;
	SDL_Color color_modulate;
	char alpha;
	char mode;
	float angle;
} ERPG_Sprite;

typedef struct {
	SDL_Color *color;
	char *string;
	SDL_Rect *clip_rect;
	ERPG_Sprite *sprite;
} ERPG_ArgSprite;

typedef struct {
	SDL_Texture *texture;
	SDL_Surface *surface;
	char *path;
} ERPG_List_img;

typedef struct {
	int x;
	int y;
} ERPG_Vector;

SDL_Color *ERPG_find_pixel_color(SDL_Surface *loadedSurface, int x, int y);

//#include"window.h"

ERPG_Sprite *ERPG_make_sprite(char *path,
                              SDL_Color *color, SDL_Rect *clip_rect);

ERPG_Sprite* ERPG_create_target_texture(SDL_Texture * texture);

void ERPG_prepare_target_texture(SDL_Texture* texture);


void ERPG_destroy_whole_sprite(ERPG_Sprite * sprite);

void ERPG_sprite_set_texture(ERPG_Sprite *sprite, SDL_Texture *texture);

void ERPG_move_sprite(ERPG_Sprite *sprite, int x, int y);

void ERPG_scale_sprite(ERPG_Sprite *sprite, int w, int h);

void ERPG_set_current_clip_sprite(ERPG_Sprite *sprite, int cx, int cy);

void ERPG_set_sprite_alpha(ERPG_Sprite *sprite, char alpha, char mode);

void ERPG_set_color_modulation(ERPG_Sprite *sprite, char r, char g, char b, char mode);

void ERPG_set_clips_sprite(ERPG_Sprite *sprite, int count_clips_x, int count_clips_y);

void ERPG_sprite_destroy(ERPG_Sprite *sprite);

SDL_Color *ERPG_get_pixel_color_sprite(ERPG_Sprite *sprite,
                                       int x, int y, SDL_bool current_anim);

void ERPG_set_pixel_color(SDL_Surface *surface, int x, int y, SDL_Color *color);

void ERPG_set_pixel_color_sprite(ERPG_Sprite *sprite, int x, int y,
                                 SDL_Color *color);

void ERPG_copy_sprite_to_renderer(ERPG_Sprite *sprite);

int luaopen_ERPG_sprite(lua_State *L);

ERPG_Sprite *Lua_check_sprite(lua_State *L, int i);

int setfield(lua_State *L, const char *index, int value);

#endif
