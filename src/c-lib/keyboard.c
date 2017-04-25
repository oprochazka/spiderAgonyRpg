#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include <time.h>
#include "main.h"
#include "list.h"
#include<math.h>
#include<SDL2/SDL.h>
#include"keyboard.h"
ERPG_Keyboard * ERPG_Create_keyboard()
{
  ERPG_Keyboard * keyboard = (ERPG_Keyboard*)malloc(sizeof(ERPG_Keyboard));

  keyboard->press_key = create_clist();
  keyboard->release_key = create_clist();
  
  return keyboard;
}

void ERPG_Pump_keyboard(SDL_Event * events, ERPG_Keyboard * keyboard)
{
  //  if(events->key.keysym.scancode != SDL_GetScancodeFromKey(events->key.keysym.sym))
  
  CNode  * node = keyboard->press_key->root;
  CNode * node2;
  if(SDL_KEYDOWN == events->type){
    //  printf("here \n");
    const char * n =  SDL_GetKeyName(events->key.keysym.sym);
    const char * sc =  SDL_GetScancodeName(events->key.keysym.scancode);
    char * name = (char*)malloc(sizeof(char)*strlen(n)+1);        
    char * scan = (char*)malloc(sizeof(char)*strlen(sc)+1);

    strcpy(name, n);
    strcpy(scan, sc);    
    char ** strings = (char**)malloc(sizeof(char*)*2);
    strings[0] = name;
    strings[1] = scan;
    char z = 0;
    if(node){
      while(node->next){
	node2 = keyboard->release_key->root;
	while(node2){
	  if(!strcmp((char*)node2->value, name)){
	    z=1;
	    break;
	  }
	  node2 = node2->next;
	}
	
	if(!strcmp((char*)((char**)node->value)[0], name)){

	  z = 1;
	  break;
	}
	node = node->next;	
      }
      if(!strcmp((char*)((char**)node->value)[0], name)){
	z = 1;
      }
      if( z == 0 ){
	CNode * new = (CNode*)malloc(sizeof(CNode));
	new->next = NULL;
	new->value = strings;
	node->next =  new;
	//add_cnode(keyboard->press_key, strings);
      }
    }else{
      add_cnode(keyboard->press_key, strings);
    }
  }
  else if(SDL_KEYUP == events->type){
    node = keyboard->press_key->root;
    int i = 0;
    char * name = (char*)SDL_GetKeyName(events->key.keysym.sym);
    
    //  printf("name: %s \n", name);	   
    while(node){
      if(!strcmp((char*)((char**)node->value)[0], name)){
	char ** tmp = (char**)remove_cnode(keyboard->press_key, i);
	free(tmp[0]);
	free(tmp[1]);
	free(tmp);
	
	//		printf("remove: %s \n", name);	   
	break;
      }	
      i++;
      node = node->next;
    }
    
    add_cnode(keyboard->release_key, (void*)name);
  }
}



void ERPG_Destroy_keyboard(ERPG_Keyboard * keyboard)
{
  remove_clist(keyboard->press_key);
  remove_clist(keyboard->release_key);
  free(keyboard->press_key);
  free(keyboard->release_key);
}
