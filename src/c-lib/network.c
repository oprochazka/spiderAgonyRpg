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
#include"main.h"
#include"basic_shapes.h"
#include"mouse.h"
#include"keyboard.h"
#include"core.h"
#include"audio.h"
#include"list.h"
#include<time.h>

static int iterator = 0;
static int iterator2 = 0;
const static int packetSize = 500;


ERPG_Network * ERPG_Network_create()
{
	ERPG_Network * out = (ERPG_Network*)malloc(sizeof(ERPG_Network));
	ERPG_CORE * core = ERPG_get_CORE();
	out->serverSock = NULL;

  	core->network = out;

	if(SDL_Init(0)==-1) {
	    printf("SDL_Init: %s\n", SDL_GetError());
	    exit(1);
	}
	if(SDLNet_Init()==-1) {
	    printf("SDLNet_Init: %s\n", SDLNet_GetError());
	    exit(2);
	}

	return out;
}


static int clientLoop(void *ptr)
{
  ERPG_CORE * core = ERPG_get_CORE();
  ERPG_Network * net = ERPG_get_Network();
  while(!net->exit)
  {
    if(core->network)
    {
  		ERPG_Network_send_string("");

      	ERPG_Network_recieve_string(packetSize);
     // 	SDL_Delay(20);
     // 	printf("here is it %d : %d \n", iterator, iterator2);
    }
    SDL_Delay(0);
  }
  return 1;
}

ERPG_TextBuffer * init_buffer(int size)
{
	ERPG_TextBuffer * buffer = (ERPG_TextBuffer*)malloc(sizeof(ERPG_TextBuffer));
	buffer->buffer = (char*)calloc(1, size);
	buffer->pointer = 0;
	buffer->isEmpty = 1;
	return buffer;
}

int ERPG_Network_connect(char * serverIp, int port)
{
	
	ERPG_Network * net = ERPG_get_Network();
	if(net == NULL)
	{
		net = ERPG_Network_create();
	}
	net->exit = 1;
	IPaddress ip;
	TCPsocket tcpsock;

	if(SDLNet_ResolveHost(&ip,serverIp,port)==-1) {
	    printf("SDLNet_ResolveHost: %s\n", SDLNet_GetError());
	    net->exit = 1;
	    return 0;
	}

	tcpsock=SDLNet_TCP_Open(&ip);
	if(!tcpsock) {
		net->exit = 1;
	    printf("SDLNet_TCP_Open: %s\n", SDLNet_GetError());
	  	return 0;
	}

	net->data=create_clist();
 	net->inputData = create_clist();
	net->exit = 0;
	net->dataMutex = SDL_CreateMutex();
 	net->inputDataMutex = SDL_CreateMutex();
 	net->socketSet = SDLNet_AllocSocketSet(1);
 	
 	net->buffer = init_buffer(2048);

	SDLNet_TCP_AddSocket(net->socketSet,tcpsock);
	
	net->serverSock = tcpsock;
	
	net->ipaddress = ip;
	net->port = port;
	
	net->thread = SDL_CreateThread(clientLoop, "clientLoop", (void *)NULL);
	return 1;
}

void ERPG_Network_add_string(char * string)
{
	ERPG_Network * net = ERPG_get_Network();
	if(SDL_LockMutex(net->inputDataMutex) == 0)
	{
		add_cnode(net->inputData, string);
		SDL_UnlockMutex(net->inputDataMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}
}

char * ERPG_Network_get_data()
{
	ERPG_Network * net = ERPG_get_Network();
	char* v = (char*) get_cnode(net->data, 0);

	if(v)
	{
		char * str = (char*)malloc(sizeof(char)* strlen(v)+1);
		strcpy(str, (char*)v);
		
		if(SDL_LockMutex(net->dataMutex) == 0)
		{	
			remove_cnode(net->data,0);
			iterator2++;
			SDL_UnlockMutex(net->dataMutex);
		}else
		{
			fprintf(stderr, "Couldn't lock mutex\n");
		}
		return str;
	}

	return NULL;
}

int ERPG_Network_send_string(char * string)
{
	ERPG_Network * net = ERPG_get_Network();
	if(!net->serverSock || !net->inputData )
	{
		return 0;
	}
	if(!net->inputData->root)
	{		
		return 1;
	}

	char * value = (char*)get_cnode(net->inputData,0);
	int len = strlen((char*)value) + 1;			
	
	int result=SDLNet_TCP_Send(net->serverSock, (char*)value,len);

	if(SDL_LockMutex(net->inputDataMutex) == 0)
	{
		remove_cnode(net->inputData,0);
		SDL_UnlockMutex(net->inputDataMutex);
	}else
	{
		fprintf(stderr, "Couldn't lock mutex\n");
	}

	if(result < len ) {
	    printf("SDLNet_TCP_Send: %s\n", SDLNet_GetError());
	    return 0;		
	}
	return 1;
}

void copyBuffer(char * msg, ERPG_TextBuffer * txtBuffer, int maxLen)
{
	ERPG_Network * net = ERPG_get_Network();

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
	//		printf("%d stringeck %s \n", strlen(tmp) + 1, tmp);
			if(SDL_LockMutex(net->dataMutex) == 0)
			{						
				add_cnode(net->data, tmp);
				SDL_UnlockMutex(net->dataMutex);
			}else
			{
				fprintf(stderr, "Couldn't lock mutex\n");
			}
			txtBuffer->pointer = 0;
			txtBuffer->isEmpty = 1;
		}				
	}
}

