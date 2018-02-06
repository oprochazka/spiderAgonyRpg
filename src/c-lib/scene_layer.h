//
// Created by ondrej on 4.2.18.
//

#ifndef C_LIB_SCENE_LAYER_H
#define C_LIB_SCENE_LAYER_H

#include "scene_object.h"
#include "list.h"
#include "static_object.h"

typedef struct ERPG_Scene{
	int tileWidth;
	int tileHeight;
	int sizeWidth;
	int sizeHeight;
	SDL_Texture * target;
	SDL_Rect boundBoxSize;
	CList ** scene_field;
	CList * scene_list;
}ERPG_Scene;

ERPG_Scene* ERPG_make_scene();

void ERPG_set_tile_size_scene(ERPG_Scene * scene, int width, int height);

void ERPG_set_size_scene(ERPG_Scene * scene, int width, int height);

void ERPG_add_field_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object);

void ERPG_add_list_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * remove_field_object(ERPG_Scene * scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * ERPG_remove_field_index_scene(ERPG_Scene *scene, int id);

ERPG_Scene_object * ERPG_remove_list_object_scene(ERPG_Scene *scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * ERPG_remove_list_index_scene(ERPG_Scene *scene, int index);

void ERPG_destroy_scene(ERPG_Scene * scene);

int luaopen_ERPG_scene(lua_State * L);

#endif //C_LIB_SCENE_LAYER_H
