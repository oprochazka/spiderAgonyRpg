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
#include "list.h"

static CList* collision_iter = NULL;
static CNode* collision_node;
static int collision_element = 0;

SDL_Texture* ERPG_scene_load_texture(ERPG_Scene *scene, int width, int height);

ERPG_Static_object* get_static_object(Node* node)
{
	if(node)
		return (ERPG_Static_object*)node->value;

	return NULL;
}

ERPG_Scene * ERPG_scene_make()
{
	ERPG_Scene * scene = (ERPG_Scene*)malloc(sizeof(ERPG_Scene));

	printf("created scene layer \n");

	SDL_Rect boundBox = {x : 0, y : 0, w: 1920, h: 1080};

	scene->tileWidth = 64;
	scene->tileHeight = 64;
	scene->boundBoxSize =boundBox;
	scene->sizeWidth = 1;
	scene->sizeHeight = 1;
	scene->target=ERPG_scene_load_texture(scene, 1, 1);;
	scene->scene_list = create_clist();
	scene->layers = 1;
	scene->quad_tree = NULL;
	scene->collision_iter = create_clist();

	scene->scene_field = (List**)calloc(scene_get_array_length(scene), sizeof(List*));

	return scene;
}

int scene_get_array_length(ERPG_Scene * scene)
{
	int x = scene->sizeWidth;
	int y = scene->sizeHeight;

	return x*y;
}

SDL_Texture* ERPG_scene_load_texture(ERPG_Scene *scene, int width, int height)
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

void ERPG_scene_set_tile_size(ERPG_Scene *scene, int width, int height)
{
	scene->tileWidth = width;
	scene->tileHeight = height;
}

void ERPG_scene_set_layers(ERPG_Scene * scene, int layers)
{
	scene->layers = layers;
}

void ERPG_scene_set_size(ERPG_Scene *scene, int width, int height)
{
	ERPG_scene_remove_fields(scene);

	scene->sizeWidth = width;
	scene->sizeHeight = height;

	scene->scene_field = (List**)calloc(scene_get_array_length(scene), sizeof(List*));

	if(scene->quad_tree)
	{
		ERPG_Quad_tree_destroy(scene->quad_tree);
		free(scene->quad_tree);

		scene->quad_tree = NULL;
	}
	scene->quad_tree = ERPG_quadtree_make(width*scene->tileWidth, height*scene->tileHeight);
}

void ERPG_scene_set_bound_box(ERPG_Scene *scene, SDL_Rect rect)
{
	if(scene->boundBoxSize.w == rect.w && scene->boundBoxSize.h == rect.h)
	{
		if(scene->target)
		{
			SDL_DestroyTexture(scene->target);
		}

		scene->target = ERPG_scene_load_texture(scene, rect.w, rect.h);
	}

	scene->boundBoxSize = rect;
}

CList* ERPG_scene_get_list_objects(ERPG_Scene* scene, SDL_Rect bound_box)
{
	CList* list = create_clist();

	ERPG_Quad_tree_retrieve(scene->quad_tree, bound_box, list);

	return list;
}

int field_position1D(ERPG_Scene* scene, int x, int y)
{
	int maxW = scene->sizeWidth;
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
ERPG_Static_object* ERPG_scene_add_field_object(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	int x = scene_object->bound_box.x / scene->tileWidth;
	int y = scene_object->bound_box.y / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene->sizeWidth*scene->sizeHeight)
	{
		return NULL;
	}

	List* field = scene->scene_field[position];

	if(!field) {
		field = create_list();
		scene->scene_field[position] = field;
	}

	return (ERPG_Static_object*)add_int_node(field, scene_object->layer ,scene_object);
}

void ERPG_scene_add_list_object(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	CList* list = scene->scene_list;
	add_cnode(list, scene_object);

	ERPG_Quad_tree_insert(scene->quad_tree, scene_object);
}

ERPG_Static_object * ERPG_scene_remove_field_object(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	int x = scene_object->bound_box.x / scene->tileWidth;
	int y = scene_object->bound_box.y / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene_get_array_length(scene))
	{
		return 0;
	}

	List* field = scene->scene_field[position];

	if(field) {
		if(remove_int_node(field, scene_object->layer))
		{
			ERPG_so_destroy(scene_object);
			return scene_object;
		}
	}

	return 0;
}

ERPG_Scene_object * ERPG_scene_remove_field_index(ERPG_Scene *scene, int id)
{
	return 0;
}

ERPG_Scene_object * ERPG_scene_remove_list_object(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	if(remove_cnode_by_pointer(scene->scene_list, scene_object)) {
		ERPG_so_destroy(scene_object);
	}

	ERPG_Quad_tree_remove(scene->quad_tree, scene_object);
}

