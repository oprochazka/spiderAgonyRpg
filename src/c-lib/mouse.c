#include<stdio.h>
#include<stdlib.h>
#include<lua5.2/lua.h>
#include<lua5.2/lauxlib.h>
#include<lua5.2/lualib.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_image.h>
#include<SDL2/SDL2_gfxPrimitives.h>
#include<SDL2/SDL_mixer.h>
#include"main.h"
#include"basic_shapes.h"
#include"lua_func.h"
#include"list.h"

void release_button(SDL_Event * events, ERPG_Mouse * mouse);
void press_button(SDL_Event * events, ERPG_Mouse * mouse);
void check_wheel(SDL_Event * events, ERPG_Mouse * mouse);
  
ERPG_Mouse * ERPG_Create_mouse()
{
  ERPG_Mouse * mouse = (ERPG_Mouse*) malloc(sizeof(ERPG_Mouse));

  mouse->button = (ERPG_Button*)malloc(sizeof(ERPG_Button));
  mouse->button->press_button = "none";
  mouse->button->motion_button = "none";
  mouse->button->release = "none";
  mouse->button->on_press = "none";
  mouse->wheel = (ERPG_Wheel*)malloc(sizeof(ERPG_Wheel));
  mouse->wheel->time = 0;
  mouse->wheel->wheel_y = 0;
  mouse->wheel->wheel_x = 0;
  mouse->button->first_time = 0;
  mouse->x = 0;
  mouse->y = 0;
  
  return mouse;
}

void ERPG_pump_mouse(SDL_Event * event, ERPG_Mouse * mouse)
{
  int x,y;

  if(SDL_MOUSEMOTION == event->type){
     SDL_GetMouseState( &x, &y );  
     mouse->x = x;
     mouse->y = y;
  }

  release_button(event, mouse);
  press_button(event, mouse);
  check_wheel(event, mouse);

}

void release_button(SDL_Event * events, ERPG_Mouse * mouse)
{
  if(events->type == SDL_MOUSEBUTTONUP && mouse->button->first_time != events->button.timestamp){
    mouse->button->release = mouse->button->press_button;
    mouse->button->press_button = "none";
    mouse->button->motion_button = "none";
    mouse->button->first_time = events->button.timestamp;
  }
}

void press_button(SDL_Event * events, ERPG_Mouse * mouse)
{
  if( events->type == SDL_MOUSEBUTTONDOWN &&
      events->button.button ==  SDL_BUTTON_RIGHT){
    mouse->button->press_button = "right";
    mouse->button->on_press = "right";
  }
  else if( events->type == SDL_MOUSEBUTTONDOWN &&
	   events->button.button ==  SDL_BUTTON_LEFT){
    mouse->button->press_button = "left";
    mouse->button->on_press = "left";
  }
  else if( events->type == SDL_MOUSEBUTTONDOWN &&
	   events->button.button ==  SDL_BUTTON_MIDDLE){
    mouse->button->press_button = "middle";
    mouse->button->on_press = "middle";
  }


  if( events->type == SDL_MOUSEMOTION &&
      events->motion.state ==  SDL_BUTTON_RMASK){
    mouse->button->motion_button = "right";
  }
  else if( events->type == SDL_MOUSEMOTION &&
	   events->motion.state ==  SDL_BUTTON_LMASK){
    mouse->button->motion_button = "left";

  }
  else if( events->type == SDL_MOUSEMOTION &&
	   events->motion.state ==  SDL_BUTTON_MMASK){
    mouse->button->motion_button = "middle";
  }
   
}

void check_wheel(SDL_Event * events, ERPG_Mouse * mouse)
{
  if(events->type == SDL_MOUSEWHEEL && mouse->wheel->time != events->wheel.timestamp){
    mouse->wheel->wheel_y = events->wheel.y;
    mouse->wheel->wheel_x = events->wheel.x;
    mouse->wheel->time = events->wheel.timestamp;
  }else{
   
  }
}

void ERPG_Destroy_mouse(ERPG_Mouse * mouse)
{
  free(mouse->button);
  free(mouse->wheel);
}
