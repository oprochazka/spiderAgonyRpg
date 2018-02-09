//
// Created by ondrej on 8.2.18.
//

#ifndef C_LIB_QUADTREE_H
#define C_LIB_QUADTREE_H

#include <SDL2/SDL_rect.h>
#include "list.h"
#include "static_object.h"

typedef struct Quad_node {
	int level;
	struct Quad_node * parrent;

	CList * objects;
	struct Quad_node ** quad_nodes;
	SDL_Rect bounds;
}Quad_node;

typedef struct ERPG_Quad_tree{
	int level;
	SDL_Rect size;
	struct Quad_node* root;
}ERPG_Quad_tree;

#endif //C_LIB_QUADTREE_H

ERPG_Quad_tree* ERPG_quadtree_make(int w, int h);
void ERPG_Quad_tree_insert(ERPG_Quad_tree* quad_tree, ERPG_Static_object* static_object);
CList* ERPG_Quad_tree_retrieve(ERPG_Quad_tree* quad_tree, SDL_Rect rect, CList* list);
ERPG_Static_object* ERPG_Quad_tree_remove(ERPG_Quad_tree* quad_tree, ERPG_Static_object * static_object);
void ERPG_Quad_tree_destroy(ERPG_Quad_tree* quad_tree);
