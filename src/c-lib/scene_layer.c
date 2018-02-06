//
// Created by ondrej on 4.2.18.
//
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include <SDL2/SDL_rect.h>
#include "scene_layer.h"
#include "window.h"
#include "static_object.h"
#include "sprite.h"
#include"core.h"
#include "lua_func.h"

ERPG_Scene * ERPG_make_scene()
{
	ERPG_Scene * scene = (ERPG_Scene*)malloc(sizeof(ERPG_Scene));

	printf("created scene layer \n");

	SDL_Rect boundBox = {x : 0, y : 0, w: 1920, h: 1080};

	scene->tileWidth = 64;
	scene->tileHeight = 64;
	scene->boundBoxSize =boundBox;
	scene->sizeWidth = 1;
	scene->sizeHeight = 1;
	scene->target = NULL;
	scene->scene_list = create_clist();

	scene->scene_field = (CList**)calloc(scene->sizeWidth*scene->sizeHeight, sizeof(CList*));

	return scene;
}

SDL_Texture* ERPG_load_texture_scene(ERPG_Scene * scene, int width, int height)
{
	ERPG_Window * win = ERPG_get_Window();

	SDL_SetRenderDrawBlendMode(win->renderer, SDL_BLENDMODE_BLEND);
	SDL_SetRenderDrawColor( win->renderer, 0, 0, 0, 0);

	SDL_Texture * texture =  SDL_CreateTexture(win->renderer, SDL_PIXELFORMAT_RGBA8888,
	                                           SDL_TEXTUREACCESS_TARGET ,width,height);

	SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);
	SDL_SetTextureAlphaMod(texture, 0);

	return texture;
}

void ERPG_set_tile_size_scene(ERPG_Scene * scene, int width, int height)
{

}

void ERPG_set_size_scene(ERPG_Scene * scene, int width, int height)
{
	scene->sizeWidth = width;
	scene->sizeHeight = height;
	scene->scene_field = (CList**)calloc(scene->sizeWidth*scene->sizeHeight, sizeof(CList*));
}

void ERPG_set_bound_box_scene(ERPG_Scene * scene, SDL_Rect rect)
{
	if(scene->boundBoxSize.w == rect.w && scene->boundBoxSize.h == rect.h)
	{
		if(scene->target)
		{
			SDL_DestroyTexture(scene->target);
		}

		scene->target = ERPG_load_texture_scene(scene, rect.w, rect.h);
	}

	scene->boundBoxSize = rect;
}

int field_position1D(ERPG_Scene* scene, int x, int y)
{
	int maxW = scene->sizeWidth / scene->tileWidth;
	int position = y * maxW + x;

	return position;
}

/*ERPG_Vector field_position2D(ERPG_Scene* scene, int x)
{
	int newX = x / (scene->sizeWidth / scene->tileWidth);
	int newY = x % (scene->sizeWidth / scene->tileWidth);

	return {x: newX, y: newY};
}
*/
void ERPG_add_field_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	int x = scene_object->bound_box.x / scene->tileWidth;
	int y = scene_object->bound_box.y / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene->sizeWidth*scene->sizeHeight)
	{
		return;
	}

	CList* field = scene->scene_field[position];

	if(!field) {
		field = create_clist();
		scene->scene_field[position] = field;
	}

	add_cnode(field, scene_object);
}

void ERPG_add_list_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	CList* list = scene->scene_list;
	add_cnode(list, scene_object);
}

ERPG_Scene_object * ERPG_remove_field_object_scene(ERPG_Scene * scene, ERPG_Static_object *scene_object)
{
	int x = scene_object->bound_box.x / scene->tileWidth;
	int y = scene_object->bound_box.y / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene->sizeWidth*scene->sizeHeight)
	{
		return 0;
	}

	CList* field = scene->scene_field[position];

	if(field) {
		if(remove_cnode_by_pointer(field, scene_object))
		{
			ERPG_destroy_so(scene_object);
		}
	}

	return 0;
}

ERPG_Scene_object * ERPG_remove_field_index_scene(ERPG_Scene *scene, int id)
{
	return 0;
}

ERPG_Scene_object * ERPG_remove_list_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	remove_cnode_by_pointer(scene, scene_object);
	if(remove_cnode_by_pointer(scene, scene_object)) {
		ERPG_destroy_so(scene_object);
	}

	return 0;
}

ERPG_Scene_object * ERPG_remove_list_index_scene(ERPG_Scene *scene, int index)
{
	return 0;
}

void ERPG_print_sprite_scene(ERPG_Scene* scene, ERPG_Static_object * scene_object)
{
	int tmpX = scene_object->sprite->destination.x;
	int tmpY = scene_object->sprite->destination.y;

	scene_object->sprite->destination.x = scene_object->bound_box.x - scene->boundBoxSize.x;
	scene_object->sprite->destination.y = scene_object->bound_box.y - scene->boundBoxSize.y;

	ERPG_copy_sprite_to_renderer(scene_object->sprite);

	scene_object->sprite->destination.x = tmpX;
	scene_object->sprite->destination.y = tmpY;
}

void ERPG_print_list_scene(ERPG_Scene* scene)
{
	CList* list = scene->scene_list;
	for(int z = 0; z < cnode_length(list); z++)
	{
		ERPG_Static_object * sobj = get_cnode(list, z);

		if(sobj && sobj->sprite)
		{
			SDL_Rect rect;
			if(SDL_IntersectRect(&scene->boundBoxSize, &sobj->bound_box, &rect)){
				ERPG_print_sprite_scene(scene, sobj);
			}
		}
	}
}

CList* ERPG_get_field_object_scene(ERPG_Scene * scene, int x_arg, int y_arg)
{
	int x = x_arg / scene->tileWidth;
	int y = y_arg / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene->sizeWidth*scene->sizeHeight)
	{
		return 0;
	}

	return scene->scene_field[position];
}

