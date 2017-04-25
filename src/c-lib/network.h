#ifndef NETWORK_H
#define NETWORK_H
#include<SDL2/SDL_net.h>
#include<SDL2/SDL_mutex.h>
#include"list.h"

typedef struct ERPG_TextBuffer{
	char * buffer;
	int pointer;
	char isEmpty;
}ERPG_TextBuffer;

typedef struct ERPG_Network{
	IPaddress ipaddress;
	TCPsocket serverSock;
	int port;
	CList * data;
	CList * inputData;
	SDL_Thread * thread;
	SDL_mutex * dataMutex;
	SDL_mutex * inputDataMutex;
	SDLNet_SocketSet socketSet;
	int exit;
	ERPG_TextBuffer * buffer;
}ERPG_Network;

ERPG_TextBuffer * init_buffer(int size);

ERPG_Network* ERPG_Network_create();

int ERPG_Network_connect(char * serverIp, int port);

int ERPG_Network_send_string(char * string);
char * ERPG_Network_recieve_string(int maxLen);
void ERPG_Network_close_connection();

int luaopen_ERPG_Network(lua_State * L);
void ERPG_Network_add_string(char * string);
char * ERPG_Network_get_data();

void ERPG_Network_destroy();
#endif
