LIBPNG_DIR=/usr/local
LIBPNG_LIBDIR=$(LIBPNG_DIR)/lib
LIBPNG_INCDIR=$(LIBPNG_DIR)/include
LUA_DIR=/usr/local
LUA_LIBDIR=$(LUA_DIR)/lib/lua/5.2
CFLAGS=-Wall -std=c99 -shared -g -O0
CLIBS=-lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer -llua5.2 -lpng -lSDL2_gfx -lm -lSDL2_net
OUT_DIR=./../game/
OUT=engine
OBJS=*.o
CC=gcc
# ... Pro aktualizaci knihovny nejdříve make lib a potom make install
makebin:
	$(CC) $(CFLAGS) -c *.c 
	rm ./../c-game/libcerpg_engine.a
	ar -cvq ./../c-game/libcerpg_engine.a *.o 	
lib:
	$(CC) -o main.so *.c $(CFLAGS) $(CLIBS) -L$(LIBPNG_LIBDIR) -I$(LIBPNG_INCDIR)
install:
	mkdir -p $(LUA_LIBDIR)
	cp main.so $(LUA_LIBDIR)

	