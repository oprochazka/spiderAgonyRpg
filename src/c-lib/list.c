#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include"list.h"

/* Asociativní seznamy add_node, search_node funguje zbytek netestován */


List *create_list() {
	List *out = (List *) malloc(sizeof(List));
	out->root = NULL;
	out->length = 0;
	return out;
}

Node *next_node(Node *n) {
	if (n->next)
		return n->next;
	return NULL;
}

void add_node(List *list, char *name, void *value) {
	Node *tmp = list->root;

	Node *new = (Node *) malloc(sizeof(Node));
	new->name = name;
	new->value = value;
	new->key = 0;
	new->next = NULL;

	if (tmp) {

		while (tmp->next) {
			tmp = tmp->next;
		}
		list->length++;
		tmp->next = new;
	} else {
		list->length++;
		list->root = new;
	}
}


Node *search_node(List *l, char *search_name) {
	Node *tmp = l->root;
	if (tmp) {
		while (tmp) {
			if (strcmp(tmp->name, search_name) == 0)
				return tmp;
			tmp = tmp->next;
		}
	}
	return NULL;
}

void* add_int_node(List *list, int i, void *value) {
	Node *tmp = list->root;

	Node *new = (Node *) malloc(sizeof(Node));
	new->name = NULL;
	new->key = i;
	new->value = value;
	new->next = NULL;

	if (tmp) {
		while (tmp->next) {
			if(i == tmp->key)
			{
				void* oldValue = tmp->value;
				tmp->value = value;
				free(new);
				return oldValue;
			}
			tmp = tmp->next;
		}
		if(i == tmp->key)
		{
			void* oldValue = tmp->value;
			tmp->value = value;
			free(new);
			return oldValue;
		}
		list->length++;
		tmp->next = new;
	} else {
		list->length++;
		list->root = new;
	}
	return NULL;
}


Node * list_int_search_node(List *l, int index)
{
	Node *tmp = l->root;
	if (tmp) {
		while (tmp) {
			if (tmp->key  == index)
				return tmp;
			tmp = tmp->next;
		}
	}
	return NULL;
}


void *list_get_value(List *l, char *search_name) {
	Node *n = search_node(l, search_name);
	if (n)
		return n->value;
	return NULL;
}

int node_length(List *l) {
	Node *node = l->root;
	int i = 0;
	while (node) {
		i++;

		node = node->next;
	}
	return i;
}

Node *remove_node(List *l, char *search_name) {
	Node *node = l->root;
	Node *tmp;
	void *value;
	if (node) {
		tmp = node;
		if (strcmp(node->name, search_name) == 0) {

			if (node->next == NULL) {
				l->root = NULL;
			} else {
				l->root = node->next;
			}

			value = node->value;
			free(node);
			l->length--;

			return value;
		}

		while (node) {

			if (strcmp(node->name, search_name) == 0 && node->next == NULL) {
				tmp->next = NULL;

				value = node->value;

				free(node);
				l->length--;

				return value;
			}

			if (strcmp(node->name, search_name) == 0) {
				tmp->next = node->next;

				value = node->value;

				free(node);
				l->length--;

				return value;
			}
			tmp = node;
			node = node->next;
		}
	}
	return NULL;
}

Node *remove_int_node(List *l, int i) {
	Node *node = l->root;
	Node *tmp;
	void *value;
	if (node) {
		tmp = node;
		if (node->key == i) {

			if (node->next == NULL) {
				l->root = NULL;
			} else {
				l->root = node->next;
			}

			value = node->value;
			free(node);
			l->length--;

			return value;
		}

		while (node) {

			if (node->key == i && node->next == NULL) {
				tmp->next = NULL;

				value = node->value;


				free(node);
				l->length--;

				return value;
			}

			if (node->key == i ) {
				tmp->next = node->next;

				value = node->value;

				free(node);
				l->length--;

				return value;
			}
			tmp = node;
			node = node->next;
		}
	}
	return NULL;
}


int list_get_length(List* list)
{
	return list->length;
}

