#ifndef LUA_FUNC_H
#define LUA_FUNC_H

SDL_Rect * Lua_from_create_rect(lua_State * L, int index);
Sint16* Lua_get_sint16_from_table(lua_State * L,int index, int size_table);
SDL_Color *Lua_get_color(lua_State * L,int index);
int setfield (lua_State *L, const char *index, int value);
int rect_to_table(lua_State * L, SDL_Rect * rect);
#endif

