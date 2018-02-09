//
// Created by ondrej on 4.2.18.
//

#ifndef C_LIB_SCENE_LAYER_H
#define C_LIB_SCENE_LAYER_H

#include "scene_object.h"
#include "list.h"
#include "static_object.h"
#include "quadtree.h"

typedef struct ERPG_Scene{
	int tileWidth;
	int tileHeight;
	int sizeWidth;
	int sizeHeight;
	int layers;

	ERPG_Quad_tree* quad_tree;
	SDL_Texture * target;
	SDL_Rect boundBoxSize;
	List ** scene_field;
	CList * scene_list;
	CList * collision_iter;
	CNode* collision_iter_node;
}ERPG_Scene;

ERPG_Scene* ERPG_scene_make();

void ERPG_scene_set_tile_size(ERPG_Scene *scene, int width, int height);

void ERPG_scene_set_size(ERPG_Scene *scene, int width, int height);

ERPG_Static_object* ERPG_scene_add_field_object(ERPG_Scene *scene, ERPG_Static_object *scene_object);

void ERPG_scene_remove_fields(ERPG_Scene* scene);

void ERPG_scene_add_list_object(ERPG_Scene *scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * remove_field_object(ERPG_Scene * scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * ERPG_scene_remove_field_index(ERPG_Scene *scene, int id);

ERPG_Scene_object * ERPG_scene_remove_list_object(ERPG_Scene *scene, ERPG_Static_object *scene_object);

ERPG_Scene_object * ERPG_scene_remove_list_index(ERPG_Scene *scene, int index);

void ERPG_scene_destroy(ERPG_Scene *scene);

int luaopen_ERPG_scene(lua_State * L);

#endif //C_LIB_SCENE_LAYER_H
