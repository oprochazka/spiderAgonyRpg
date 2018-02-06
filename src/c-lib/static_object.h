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
}ERPG_Static_object;

ERPG_Static_object* ERPG_make_static_object();

void ERPG_set_id_so(ERPG_Static_object * static_object, int id);

void ERPG_set_sprite_so(ERPG_Static_object* static_object, ERPG_Sprite * sprite);

void ERPG_destroy_so(ERPG_Static_object * static_object);

int luaopen_ERPG_Static_object(lua_State * L);

#endif //C_LIB_STATIC_OBJECT_H
