#ifndef LIST_H
#define LIST_H

typedef struct Node {
	char *name;
	int key;
	void *value;
	struct Node *next;
} Node;

typedef struct {
	Node *root;
	int length;
} List;

typedef struct CNode {
	void *value;
	struct CNode *next;
} CNode;

typedef struct {
	CNode *root;
	int length;
} CList;


List *create_list();

void add_node(List *list, char *name, void *value);

Node *search_node(List *l, char *search_name);

Node * list_int_search_node(List *l, int index);

Node *remove_int_node(List *l, int i);

void* add_int_node(List *list, int i, void *value);

void clist_iter(CList* l, void (*f)(void*));


void destroy_int_list(List *l);

void *list_get_value(List *l, char *search_name);

int list_get_length(List* list);

Node *remove_node(List *l, char *search_name);

void destroy_list(List *l);

CList *create_clist();

int get_clist_length(CList* list);

void add_cnode(CList *n, void *value);

void *remove_cnode(CList *l, int index);

void *get_cnode(CList *l, int index);

void remove_clist(CList *l);

CNode *replace_cnode(CList *l, void *pointer, void *new_pointer);

CNode *remove_cnode_by_pointer(CList *l, void *pointer);

int cnode_length(CList *l);

#endif
