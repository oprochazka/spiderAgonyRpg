#include<stdio.h>
#include<stdlib.h>
#include <lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL_mixer.h>
#include<SDL2/SDL_thread.h>
#include<SDL2/SDL_mutex.h>

#include"network.h"
#include"server_network.h"
#include"main.h"
#include"basic_shapes.h"
#include"mouse.h"
#include"keyboard.h"
#include"core.h"
#include"audio.h"

#include<time.h>
const static int packetSize = 1024;

static int serverLoop(void *ptr)
{
  ERPG_Network_server * net = ERPG_get_Network_server();
  while(!net->exit)
  {    
	ERPG_Network_accept_socket();
	ERPG_Network_send_string_server();
	ERPG_Network_send_string_server_broadcast();
	ERPG_Network_recieve_string_server(packetSize);
	SDL_Delay(0);
  }
  return 1;
}

ERPG_ClientSock * initClientSock(TCPsocket socket)
{
	ERPG_ClientSock * sock = (ERPG_ClientSock*)malloc(sizeof(ERPG_ClientSock));
	sock->buffer = init_buffer(2048);
	sock->socket = socket;

	return sock;
}

void ERPG_Network_create_server(int port)
{
	ERPG_CORE * core = ERPG_get_CORE();
	ERPG_Network_server * net = ERPG_get_Network_server();
	if(!net)
	{
		net = (ERPG_Network_server*)malloc(sizeof(ERPG_Network_server));	
	}else if(net->exit == 0){
		ERPG_Network_close_connection_server();
	}

	net->clientSock = NULL;
	net->clientSocks = create_list();
	net->socketSet = SDLNet_AllocSocketSet(10);
	net->exit = 0;
	net->dataMutex = SDL_CreateMutex();
 	net->inputDataMutex = SDL_CreateMutex();
 	net->inputDataBroadMutex = SDL_CreateMutex();
 	net->clientSockMutex = SDL_CreateMutex();

 	net->data=create_clist();
 	net->inputData = create_clist();
 	net->inputDataBroad = create_clist();

	core->network_server = net;

	IPaddress ipaddress;
	TCPsocket tcpsock;

	if(SDLNet_ResolveHost(&ipaddress,NULL,port)==-1) {
	    printf("SDLNet_ResolveHost: %s\n", SDLNet_GetError());
	    exit(1);
	}

	tcpsock=SDLNet_TCP_Open(&ipaddress);
	if(!tcpsock) {
	    printf("SDLNet_TCP_Open: %s\n", SDLNet_GetError());
	    exit(2);
	}
	
	net->ipaddress = ipaddress;
	net->tcpsock = tcpsock;
	net->port = port;

	SDLNet_TCP_AddSocket(net->socketSet,net->tcpsock);

	net->thread = SDL_CreateThread(serverLoop, "serverLoop", (void *)NULL);
}

void ERPG_Network_server_add_broad_string(char * socket, char * string)
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	ERPG_PacketS * packet = (ERPG_PacketS*)malloc(sizeof(ERPG_PacketS));

	packet->data = string;
	packet->dest = socket;

	if(SDL_LockMutex(net->inputDataBroadMutex) == 0)
	{		
		add_cnode(net->inputDataBroad, packet);

		SDL_UnlockMutex(net->inputDataBroadMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}
}

void ERPG_Network_server_add_string(TCPsocket socket, char * string)
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	ERPG_Packet * packet = (ERPG_Packet*)malloc(sizeof(ERPG_Packet));
	
	packet->data = string;
	packet->dest = socket;

	if(SDL_LockMutex(net->inputDataMutex) == 0)
	{
		add_cnode(net->inputData, packet);
		SDL_UnlockMutex(net->inputDataMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}
}

List * ERPG_Network_server_get_data()
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	List * list = NULL; 

	if(SDL_LockMutex(net->dataMutex) == 0)
	{	
		list = (List*) get_cnode(net->data, 0);
		if(list)
			remove_cnode(net->data,0);
		else
			list = NULL;

		SDL_UnlockMutex(net->dataMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}
	return list;
}

char * ERPG_Network_accept_socket()
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	TCPsocket new_tcpsock;

	int numready;

	numready=SDLNet_CheckSockets(net->socketSet, 0);
	if(numready==-1) {
		printf("SDLNet_CheckSockets: %s\n", SDLNet_GetError());	
		perror("SDLNet_CheckSockets");
	}
	else if(numready) {
		if(SDLNet_SocketReady(net->tcpsock)) {   
			new_tcpsock = SDLNet_TCP_Accept(net->tcpsock);
			net->clientSock = new_tcpsock;

			if(!new_tcpsock) {
			}
			else {
				char * str = NULL;
				int numused = 0;
				if(SDL_LockMutex(net->clientSockMutex) == 0)
				{	
					printf("Adding socket \n");
					str = (char*)malloc(20);
					snprintf(str,20,"%d", net->idCounter);
				
					numused = SDLNet_TCP_AddSocket(net->socketSet,new_tcpsock);

					ERPG_ClientSock * clientSock = initClientSock(new_tcpsock);

					add_node(net->clientSocks, str , clientSock);
					net->idCounter++;	    
					SDL_UnlockMutex(net->clientSockMutex);
				}
				
				if(numused==-1) {
				    printf("SDLNet_AddSocket: %s\n", SDLNet_GetError());
				}

				return str;
			}
		}
	}

	return NULL;
}