ERPG_Scene_object * ERPG_scene_remove_list_index(ERPG_Scene *scene, int index)
{
	return 0;
}

void ERPG_scene_print_sprite(ERPG_Scene *scene, ERPG_Static_object *scene_object)
{
	scene_object->sprite->destination.x = scene_object->bound_box.x - scene->boundBoxSize.x;
	scene_object->sprite->destination.y = scene_object->bound_box.y - scene->boundBoxSize.y;

	ERPG_copy_sprite_to_renderer(scene_object->sprite);
}

void ERPG_scene_print_list(ERPG_Scene *scene)
{
	CList* list = scene->scene_list;
	CList* render_list = create_clist();
	ERPG_Quad_tree_retrieve(scene->quad_tree, scene->boundBoxSize, render_list);

	for(int z = 0; z < cnode_length(render_list); z++)
	{
		ERPG_Static_object * sobj =(ERPG_Static_object*) get_cnode(list, z);

		if(sobj && sobj->sprite)
		{
			SDL_Rect rect;
			if(SDL_IntersectRect(&scene->boundBoxSize, &sobj->bound_box, &rect)){
				ERPG_scene_print_sprite(scene, sobj);
			}
		}
	}

	remove_clist(render_list);
	free(render_list);
}

List* ERPG_scene_get_field_object(ERPG_Scene *scene, int x_arg, int y_arg)
{
	int x = x_arg / scene->tileWidth;
	int y = y_arg / scene->tileHeight;

	int position = field_position1D(scene, x, y);

	if(position >= scene_get_array_length(scene))
	{
		return 0;
	}

	return scene->scene_field[position];
}

void ERPG_scene_draw(ERPG_Scene *scene)
{
	int minX = scene->boundBoxSize.x/scene->tileWidth;
	int minY = scene->boundBoxSize.y/scene->tileHeight;
	int maxWidth = minX + scene->boundBoxSize.w/scene->tileWidth + 1;
	int maxHeight = minY + scene->boundBoxSize.h/scene->tileHeight + 1;

	SDL_Texture * texture = scene->target;
	ERPG_prepare_target_texture(texture);

	for(int y = minY; y < maxHeight && y < scene->sizeHeight; y++)
	{
		for(int x = minX; x < maxWidth && x < scene->sizeWidth ; x++)
		{
			int newX = field_position1D(scene, x, y);
			if(newX >= scene_get_array_length(scene))
			{
				printf("huh alert %d \n", newX);
			}

			List* list = scene->scene_field[newX];
			if(!list)
			{
				continue;
			}
			for(int z = 0; z < scene->layers; z++)
			{
				ERPG_Static_object * sobj = get_static_object(list_int_search_node(list, z));

				if(sobj && sobj->sprite)
				{
					ERPG_scene_print_sprite(scene, sobj);
				}
			}
		}
	}
	ERPG_scene_print_list(scene);

	ERPG_Sprite * sprite = ERPG_create_target_texture(texture);
	ERPG_copy_sprite_to_renderer(sprite);
	ERPG_sprite_destroy(sprite);
	free(sprite);
}

void ERPG_scene_remove_fields(ERPG_Scene* scene)
{
	for(int x = 0; x < scene_get_array_length(scene); x++)
	{
		List* list = scene->scene_field[x];
		if(list)
			destroy_int_list(list);
		free(list);
		scene->scene_field[x] = NULL;
	}
	free(scene->scene_field);
	scene->scene_field = NULL;
}

void ERPG_scene_destroy(ERPG_Scene *scene)
{
	ERPG_scene_remove_fields(scene);
	remove_clist(scene->scene_list);
	free(scene->scene_list);
	scene->scene_list = NULL;
	ERPG_Quad_tree_destroy(scene->quad_tree);
	free(scene->quad_tree);
	scene->quad_tree = NULL;

	if(scene->target)
	{
		SDL_DestroyTexture(scene->target);
	}

	if(collision_iter)
	{
		//remove_clist(collision_iter);
		//free(collision_iter);
	}

	remove_clist(scene->collision_iter);
	free(scene->collision_iter);
}


CList* scene_collide_list(CList* list, SDL_Rect bound_box,CList* out_list)
{
	CNode* node = list->root;

	while(node)
	{
		ERPG_Static_object* sobj = (ERPG_Static_object*)node->value;
		SDL_Rect rect_out;

		if(SDL_IntersectRect(&sobj->bound_box, &bound_box, &rect_out))
		{
			add_cnode(out_list, sobj);
		}

		node = node->next;
	}

	return out_list;
}

