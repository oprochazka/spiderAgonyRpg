#ifndef SERVER_NETWORK_H
#define SERVER_NETWORK_H
#include<SDL2/SDL_net.h>
#include<SDL2/SDL_mutex.h>
#include"list.h"



typedef struct ERPG_Network_server{
	IPaddress ipaddress;
	TCPsocket tcpsock;
	List * clientSocks;
	TCPsocket clientSock;
	int port;
	int idCounter;
	int exit;
	SDLNet_SocketSet socketSet;
	SDL_Thread * thread;
	SDL_mutex * dataMutex;
	SDL_mutex * inputDataMutex;
	SDL_mutex * inputDataBroadMutex;
	SDL_mutex * clientSockMutex;
	CList * data;
	CList * inputData;
	CList * inputDataBroad;
}ERPG_Network_server;

typedef struct ERPG_ClientSock{
	ERPG_TextBuffer * buffer;
	TCPsocket socket;
}ERPG_ClientSock;

typedef struct ERPG_Packet{
	TCPsocket dest;
	char * data;
}ERPG_Packet;

typedef struct ERPG_PacketS{
	char * dest;
	char * data;
}ERPG_PacketS;

void ERPG_Network_create_server(int port);
int ERPG_Network_connect(char * serverIp, int port);
char * ERPG_Network_accept_socket();
void ERPG_DestroySocket(ERPG_ClientSock * socket);

int ERPG_Network_send_string_server();
List * ERPG_Network_recieve_string_server(int maxLen);
void ERPG_Network_close_server();
int luaopen_ERPG_Network_server(lua_State * L);
void ERPG_Network_send_string_server_broadcast();
void ERPG_Network_close_connection_server();

void ERPG_Network_server_destroy();
#endif