int ERPG_Network_server_unload_client(char * id)
{
	ERPG_Network_server * net = ERPG_get_Network_server();	
	Node * nsocket = search_node(net->clientSocks, id);

	if(nsocket)
	{			
		//TCPsocket socket = ((ERPG_ClientSock*)nsocket->value)->socket;
		//DLNet_TCP_DelSocket(net->socketSet,socket);

		ERPG_DestroySocket((ERPG_ClientSock*)nsocket->value);
		if(SDL_LockMutex(net->clientSockMutex) == 0)
		{	
			remove_node(net->clientSocks, id);
			SDL_UnlockMutex(net->clientSockMutex);
		}

		return 1;
	}
	return 0;
}

int ERPG_Network_send_string_server()
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	ERPG_Packet * packet = (ERPG_Packet*)get_cnode(net->inputData,0);

	if(packet)
	{
		char * value = packet->data;
		int len = strlen(value) + 1;	

		int result=SDLNet_TCP_Send(packet->dest, value, len);

		if(SDL_LockMutex(net->inputDataMutex) == 0)
		{
			remove_cnode(net->inputData,0);
			SDL_UnlockMutex(net->inputDataMutex);
		}

	    
		if(result < len ) {
		    return 0;
		}        	
	}
	return 1;
}

void ERPG_Network_send_string_server_broadcast()
{
	ERPG_Network_server * net = ERPG_get_Network_server();

	CList * data = net->inputDataBroad;
	List * socks = net->clientSocks;
	Node * node = socks->root;

	ERPG_PacketS * value;
	if(SDL_LockMutex(net->inputDataBroadMutex) == 0)
	{
		value = (ERPG_PacketS*)get_cnode(data, 0);
		SDL_UnlockMutex(net->inputDataBroadMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}

	if(!value)
	{
		return;
	}

	while(node)
	{
		Node * next = node->next;		 

		if(strcmp(node->name, value->dest))
		{	
			TCPsocket socket = ((ERPG_ClientSock*)node->value)->socket;	
			int len = strlen(value->data)+1;
			int result=SDLNet_TCP_Send(socket, (char*)value->data,len);
		//	printf("%d stringSer %s \n",len-1, (char*)value->data);
			if(result < len ) {
		  	  ERPG_Network_server_unload_client((char*)node->name);
			}			
		}
		node = next;
	}

	if(SDL_LockMutex(net->inputDataBroadMutex) == 0)
	{
		remove_cnode(net->inputDataBroad, 0);
		SDL_UnlockMutex(net->inputDataBroadMutex);
	}
}

void copyBufferServer(char * msg, ERPG_TextBuffer * txtBuffer, int maxLen, List * out, Node * node)
{
	for(int i = 0; i < maxLen; i++)
	{
		char a = msg[i];
		if(a == '$')
			continue;

		txtBuffer->buffer[txtBuffer->pointer++] = a;
		txtBuffer->isEmpty = 0;
		if(a == '\0')
		{
			char * tmp = (char*)malloc(sizeof(char)*strlen(txtBuffer->buffer) + 1);
			strcpy(tmp, txtBuffer->buffer);
								
			char * newName = (char*)malloc(sizeof(char)*strlen(node->name)+1);
			strcpy(newName, node->name);
			add_node(out, newName, tmp);		

			txtBuffer->pointer = 0;
			txtBuffer->isEmpty = 1;
		}				
	}
}

List * ERPG_Network_recieve_string_server(int maxLen)
{	
	List * out = create_list();
	ERPG_Network_server * net = ERPG_get_Network_server();

	List * socks = net->clientSocks;
	Node * node = socks->root;
	char * msg = (char*)malloc(sizeof(char)*maxLen);
	while(node)
	{
		int result;		
		int numready;

		numready=SDLNet_CheckSockets(net->socketSet, 0);
		if(numready==-1) {
			printf("SDLNet_CheckSockets: %s\n", SDLNet_GetError());
			perror("SDLNet_CheckSockets");
		}
		else if(numready) {
			ERPG_ClientSock *clientSock = (ERPG_ClientSock*)node->value;
			TCPsocket tcpSock = ((ERPG_ClientSock*)node->value)->socket;

			if(SDLNet_SocketReady(tcpSock)) {	
				
				memset(msg,'$',sizeof(char)*maxLen);

				ERPG_TextBuffer * txtBuffer = clientSock->buffer;

				result=SDLNet_TCP_Recv(tcpSock, msg,maxLen);

				if(result<=0) {
					ERPG_Network_server_unload_client((char*)node->name);
				}
				copyBufferServer(msg, txtBuffer, maxLen, out, node);	
			}
		}
		
		node = node->next;
	}

	if(SDL_LockMutex(net->dataMutex) == 0)
	{	
		if(out->root)
		{			
			add_cnode(net->data, out);			
		}
		else
		{
			destroy_list(out);
			free(out);
			out = NULL;
		}
		SDL_UnlockMutex(net->dataMutex);
	}

	free(msg);
	return out;
}

void ERPG_DestroySocket(ERPG_ClientSock * socket)
{
	free(socket->buffer->buffer);
	free(socket->buffer);
	if(socket->socket)
	{
		ERPG_Network_server * net = ERPG_get_Network_server();	

		SDLNet_TCP_DelSocket(net->socketSet, socket->socket);
	}
}

void ERPG_Network_close_connection_server()
{
	ERPG_Network_server * net = ERPG_get_Network_server();

	int threadReturnValue;
	net->exit = 1;

	SDL_WaitThread(net->thread, &threadReturnValue);

	SDL_DestroyMutex(net->dataMutex);
	SDL_DestroyMutex(net->inputDataMutex);
	SDL_DestroyMutex(net->inputDataBroadMutex);
	SDL_DestroyMutex(net->clientSockMutex);	

	Node * root = net->clientSocks->root;

	while(root)
	{
		ERPG_DestroySocket((ERPG_ClientSock*)root);

		root = root->next;
	}

	destroy_list(net->clientSocks);
	free(net->clientSocks);
	net->clientSocks = NULL;

	remove_clist(net->data);
	free(net->data);
	net->data = NULL;


	while(1)
	{
		List * list = (List*)remove_cnode(net->inputData, 0);
		if(list)
		{
			destroy_list(list);
			free(list);
		}else{
			break;
		}			
	}

	remove_clist(net->inputData);
	free(net->inputData);
	net->inputData = NULL;

	remove_clist(net->inputDataBroad);
	free(net->inputDataBroad);
	net->inputDataBroad = NULL;

	SDLNet_FreeSocketSet(net->socketSet);
	SDLNet_TCP_Close(net->tcpsock);
}

void ERPG_Network_server_destroy()
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	if(net == NULL)
		return;

	if(net->exit == 0)
	{
		ERPG_Network_close_connection_server();
	}

	free(net);
}