SDL_bool ERPG_scene_is_dynamic_collision(ERPG_Scene* scene, SDL_Rect bound_box, CList* list_out)
{
	CList* list = create_clist();
	ERPG_Quad_tree_retrieve(scene->quad_tree, bound_box, list);

	scene_collide_list(list, bound_box, list_out);
	remove_clist(list);
	free(list);
}

CList* ERPG_scene_is_collision(ERPG_Scene *scene, SDL_Rect bound_box, SDL_Rect *rect_out)
{
	int minX = bound_box.x/scene->tileWidth;
	int minY = bound_box.y/scene->tileHeight;
	int maxX = minX + (bound_box.w/scene->tileWidth)+2;
	int maxY = minY + (bound_box.h/scene->tileHeight)+2;

	if(minX < 0)
		minX = 0;
	if(minY < 0)
		minY = 0;
	if(maxX < 0)
		maxX = 0;
	if(maxY < 0)
		maxY = 0;

	CList* collisions = create_clist();
	ERPG_scene_is_dynamic_collision(scene, bound_box, collisions);

	for(int y = minY; y < maxY && y < scene->sizeHeight; y++) {
		for (int x = minX; x < maxX && x < scene->sizeWidth; x++) {
			int newX = field_position1D(scene, x, y);
			List *list = scene->scene_field[newX];
			if (!list) {
				continue;
			}
			for (int z = 1; z < list_get_length(list); z++) {
				ERPG_Static_object * sobj = get_static_object(list_int_search_node(list, z));
				if(sobj)
				{
					SDL_bool result = SDL_IntersectRect(&sobj->bound_box,
					                                    &bound_box,
					                                    rect_out);
					if(result){
						add_cnode(collisions, sobj);
					}
				}
			}
		}
	}

	return collisions;
}

int Lua_Scene(lua_State * L)
{
	ERPG_Scene * lua_scene = lua_newuserdata(L, sizeof(ERPG_Scene));

	ERPG_Scene * scene = ERPG_scene_make();

	memcpy(lua_scene, scene, sizeof(ERPG_Scene));

	free(scene);

	luaL_setmetatable(L, "ERPG_Scene");

	return 1;
}

int Scene_list_iter (lua_State *L) {
	if(collision_node)
	{
		collision_element++;
		lua_pushnumber(L, collision_element);

		ERPG_Static_object* collision = (ERPG_Static_object*)collision_node->value;
		lua_rawgeti(L, LUA_REGISTRYINDEX, collision->lua_registry);

		collision_node = collision_node->next;
	}
	else
	{
		lua_pushnil(L);
		lua_pushnil(L);
	}

	return 2;
}

int Lua_scene_get_collision_iter (lua_State *L) {
	ERPG_Scene * scene = lua_touserdata(L, 1);
	SDL_Rect rect = Lua_from_create_rect_static(L, 2);
	SDL_Rect rect_out;

	if(collision_iter)
	{
		remove_clist(collision_iter);
		free(collision_iter);
		collision_iter = NULL;
	}

	collision_iter = ERPG_scene_is_collision(scene, rect, &rect_out);
	collision_node = collision_iter->root;
	collision_element = 1;

	lua_pushcclosure(L, Scene_list_iter, 0);

	return 1;
}

int Lua_is_scene_collision(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	SDL_Rect rect = Lua_from_create_rect_static(L, 2);
	SDL_Rect rect_out;
	CList* list = ERPG_scene_is_collision(scene, rect, &rect_out);
	CNode* node = list->root;

	lua_newtable(L);
	if(list) {
		int i = 0;
		while(node){
			ERPG_Static_object * static_object = (ERPG_Static_object*) get_cnode(list, i);

			if(static_object)
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);
				lua_rawseti(L, -2, i+1);
				i++;
			}
			node = node->next;
		}

		remove_clist(list);
		free(list);
	}

	return 1;
}

int Lua_set_tile_size_scene(lua_State * L)
{
	ERPG_scene_set_tile_size(lua_touserdata(L, 1), lua_tointeger(L, 2), lua_tointeger(L, 3));
	return 0;
}

int Lua_set_bound_box_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	int x = lua_tonumber(L, 2);
	int y = lua_tonumber(L, 3);
	int w = lua_tonumber(L, 4);
	int h = lua_tonumber(L, 5);

	SDL_Rect rect = {x : x, y: y, w: w, h: h};

	ERPG_scene_set_bound_box(scene, rect);

	return 0;
}

