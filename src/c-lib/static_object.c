//
// Created by ondrej on 4.2.18.
//

#include "static_object.h"
#include "sprite.h"
#include "lua_func.h"

ERPG_Static_object* ERPG_make_static_object()
{
	ERPG_Static_object * static_object = (ERPG_Static_object*)malloc(sizeof(ERPG_Static_object));

	SDL_Rect bound_box = {x: 0, y: 0, w: 0, h: 0};

	static_object->sprite = 0;
	static_object->bound_box = bound_box;

	return static_object;
}

void ERPG_set_bound_box_so(ERPG_Static_object * static_object, SDL_Rect bound_box)
{
	static_object->bound_box = bound_box;
}

void ERPG_set_id_so(ERPG_Static_object * static_object, int id)
{

}

void ERPG_set_sprite_so(ERPG_Static_object* static_object, ERPG_Sprite * sprite)
{
	static_object->sprite = sprite;
}

void ERPG_destroy_so(ERPG_Static_object * static_object)
{

}

void ERPG_save_so(ERPG_Static_object * static_object)
{

}

int Lua_Static_object(lua_State * L)
{
	ERPG_Static_object * lua_static_object = lua_newuserdata(L, sizeof(ERPG_Static_object));

	ERPG_Static_object * static_object = ERPG_make_static_object();

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

	ERPG_set_bound_box_so(static_object, rect);

	lua_rawgeti(L, LUA_REGISTRYINDEX, static_object->lua_registry);

	return 1;
}

int Lua_set_sprite_so(lua_State * L)
{
	ERPG_set_sprite_so(lua_touserdata(L, 1), lua_touserdata(L, 2));

	return 0;
}

int Lua_static_object_gc(lua_State * L)
{
	ERPG_Static_object * static_object = lua_touserdata(L, 1);

	ERPG_destroy_so(static_object);

	return 0;
}

int luaopen_ERPG_Static_object(lua_State * L)
{
	static const luaL_Reg method[] = {
			{"setSprite", Lua_set_sprite_so},
			{"setBoundBox", Lua_set_bound_box_so},
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