void ERPG_Network_server_close_connection()
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	SDLNet_TCP_Close(net->tcpsock);
}

int Lua_ERPG_Network_create_server(lua_State * L)
{
	ERPG_Network_create_server(luaL_checkinteger(L,1));
	return 0;
}

int Lua_ERPG_Network_accept_socket(lua_State * L)
{
	char * str = ERPG_Network_accept_socket();
	if(ERPG_Network_accept_socket())
	{
		lua_pushlstring(L,str, strlen(str));
	}
	else
	{
		lua_pushnil(L);
	}
	return 1;
}


int Lua_ERPG_Network_server_get_data(lua_State * L)
{
	List * list = ERPG_Network_server_get_data();
	if(list)
	{
		Node * node = list->root;
		lua_newtable(L);
		while(node)
		{
			lua_pushlstring(L, node->name, strlen(node->name));
			lua_pushlstring(L, (char*)node->value, strlen((char*)node->value));
			lua_settable(L, -3);
			node = node->next;							
		}
		destroy_list(list);
		free(list);
	}else
	{
		lua_pushnil(L);
	}

	return 1;
}

int Lua_ERPG_Network_server_add_string(lua_State * L)
{
	ERPG_Network_server * net = ERPG_get_Network_server();
	Node * node = search_node(net->clientSocks, (char*)luaL_checkstring(L,2));

	if(node)
	{
		char * luaS = (char*)luaL_checkstring(L,1);
		char * input = (char*)malloc(strlen(luaS) + 1);
		strcpy(input, luaS);

		ERPG_Network_server_add_string((TCPsocket)node->value,input);
	}
	return 0;
}
int Lua_ERPG_Network_server_add_broad_string(lua_State * L)
{
	char * luaS = (char*)luaL_checkstring(L,1);
	char * input = (char*)malloc(packetSize);
	strcpy(input, luaS);

	char * luaS2 = (char*)luaL_checkstring(L,2);
	char * input2 = (char*)malloc(strlen(luaS) + 1);
	strcpy(input2, luaS2);


	ERPG_Network_server_add_broad_string(input2, input);

	return 0;
}

int Lua_ERPG_Network_server_unload_client(lua_State * L)
{
	ERPG_Network_server_unload_client((char*)luaL_checkstring(L,1));
	return 0;
}

int Lua_ERPG_Network_close_connection_server(lua_State * L)
{
	ERPG_Network_close_connection_server();
	return 0;
}

int luaopen_ERPG_Network_server(lua_State * L)
{  
  static const luaL_Reg method[] = {
    {"create", Lua_ERPG_Network_create_server},
    {"accept_socket", Lua_ERPG_Network_accept_socket},
    {"network_close_connection", Lua_ERPG_Network_close_connection_server},
    {"unload_client", Lua_ERPG_Network_server_unload_client},
    {"add_string", Lua_ERPG_Network_server_add_string},
    {"add_broad_string", Lua_ERPG_Network_server_add_broad_string},
    {"get_data", Lua_ERPG_Network_server_get_data},
    {NULL, NULL}
  };

  luaL_newlib(L, method);
  
  return 1;
}