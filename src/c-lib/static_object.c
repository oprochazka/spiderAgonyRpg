//
// Created by ondrej on 4.2.18.
//

#include "static_object.h"
#include "sprite.h"
#include "lua_func.h"

ERPG_Static_object* ERPG_so_make()
{
	ERPG_Static_object * static_object = (ERPG_Static_object*)malloc(sizeof(ERPG_Static_object));

	SDL_Rect bound_box = {x: 0, y: 0, w: 0, h: 0};

	static_object->sprite = NULL;
	static_object->bound_box = bound_box;
	static_object->lua_object_ref = LUA_REFNIL;
	static_object->lua_registry = LUA_REFNIL;
	static_object->lua_sprite_ref = LUA_REFNIL;
	static_object->layer = 0;

	return static_object;
}

void ERPG_so_set_bound_box(ERPG_Static_object *static_object, SDL_Rect bound_box)
{
	static_object->bound_box = bound_box;
}

void ERPG_so_set_layer(ERPG_Static_object *static_object, int layer)
{
	static_object->layer = layer;
}

void ERPG_so_set_id(ERPG_Static_object *static_object, int id)
{

}

void ERPG_so_set_sprite(ERPG_Static_object *static_object, ERPG_Sprite *sprite)
{
	static_object->sprite = sprite;
}

void ERPG_so_destroy(ERPG_Static_object *static_object)
{

}

void ERPG_so_save(ERPG_Static_object *static_object)
{

}

ERPG_Static_object * Lua_Static_object_check(lua_State * L, int i)
{
	return luaL_checkudata(L, i, "ERPG_StaticObject");
}

int Lua_Static_object(lua_State * L)
{
	ERPG_Static_object * lua_static_object = lua_newuserdata(L, sizeof(ERPG_Static_object));

	ERPG_Static_object * static_object = ERPG_so_make();

	memcpy(lua_static_object, static_object, sizeof(ERPG_Static_object));

	free(static_object);

	luaL_setmetatable(L, "ERPG_StaticObject");

	int ref = luaL_ref (L, LUA_REGISTRYINDEX);

	lua_rawgeti(L, LUA_REGISTRYINDEX, ref);

	lua_static_object->lua_registry = ref;

	return 1;
}

int Lua_set_bound_box_so(lua_State * L)
{
	ERPG_Static_object * static_object = lua_touserdata(L, 1);
	SDL_Rect rect = Lua_from_create_rect_static(L, 2);

	ERPG_so_set_bound_box(static_object, rect);

	//ERPG_Quad_tree_remove(scene->quad_tree, scene_object);

	lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);

	return 0;
}

int Lua_object_set_ref_so(lua_State * L)
{
	ERPG_Static_object * lua_static_object =  lua_touserdata(L,1);

	if(lua_istable(L, 2))
	{
		int ref = luaL_ref (L, LUA_REGISTRYINDEX);
		lua_static_object->lua_object_ref = ref;
	}

	return 0;
}

int Lua_object_get_ref_so(lua_State * L)
{
	ERPG_Static_object * lua_static_object = lua_touserdata(L, 1);
	lua_rawgeti(L, LUA_REGISTRYINDEX, lua_static_object->lua_object_ref);

	return 1;
}


int Lua_set_sprite_so(lua_State * L)
{
	ERPG_Static_object * static_object = lua_touserdata(L, 1);
	ERPG_so_set_sprite(static_object, Lua_check_sprite(L, 2));

	int ref = luaL_ref (L, LUA_REGISTRYINDEX);
	static_object->lua_sprite_ref = ref;

	return 0;
}

int Lua_set_layer_so(lua_State * L)
{
	ERPG_so_set_layer(lua_touserdata(L, 1), (int)lua_tonumber(L, 2));

	return 0;
}

void Lua_static_object_unref(lua_State* L, ERPG_Static_object* static_object)
{
	if(static_object->sprite != LUA_REFNIL)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, static_object->lua_sprite_ref);
		static_object->lua_sprite_ref = LUA_REFNIL;
	}
	if(static_object->lua_object_ref != LUA_REFNIL)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, static_object->lua_object_ref);
		static_object->lua_object_ref = LUA_REFNIL;
	}
}
int Lua_static_object_gc(lua_State * L)
{
	ERPG_Static_object * static_object = lua_touserdata(L, 1);
//	ERPG_so_destroy(static_object);
	Lua_static_object_unref(L,static_object);

	return 0;
}

int luaopen_ERPG_Static_object(lua_State * L)
{
	static const luaL_Reg method[] = {
			{"setSprite", Lua_set_sprite_so},
			{"setBoundBox", Lua_set_bound_box_so},
			{"setReference", Lua_object_set_ref_so},
			{"getReference", Lua_object_get_ref_so},
			{"setLayer", Lua_set_layer_so},
			{NULL, NULL}
	};

	static const luaL_Reg sprite_lib[] = {
			{"make", Lua_Static_object},
			{NULL, NULL}
	};
	luaL_newmetatable(L, "ERPG_StaticObject");
	luaL_newlib(L, method);
	lua_setfield(L, -2, "__index");

	lua_pushcfunction(L, Lua_static_object_gc);
	lua_setfield(L, -2, "__gc");

	luaL_newlib(L, sprite_lib);

	return 1;
}