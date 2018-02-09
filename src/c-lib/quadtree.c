#include "quadtree.h"
#include "static_object.h"

const int MAX_OBJECTS = 10;
const int MAX_LEVELS = 5;

Quad_node* quad_tree_node_make(int level)
{
	Quad_node* out = (Quad_node*)malloc(sizeof(Quad_node));
	out->bounds = (SDL_Rect){x: 0, y:0, w: 0, h: 0};
	out->level = level;
	out->objects = create_clist();
	out->quad_nodes = calloc(4, sizeof(Quad_node*));
	out->parrent = NULL;

	return out;
}

ERPG_Quad_tree* ERPG_quadtree_make(int w, int h)
{
	ERPG_Quad_tree* out = (ERPG_Quad_tree*)malloc(sizeof(ERPG_Quad_tree));

	out->level = 0;
	out->size = (SDL_Rect){x: 0,y: 0,w: w,h: h};
	out->root = NULL;

	return out;
}

Quad_node* quad_node_set(Quad_node* quad_node, SDL_Rect rect)
{
	int new_level = quad_node->level +1;
	Quad_node* node = quad_tree_node_make(new_level);
	node->parrent = quad_node;
	node->bounds = rect;

	return node;
}

void Quad_tree_split(Quad_node* quad_tree)
{
	int subWidth = (quad_tree->bounds.w / 2);
	int subHeight = (quad_tree->bounds.h / 2);
	int x = quad_tree->bounds.x;
	int y = quad_tree->bounds.y;

	Quad_node** nodes = quad_tree->quad_nodes;

	nodes[0] = quad_node_set(quad_tree,
	                         (SDL_Rect){x: x + subWidth,y:  y, w: subWidth,h: subHeight});

	nodes[1] = quad_node_set(quad_tree,
	                         (SDL_Rect){x: x ,y:  y, w: subWidth,h: subHeight});

	nodes[2] = quad_node_set(quad_tree,
	                         (SDL_Rect){x: x ,y:  y + subHeight, w: subWidth,h: subHeight});

	nodes[3] = quad_node_set(quad_tree,
	                         (SDL_Rect){x: x + subWidth,y:  y + subHeight,
			                         w: subWidth,h: subHeight});
}

void Quad_node_connect(Quad_node* quad_node, Quad_node* quad_child)
{
//	Quad_node*
}

void Quad_tree_merge(Quad_node* quad_node)
{
	int object_sum = get_clist_length(quad_node->objects);

	for(int i = 0; i < 4; i++)
	{
		Quad_node* q = quad_node->quad_nodes[i];
		if(q)
		{
			object_sum += get_clist_length(q->objects);
		}
	}

	if(object_sum < MAX_OBJECTS)
	{
		for(int i = 0; i < 4; i++)
		{
			Quad_node* q = quad_node->quad_nodes[i];

		}
	}

}

int Quad_tree_getindex(Quad_node* quad_tree, SDL_Rect rect)
{
	SDL_Rect bounds = quad_tree->bounds;
	int index = -1;
	double verticalMidpoint = bounds.x + (bounds.w / 2);
	double horizontalMidpoint = bounds.y + (bounds.h / 2);

	char topQuadrant = (rect.y < horizontalMidpoint && rect.y + rect.h < horizontalMidpoint);
	char bottomQuadrant = (rect.y > horizontalMidpoint);

	if (rect.x < verticalMidpoint && rect.x + rect.w < verticalMidpoint) {
		if (topQuadrant) {
			index = 1;
		}
		else if (bottomQuadrant) {
			index = 2;
		}
	}
	else if (rect.x > verticalMidpoint) {
		if (topQuadrant) {
			index = 0;
		}
		else if (bottomQuadrant) {
			index = 3;
		}
	}

	return index;
}