CList *create_clist() {
	CList *out = (CList *) malloc(sizeof(CList));
	out->root = NULL;
	out->length = 0;
	return out;
}

int get_clist_length(CList *list) {
	return list->length;
}

void add_cnode(CList *n, void *value) {
	CNode *tmp = n->root;

	CNode *new = (CNode *) malloc(sizeof(CNode));
	new->value = value;
	new->next = NULL;

	if (tmp) {
		while (tmp->next) {
			if (tmp->value == value) {
				return;
			}
			tmp = tmp->next;
		}
		n->length++;
		tmp->next = new;
	} else {
		n->root = new;
		n->length++;
	}
}

void *get_cnode(CList *l, int index) {
	CNode *node = l->root;
	CNode *tmp;
	void *value;
	if (node) {
		if (index == 0) {
			value = node->value;
			return value;
		}
		for (int i = 0; i < index - 1; i++) {
			if (!node)
				break;
			node = node->next;
		}
		if (node->next->next != NULL) {
			tmp = node->next;
			value = tmp->value;
			return value;
		} else {
			tmp = node->next;
			value = tmp->value;
			return value;
		}
	}
	return NULL;
}

void clist_iter(CList* l, void (*f)(void*))
{
	CNode* node = l->root;

	while(node)
	{
		f(node->value);

		node = node->next;
	}
}

void *remove_cnode(CList *l, int index) {
	CNode *node = l->root;
	CNode *tmp;
	void *value;
	if (node) {
		if (index == 0) {
			value = node->value;
			l->root = node->next;
			free(node);
			l->length--;
			return value;
		}
		for (int i = 0; i < index - 1; i++) {

			if (!node)
				break;

			node = node->next;
		}
		if (node->next->next != NULL) {
			tmp = node->next;
			node->next = node->next->next;
			value = tmp->value;
			free(tmp);
			l->length--;
			return value;
		} else {
			tmp = node->next;
			node->next = NULL;
			value = tmp->value;
			free(tmp);
			l->length--;
			return value;
		}
	}
	return NULL;
}

CNode *remove_cnode_by_pointer(CList *l, void *pointer) {
	CNode *node = l->root;
	CNode *tmp;
	void *value;
	int index = 0;
	if (node) {
		if (index == 0 && node->value == pointer) {
			value = node->value;
			l->root = node->next;
			free(node);
			l->length--;
			return value;
		}
		while (node->next->value != pointer) {
			if (!node)
				break;
			node = node->next;
		}
		if (node->next->next != NULL) {
			tmp = node->next;
			node->next = node->next->next;
			value = tmp->value;
			free(tmp);
			l->length--;
			return value;
		} else {
			tmp = node->next;
			node->next = NULL;
			value = tmp->value;
			free(tmp);
			l->length--;
			return value;
		}
	}
	return NULL;
}

CNode *replace_cnode(CList *l, void *pointer, void *new_pointer) {
	CNode *tmp = l->root;
	if (tmp) {
		while (tmp) {
			if (pointer == tmp->value) {
				CNode *tmp1 = tmp->value;
				tmp->value = new_pointer;
				return tmp1;
			}
			tmp = tmp->next;
		}
	}
	return NULL;
}


void remove_clist(CList *l) {
	CNode *node = l->root;
	CNode *tmp;
	if (node) {
		while (node) {
			tmp = node->next;
			free(node);
			node = tmp;
		}
	}
	l->root = NULL;
	l->length = 0;
}

void destroy_list(List *l) {
	Node *node = l->root;
	Node *tmp;
	if (node) {
		while (node) {
			tmp = node->next;
			if(node->name)
				free(node->name);
			free(node);
			node = tmp;
		}
	}
}

void destroy_int_list(List *l) {
	Node *node = l->root;
	Node *tmp;
	if (node) {
		while (node) {
			tmp = node->next;
			free(node);
			node = tmp;
		}
	}
}

int cnode_length(CList *l) {
	CNode *node = l->root;
	int i = 0;
	while (node) {
		i++;

		node = node->next;
	}
	return i;
}