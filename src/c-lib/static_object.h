//
// Created by ondrej on 4.2.18.
//

#ifndef C_LIB_STATIC_OBJECT_H
#define C_LIB_STATIC_OBJECT_H

#include "sprite.h"

typedef struct ERPG_Static_object{
	ERPG_Sprite * sprite;
	SDL_Rect bound_box;
	int lua_registry;
	int lua_object_ref;
	int lua_sprite_ref;
	int layer;
}ERPG_Static_object;

ERPG_Static_object* ERPG_so_make();

void ERPG_so_set_id(ERPG_Static_object *static_object, int id);

void ERPG_so_set_bound_box(ERPG_Static_object *static_object, SDL_Rect bound_box);

void ERPG_so_set_sprite(ERPG_Static_object *static_object, ERPG_Sprite *sprite);

void ERPG_so_destroy(ERPG_Static_object *static_object);

void Lua_static_object_unref(lua_State* L, ERPG_Static_object* static_object);

ERPG_Static_object * Lua_Static_object_check(lua_State * L, int i);

int luaopen_ERPG_Static_object(lua_State * L);

#endif //C_LIB_STATIC_OBJECT_H
