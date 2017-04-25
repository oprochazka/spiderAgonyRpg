#ifndef MOUSE_H
#define MOUSE_H
typedef struct ERPG_Wheel{
  char wheel_x;
  char wheel_y;
  int time;
}ERPG_Wheel;
typedef struct ERPG_Button{
  char * press_button;
  int first_time;
  int time;
  char * release;
  char * motion_button;
  char * on_press;
}ERPG_Button;

typedef struct ERPG_Mouse{
  int x;
  int y;
  ERPG_Button * button;
  ERPG_Wheel * wheel;
}ERPG_Mouse;

ERPG_Mouse * ERPG_Create_mouse();
void ERPG_pump_mouse(SDL_Event * events, ERPG_Mouse * mouse);
void ERPG_Destroy_mouse(ERPG_Mouse * mouse);

#endif
