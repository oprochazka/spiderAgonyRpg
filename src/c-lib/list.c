#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include"list.h"

/* Asociativní seznamy add_node, search_node funguje zbytek netestován */

Node *next_node(Node *n) {
	if (n->next)
		return n->next;
	return NULL;
}

void add_node(List *n, char *name, void *value) {
	Node *tmp = n->root;

	Node *new = (Node *) malloc(sizeof(Node));
	new->name = name;
	new->value = value;
	new->next = NULL;

	if (tmp) {

		while (tmp->next) {
			tmp = tmp->next;
		}
		tmp->next = new;
	} else
		n->root = new;
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

			return value;
		}

		while (node) {

			if (strcmp(node->name, search_name) == 0 && node->next == NULL) {
				tmp->next = NULL;

				value = node->value;

				free(node);

				return value;
			}


			if (strcmp(node->name, search_name) == 0) {
				tmp->next = node->next;

				value = node->value;

				free(node);

				return value;
			}
			tmp = node;
			node = node->next;
		}
	}
	return NULL;

}

List *create_list() {
	List *out = (List *) malloc(sizeof(List));
	out->root = NULL;
	return out;
}

CList *create_clist() {
	CList *out = (CList *) malloc(sizeof(CList));
	out->root = NULL;
	return out;
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
		tmp->next = new;
	} else
		n->root = new;
}

CNode *get_cnode(CList *l, int index) {
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


CNode *remove_cnode(CList *l, int index) {
	CNode *node = l->root;
	CNode *tmp;
	void *value;
	if (node) {
		if (index == 0) {
			value = node->value;
			l->root = node->next;
			free(node);
			return value;
		}
		for (int i = 0; i < index-1; i++) {

			if (!node)
				break;

			node = node->next;
		}
		if (node->next->next != NULL) {
			tmp = node->next;
			node->next = node->next->next;
			value = tmp->value;
			free(tmp);
			return value;
		} else {
			tmp = node->next;
			node->next = NULL;
			value = tmp->value;
			free(tmp);
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
			return value;
		} else {
			tmp = node->next;
			node->next = NULL;
			value = tmp->value;
			free(tmp);
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

}

void destroy_list(List *l) {
	Node *node = l->root;
	Node *tmp;
	if (node) {
		while (node) {
			tmp = node->next;
			free(node->name);
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