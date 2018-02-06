#ifndef KEYBOARD_H
#define KEYBOARD_H

typedef struct ERPG_Keyboard{
  CList * press_key;
  CList * release_key;
}ERPG_Keyboard;

ERPG_Keyboard * ERPG_Create_keyboard();
void ERPG_Pump_keyboard(SDL_Event * events, ERPG_Keyboard * keyboard);
void ERPG_Destroy_keyboard(ERPG_Keyboard * keyboard);
#endif