void Quad_tree_insert(Quad_node* quad_tree, ERPG_Static_object* static_object)
{
	SDL_Rect object_rect = static_object->bound_box;
	Quad_node** nodes = quad_tree->quad_nodes;
	CList* objects = quad_tree->objects;

	if (nodes[0] != 0) {
		int index = Quad_tree_getindex(quad_tree, object_rect);

		if (index != -1) {
			Quad_tree_insert(quad_tree->quad_nodes[index], static_object);

			return;
		}
	}

	add_cnode(objects, static_object);

	if (get_clist_length(objects) > MAX_OBJECTS && quad_tree->level < MAX_LEVELS) {
		if (nodes[0] == 0) {
			Quad_tree_split(quad_tree);
		}

		int i = 0;
		while (i < get_clist_length(objects)) {
			ERPG_Static_object* static_object1 = get_cnode(objects, i);
			int index = Quad_tree_getindex(quad_tree, static_object1->bound_box);
			if (index != -1) {
				add_cnode(nodes[index]->objects, remove_cnode(objects, i));
			}
			else {
				i++;
			}
		}
	}
}

void ERPG_Quad_tree_insert(ERPG_Quad_tree* quad_tree, ERPG_Static_object* static_object)
{
	Quad_node* rootNode = quad_tree->root;

	if(!rootNode)
	{
		rootNode = quad_tree_node_make(0);
		rootNode->bounds = quad_tree->size;
		quad_tree->root = rootNode;
	}

	Quad_tree_insert(rootNode, static_object);
}

CList* Quad_tree_retrieve(Quad_node* quad_tree, SDL_Rect rect, CList* list)
{
	Quad_node** nodes = quad_tree->quad_nodes;

	if (nodes[0] != NULL)
	{
		int index = Quad_tree_getindex(quad_tree, rect);

		if (index != -1)
		{
			Quad_tree_retrieve(nodes[index], rect, list);
		}
		else
		{
			for (int i = 0; i < 4; i++)
			{
				Quad_tree_retrieve(nodes[i], rect, list);
			}
		}
	}

	for(int i = 0; i < get_clist_length(quad_tree->objects); i++)
		add_cnode(list, (ERPG_Static_object*)get_cnode(quad_tree->objects, i));

	return list;
}


CList* ERPG_Quad_tree_retrieve(ERPG_Quad_tree* quad_tree, SDL_Rect rect, CList* list)
{
	if(quad_tree->root)
		return Quad_tree_retrieve(quad_tree->root, rect,list);

	return NULL;
}

ERPG_Static_object* Quad_tree_remove(Quad_node* quad_node, ERPG_Static_object * static_object) {
	int index = Quad_tree_getindex(quad_node, static_object->bound_box);
	Quad_node **nodes = quad_node->quad_nodes;

	for (int i = 0; i < get_clist_length(quad_node->objects); i++){
		ERPG_Static_object* sobj = (ERPG_Static_object*)get_cnode(quad_node->objects, i);
		if(sobj == static_object)
		{
			return (ERPG_Static_object*)remove_cnode(quad_node->objects, i);
		}
	}

	if (index != -1 && nodes[0] != NULL) {
		return Quad_tree_remove(nodes[index], static_object);
	}
	else
	{
		return NULL;
	}
}

ERPG_Static_object*  ERPG_Quad_tree_remove(ERPG_Quad_tree* quad_tree, ERPG_Static_object * static_object)
{
	if(quad_tree->root)
	{
		return Quad_tree_remove(quad_tree->root, static_object);
	}
	return NULL;
}

void Quad_tree_destroy(Quad_node* quad_node)
{
	CList* objects = quad_node->objects;
	remove_clist(objects);
	free(objects);
	quad_node->objects = NULL;
	quad_node->parrent = NULL;

	Quad_node** quad_nodes = quad_node->quad_nodes;

	for (int i = 0; i < 4; i++) {
		Quad_node* quad = quad_nodes[i];
		if (quad) {
			Quad_tree_destroy(quad);
			free(quad);
		}
	}

	free(quad_nodes);
}

void ERPG_Quad_tree_destroy(ERPG_Quad_tree* quad_tree)
{
	Quad_node* node = quad_tree->root;
	if(node)
	{
		Quad_tree_destroy(node);
		free(node);
		quad_tree->root = NULL;
	}
}