int Lua_add_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_Static_object * old = ERPG_scene_add_field_object(scene, static_object);

	if(old)
		lua_rawgeti(L, LUA_REGISTRYINDEX, old->lua_object_ref);
	else
		lua_pushnil(L);

	return 1;
}

int Lua_add_list_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = lua_touserdata(L, 2);

	ERPG_scene_add_list_object(scene, static_object);


	return 0;
}

int Lua_remove_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = Lua_Static_object_check(L, 2);

	if(ERPG_scene_remove_field_object(scene, static_object))
	{
		luaL_unref(L, LUA_REGISTRYINDEX, static_object->lua_registry);
		static_object->lua_registry = LUA_REFNIL;
	}

	return 0;
}

int Lua_remove_list_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = Lua_Static_object_check(L, 2);

	ERPG_scene_remove_list_object(scene, static_object);

	luaL_unref(L, LUA_REGISTRYINDEX, static_object->lua_registry);
	static_object->lua_registry = LUA_REFNIL;

	return 0;
}

int Lua_scene_set_layers(lua_State * L)
{
	ERPG_scene_set_layers(lua_touserdata(L, 1), lua_tointeger(L, 2));

	return 0;
}

int Lua_set_size_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);

	int w = lua_tonumber(L, 2);
	int h = lua_tonumber(L, 3);

	ERPG_scene_set_size(scene, w, h);

	return 0;
}

int Lua_scene_get_list_objects(lua_State* L)
{
	ERPG_Scene* scene = lua_touserdata(L, 1);
	SDL_Rect rect = Lua_from_create_rect_static(L, 2);

	CList* list = ERPG_scene_get_list_objects(scene, rect);

	lua_newtable(L);
	if(list) {
		for (int i = 0; i < get_clist_length(list); i++) {
			ERPG_Static_object * static_object = (ERPG_Static_object*) get_cnode(list, i);
			if(static_object)
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);
				lua_rawseti(L, -2, i+1);
			}
		}

		remove_clist(list);
		free(list);
	}

	return 1;
}

int Lua_get_field_object_scene(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);
	List* list = ERPG_scene_get_field_object(scene, lua_tonumber(L, 2), lua_tonumber(L, 3));

	lua_newtable(L);
	if(list) {
		for (int i = 0; i < list_get_length(list); i++) {
			ERPG_Static_object * static_object = get_static_object(list_int_search_node(list, i));
			if(static_object)
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);
				lua_rawseti(L, -2, i+1);
			}
		}
	}

	return 1;
}

int Lua_scene_set_so_bound_box(lua_State * L)
{
	ERPG_Scene* scene = lua_touserdata(L, 1);
	ERPG_Static_object* static_object = Lua_Static_object_check(L, 2);
	SDL_Rect rect = Lua_from_create_rect_static(L, 3);
	if(ERPG_Quad_tree_remove(scene->quad_tree, static_object))
	{
		ERPG_so_set_bound_box(static_object, rect);
		ERPG_Quad_tree_insert(scene->quad_tree, static_object);
	}
	else
	{
		printf("Cannot find element in quad tree \n");
	}

	return 0;
}

int Lua_draw_scene(lua_State * L)
{
	ERPG_scene_draw(lua_touserdata(L, 1));

	return 0;
}

int Lua_Scene_gc(lua_State * L)
{
	ERPG_Scene * scene = lua_touserdata(L, 1);

	for(int x = 0; x < get_clist_length(scene->scene_list); x++)
	{
		ERPG_Static_object* sobj = (ERPG_Static_object*)get_cnode(scene->scene_list, x);

		if(sobj)
		{
			Lua_static_object_unref(L, sobj);
			luaL_unref(L, LUA_REGISTRYINDEX, sobj->lua_registry);
			sobj->lua_registry = LUA_REFNIL;
		}
	}

	for(int x = 0; x < scene_get_array_length(scene); x++)
	{
		List* list = scene->scene_field[x];
		if(!list)
		{
			continue;
		}
		for(int z = 0; z < scene->layers; z++)
		{
			ERPG_Static_object * sobj = get_static_object(list_int_search_node(list, z));

			if(sobj)
			{
				Lua_static_object_unref(L, sobj);
				luaL_unref(L, LUA_REGISTRYINDEX, sobj->lua_registry);
				sobj->lua_registry = LUA_REFNIL;
			}
		}
	}

	ERPG_scene_destroy(scene);

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
			{"setTileSize", Lua_set_tile_size_scene},
			{"setLayers", Lua_scene_set_layers},
			{"getListObjects", Lua_scene_get_list_objects},
			{"getCollisionIter", Lua_scene_get_collision_iter},
			{"setSceneObjBoundBox", Lua_scene_set_so_bound_box},
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