char * ERPG_Network_recieve_string(int maxLen)
{	
	ERPG_Network * net = ERPG_get_Network();
	
	int result = 1;

	if(net->serverSock)		
	{
		int numready;

		numready=SDLNet_CheckSockets(net->socketSet, 0);
		if(numready==-1) {
			printf("SDLNet_CheckSockets: %s\n", SDLNet_GetError());
			perror("SDLNet_CheckSockets");
		}
		else if(numready) {
			if(SDLNet_SocketReady(net->serverSock)) {   	
				char * msg = (char*)malloc(sizeof(char)*maxLen);
				memset(msg,'$',sizeof(char)*maxLen);
				ERPG_TextBuffer * txtBuffer = net->buffer;

				result = SDLNet_TCP_Recv(net->serverSock, msg, maxLen);
				copyBuffer(msg, txtBuffer, maxLen);

				free(msg);			

				iterator++;
			
				return msg;
			}

			if(result<=0) {

			}
		}
	}
	
	return NULL;
}
void ERPG_Network_close_connection()
{
	ERPG_Network * net = ERPG_get_Network();
	if(net && net->exit == 0)
	{
		int threadReturnValue;
		net->exit = 1;

		SDL_WaitThread(net->thread, &threadReturnValue);

		TCPsocket socket = net->serverSock;

		net->serverSock = NULL;
		SDLNet_TCP_Close(socket);
		net->socketSet=NULL;	

		remove_clist(net->data);
		remove_clist(net->inputData);

		free(net->buffer->buffer);
		free(net->buffer);

		net->thread = NULL;
		SDLNet_FreeSocketSet(net->socketSet);
		net->socketSet = NULL;
		SDL_DestroyMutex(net->dataMutex);
		SDL_DestroyMutex(net->inputDataMutex);

		net->dataMutex = NULL;
		net->inputDataMutex = NULL;
	}
}

void ERPG_Network_destroy()
{
	ERPG_Network * net = ERPG_get_Network();
	if(!net){
		return;
	}
	if(net->exit == 0)
	{
		ERPG_Network_close_connection();
	}


//	net->exit = 1;
	
	free(net);
}

int Lua_ERPG_Network_get_data(lua_State * L)
{
	char * str = ERPG_Network_get_data();

	if(str)
	{
		lua_pushlstring(L, str, strlen(str));
		free(str);
	}else
	{
		lua_pushnil(L);
	}
	return 1;
}

int Lua_ERPG_Network_add_string(lua_State * L)
{
	char * luaS = (char*)luaL_checkstring(L,1);
	char * input = (char*)malloc(strlen(luaS) + 1);
	strcpy(input, luaS);
	ERPG_Network_add_string(input);
	return 0;
}

int Lua_ERPG_Network_connect(lua_State * L)
{
	int r = ERPG_Network_connect((char*)luaL_checkstring(L,1),luaL_checkinteger(L,2));

	if(!r)
	{
		lua_pushnil(L);
		return 1;
	}

	lua_pushnumber(L,r);

	return 1;
}	

int Lua_ERPG_Network_send_string(lua_State * L)
{
	char * str = (char*)luaL_checkstring(L,1);
	char * input = (char*)malloc(strlen(str) + 1);
	strcpy(input, str);

	lua_pushnumber(L,ERPG_Network_send_string(input));
	return 0;
}

int Lua_ERPG_Network_recieve_string(lua_State * L)
{
	char * str = ERPG_Network_recieve_string(luaL_checkinteger(L,1));
	if(strlen(str) <= 0 )
	{
		lua_pushnil(L);
	}else
	{
		lua_pushlstring(L, str, strlen(str));
	}
	free(str);

	return 1;
}

int Lua_ERPG_Network_close_connection(lua_State * L)
{
	ERPG_Network_close_connection();
	return 0;
}

int luaopen_ERPG_Network(lua_State * L)
{  
  static const luaL_Reg method[] = {
    {"network_connect",Lua_ERPG_Network_connect},
    {"network_send_string", Lua_ERPG_Network_send_string},
    {"network_recieve_string", Lua_ERPG_Network_recieve_string},
    {"network_close_connection", Lua_ERPG_Network_close_connection},
    {"add_data", Lua_ERPG_Network_add_string},
    {"get_data", Lua_ERPG_Network_get_data},
    {NULL, NULL}
  };

  luaL_newlib(L, method);
  
  return 1;
}