void ERPG_draw_scene(ERPG_Scene * scene)
{
	int minX = scene->boundBoxSize.x/scene->tileWidth;
	int minY = scene->boundBoxSize.y/scene->tileHeight;
	int maxWidth = minX + scene->boundBoxSize.w/scene->tileWidth + 1;
	int maxHeight = minY + scene->boundBoxSize.h/scene->tileHeight + 1;

	SDL_Texture * texture = scene->target;
	ERPG_prepare_target_texture(texture);

	for(int y = minY; y < maxHeight && y < scene->sizeHeight/scene->tileHeight; y++)
	{
		for(int x = minX; x < maxWidth && x < scene->sizeWidth/scene->tileWidth ; x++)
		{
			int newX = field_position1D(scene, x, y);
			CList* list = scene->scene_field[newX];
			if(!list)
			{
				continue;
			}
			for(int z = 0; z < cnode_length(list); z++)
			{
				ERPG_Static_object * sobj = get_cnode(list, z);

				if(sobj && sobj->sprite)
				{
					ERPG_print_sprite_scene(scene, sobj);
				}
			}
		}
	}
	ERPG_print_list_scene(scene);

	ERPG_Sprite * sprite = ERPG_create_target_texture(texture);
	ERPG_copy_sprite_to_renderer(sprite);
	ERPG_sprite_destroy(sprite);
	free(sprite);
}

void ERPG_destroy_scene(ERPG_Scene * scene)
{

}

SDL_bool ERPG_is_scene_collision(ERPG_Scene * scene, SDL_Rect bound_box, SDL_Rect* rect_out)
{
	for(int y = 0; y < scene->sizeHeight/scene->tileHeight; y++) {
		for (int x = 0; x < scene->sizeWidth / scene->tileWidth; x++) {
			int newX = field_position1D(scene, x, y);
			CList *list = scene->scene_field[newX];
			if (!list) {
				continue;
			}
			for (int z = 1; z < cnode_length(list); z++) {
				ERPG_Static_object *sobj = get_cnode(list, z);
				SDL_bool result = SDL_IntersectRect(&sobj->bound_box,
				                                    &bound_box,
				                                    rect_out);
				if(result)
				{
					return result;
				}
			}
		}
	}

	return SDL_FALSE;
}

int Lua_Scene(lua_State * L)
{
	ERPG_Scene * lua_scene = lua_newuserdata(L, sizeof(ERPG_Scene));

	ERPG_Scene * scene = ERPG_make_scene();

	memcpy(lua_scene, scene, sizeof(ERPG_Scene));

	free(scene);

	luaL_setmetatable(L, "ERPG_Scene");

	return 1;
}

int Lua_is_scene_collision(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	SDL_Rect rect = Lua_from_create_rect_static(L, 2);
	SDL_Rect rect_out;
	SDL_bool result = ERPG_is_scene_collision(scene, rect, &rect_out);

	rect_to_table(L, &rect_out);
	lua_pushnumber(L, result);

	return 2;
}

int Lua_set_bound_box_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	int x = lua_tonumber(L, 2);
	int y = lua_tonumber(L, 3);
	int w = lua_tonumber(L, 4);
	int h = lua_tonumber(L, 5);

	SDL_Rect rect = {x : x, y: y, w: w, h: h};

	ERPG_set_bound_box_scene(scene, rect);

	return 0;
}

int Lua_add_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_add_field_object_scene(scene, static_object);

	return 0;
}

int Lua_add_list_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_add_list_object_scene(scene, static_object);

	return 0;
}

int Lua_remove_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_remove_field_object_scene(scene, static_object);

	return 0;
}

int Lua_remove_list_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_remove_list_object_scene(scene, static_object);

	return 0;
}

int Lua_set_size_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);

	int w = lua_tonumber(L, 2);
	int h = lua_tonumber(L, 3);

	ERPG_set_size_scene(scene, w, h);

	return 0;
}

int Lua_get_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	CList* list = ERPG_get_field_object_scene(scene, lua_tonumber(L, 2), lua_tonumber(L, 3));

	lua_newtable(L);
	if(list) {
		for (int i = 0; i < cnode_length(list); i++) {
			ERPG_Static_object* static_object = get_cnode(list, i);
			if(static_object)
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);
				lua_rawseti(L, -2, i+1);
			}
		}
	}

	return 1;
}

int Lua_draw_scene(lua_State * L)
{
	ERPG_draw_scene(lua_touserdata(L, 1));

	return 0;
}

int Lua_Scene_gc(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);

	//ERPG_destroy_scene(scene);

	return 0;
}

int luaopen_ERPG_scene(lua_State * L)
{
	static const luaL_Reg method[] = {
			{"addFieldObject",Lua_add_field_object_scene},
			{"addListObject", Lua_add_list_object_scene},
			{"draw", Lua_draw_scene},
			{"setBox", Lua_set_bound_box_scene},
			{"setSize", Lua_set_size_scene},
			{"isCollision", Lua_is_scene_collision},
			{"removeFieldObject", Lua_remove_field_object_scene},
			{"removeListObject", Lua_remove_list_object_scene},
			{"getFieldObject", Lua_get_field_object_scene},
			{NULL, NULL}
	};

	static const luaL_Reg sprite_lib[] = {
			{"make", Lua_Scene},
			{NULL, NULL}
	};
	luaL_newmetatable(L, "ERPG_Scene");
	luaL_newlib(L, method);
	lua_setfield(L, -2, "__index");

	lua_pushcfunction(L, Lua_Scene_gc);
	lua_setfield(L, -2, "__gc");

	luaL_newlib(L, sprite_lib);

	return 1;
}