#ifndef LIST_H
#define LIST_H

typedef struct Node{
  char * name;
  void * value;
  struct  Node * next;
}Node;

typedef struct{
  Node * root;
}List;

typedef struct CNode{
  void * value;
  struct  CNode * next;
}CNode;

typedef struct{
  CNode * root;
}CList;


List * create_list();
void add_node(List * n, char * name, void * value);
Node * search_node(List * l, char * search_name);
void * list_get_value(List * l, char * search_name);
Node * remove_node(List * l, char * search_name);
void destroy_list(List * l );

CList * create_clist();
void add_cnode(CList * n, void * value);
CNode* remove_cnode(CList * l, int index);
CNode* get_cnode(CList *l, int index);
void remove_clist(CList * l );
CNode* replace_cnode(CList * l, void * pointer, void * new_pointer);
CNode* remove_cnode_by_pointer(CList * l, void * pointer);
int cnode_length(CList * l);
#endif
