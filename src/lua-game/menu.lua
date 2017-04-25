dofile(PATH_CONFIGS .. "options_config.lua")
Editor = require(PATH_EDITOR .. "editor")
NGD = require(PATH_GAME .. "new_game_dialog")
--Editor = require "editor"

function make_button_frame(x,y, button_w, button_h, color_button, color_text,text_size, 
			   y_margin,list_button)
   local h = 0
   local w = 0
   local button_frame ={}
   local button
   local objects = {}
   local first = nil
   button_frame = GUI.make_empty_frame(create_rect(x,y- button_h - y_margin,button_w,
						   h+ (button_h + y_margin)))
  -- h = button_h + y_margin
   for k,tab in ipairs(list_button) do
      local text = tab[1]
      local func = tab[2]
      button = GUI.make_text_button(create_rect(x,y+h,button_w,button_h), text_size, text, 
				color_button, color_text, 10, 10)
      
  --    button = GUI.make_button(PATH_GUI_IMG .. "menu_button.png", x, y+h)
  --    local txt = GUI.make_element_text(x+10, y+h+10, text_size, text, {10,0,0,255}, PATH_FONTS .. 
--					   "Ubuntu-B.ttf")

      h = h + y_margin + button_h
      
      --objects[#objects+1] = button
      GUI.add_event(button,"on_click", function (self,mouse)
		   if mouse.release == "left" then
		      func(self,mouse)
		   end;end)
    --  GUI.compose_object(button, txt)
      GUI.compose_object(button_frame, button)
   end   

   function button_frame:add_first(name,func)
      local x,y = self.bound_box.x, self.bound_box.y
      button = GUI.make_text_button(create_rect(x,y , button_w, button_h), 
				    text_size, name,
				    color_button, color_text, 10, 10)
  --    button = GUI.make_button(PATH_GUI_IMG .. "menu_button.png", x, y)
   --   local txt = GUI.make_element_text(x+10, y+10, text_size, name, {10,0,0,255}, PATH_FONTS .. 
--					   "Ubuntu-B.ttf")

      GUI.add_event(button,"on_click", function (self,mouse)

		   if mouse.release == "left" then
		      func(self,mouse)
		   end;end)
  --    GUI.compose_object(button, txt)
      GUI.compose_object(button_frame, button)
      first = true
   end
   function button_frame:remove_first(name, func)
      if first then
	 button_frame.objects[#button_frame.objects] = nil
	 first = nil
      end
   end


   button_frame.bound_box["h"] = h + button_h + y_margin

   GUI.add_event(button_frame, "on_iter", on_iter)

   return button_frame
end

function make_window_options()
   local x,y = GUI.SCREEN.width/2-150, GUI.SCREEN.height/2-150
   local frame 
   
   local canvas = _OPTIONS.canvas
   local is_music = _OPTIONS.music
   local is_sound = _OPTIONS.sound
   local is_fullscreen = _OPTIONS.fullscreen

   local function music_off(main_window)      
      _OPTIONS.music = nil
      ERPG_Audio.music_stop()      
   end
   local function music_on(main_window)
      if _OPTIONS.music == nil then
	 _OPTIONS.music = true
	 ERPG_Audio.play_music(-1)
      end
   end
   local function sound_off(main_window)
      _OPTIONS.sound = false
   end
   local function sound_on(main_window)
      _OPTIONS.sound = true
   end
   local function on_click_cancle(self,mouse)
      GUI.send_event(self.parrent, "on_destroy",self)
   end
   local function toggle_fullscreen()
      if _OPTIONS.fullscreen == nil then
	 _OPTIONS.fullscreen = true
	 GUI.main_window.window:toggle_fullscreen()
      end
   end
   local function toggle_fullscreen2()
      if _OPTIONS.fullscreen then
	 _OPTIONS.fullscreen = nil
	 GUI.main_window.window:toggle_fullscreen()
      end
   end

   local function on_apply(self)
      for k, obj in ipairs(frame.layout.objects) do	 
	 if obj.func then
	    obj.func(main_window)
	 end
      end
      GUI.send_event(frame, "on_destroy")
   end

   local combo_box = make_combo_box(200, 
				    {{"default", function () 
					 GUI.main_window.window:
					 set_resolution(GUI.SCREEN.width,GUI.SCREEN.height)
						 end },
				     {"1024x768", function () 
					 GUI.main_window.window:set_resolution(1024,768) 
					 GUI.main_window.window:toggle_fullscreen_cut()
						  end },
				     {"800x600", function ()
					 GUI.main_window.window:set_resolution(800,600) end },
				     {"600x480", function ()
					 GUI.main_window.window:set_resolution(600,480) end }
				    })

   local sound_check =  GUI.make_check_box("Zvuky",is_sound, sound_on,
					sound_off)

   local music_check =  GUI.make_check_box("Hudba",is_music, music_on,music_off)

   local toggle_fullscreen =  GUI.make_check_box("Celá obrazovka",is_fullscreen, 
					toggle_fullscreen,
					toggle_fullscreen2)

   local layout_buttons = GUI.make_layout_buttons({{"APPLY", on_apply},
						   {"CANCLE", on_click_cancle}})

   local button_sprite = GUI.make_button(PATH_GUI_IMG .. "cross.png")
   local layout = GUI.make_layout({music_check,sound_check,toggle_fullscreen}, {0,0,300,200})

   frame = GUI.make_frame({x,y, 0,200},layout , layout_buttons,color)
  
   GUI.add_event(frame,"on_apply", on_apply)
   return frame
end

local function on_win_game()
   GUI.compose_object(GUI.main_window.objects[1], GUI.make_message_box("Zvítězil jsi!!!"))
end

function make_menu_bar()
   local window_machine = get_window_machine()

   local main_frame
   local the_game = nil
   local last_object = nil
   local pent
   local frame_canvas = GUI.make_empty_frame(create_rect(0, 0, GUI.SCREEN.width, GUI.SCREEN.height))
   frame_canvas["main_frame"] = true

   GUI.add_event(frame_canvas,"on_destroy", GUI.on_destroy_object_gui)
   local function on_click_quit(self,mouse)
      GUI.send_event(GUI.main_window, "on_exit")
   end
   local function absolute_start_game(func, frame, args, type)
      GUI.main_window["objects"] = {}
      frame_canvas.objects = {}
      local function on_press_key (self,release)
      	 for k, v in ipairs(self.objects) do
      	    GUI.send_event(v,"on_release_key", release)
      	 end
      end
      
      local function on_resume(self)
      	 local gm = get_game_machine()
      	 gm:stop_time()
      	 GUI.main_window["objects"] = {}
      	 ERPG_Audio.stop_all_sound()
      	 GUI.compose_object(GUI.main_window, pent)
      	 GUI.compose_object(GUI.main_window, main_frame)
      end     


      main_frame:add_first("Návrat do hry", function ()  
			      GUI.main_window["objects"] = {}
			      local gm = get_game_machine()
			      gm:start_time()
			      GUI.compose_object(GUI.main_window, frame_canvas) end)

      the_game = GameStarter.start(frame, args, func, type)



      GUI.add_event(frame_canvas, "on_release_key", on_press_key)
      GUI.add_event(frame_canvas, "on_resume", on_resume)
      GUI.add_event(frame_canvas, "on_iter", the_game)
      GUI.add_event(frame_canvas, "on_win_game", on_win_game)
      GUI.compose_object(GUI.main_window, frame_canvas)    
   end

   local function on_start_game(self,args)   
      absolute_start_game(GameStarter.loading_game, frame_canvas, args)
   end

   local function on_start_editor(self)   
  
      GUI.main_window["objects"] = {}

      local function on_resume (self)
   	 GUI.main_window["objects"] = {}
   	 ERPG_Audio.stop_all_sound()
   	 
   	 GUI.compose_object(GUI.main_window, pent)
   	 GUI.compose_object(GUI.main_window, main_frame)
      end
      main_frame:remove_first()

      local frame_canvas_editor =
	      GUI.make_empty_frame(create_rect(0, 0, GUI.SCREEN.width, GUI.SCREEN.height))

      frame_canvas_editor["main_frame"] = true
      GUI.add_event(frame_canvas_editor,"on_destroy", GUI.on_destroy_object_gui)
     
      the_game = Editor.start(frame_canvas_editor)
      

      GUI.add_event(frame_canvas_editor, "on_resume", on_resume)
      GUI.add_event(frame_canvas_editor, "on_iter", the_game)
      GUI.compose_object(GUI.main_window, frame_canvas_editor)                  
   end
   


   local function on_click_start(self, mouse)    
      local function apply(stats, inventory_items)
	     GUI.send_event(self,"on_start_game",{["stats"] = stats, ["items"] = inventory_items})
      end
      GUI.add_event(self, "on_start_game", on_start_game)
      local msg = NGD.make(apply)
      msg:move(GUI.SCREEN.width/2 - msg.bound_box.w/2, GUI.SCREEN.height/2 - msg.bound_box.h/2)
      GUI.compose_object(GUI.main_window, msg)
   end

   local function on_click_editor(self, mouse)    
      local function apply()
	 GUI.send_event(self,"on_start_editor")
      end

      local msg = GUI.make_message_box("Opravdu chcete spustit editor návrat zpět do hry nebude možný?",apply)

      GUI.add_event(self, "on_start_editor", on_start_editor)
      GUI.compose_object(GUI.main_window, msg)
   end

   local function on_click_options(self, mouse)    
      local options = window_machine:get_options()
      GUI.compose_object(GUI.main_window, options)
   end     
   
   local function on_click_load(self, mouse)
      local browse = GUI.make_file_browser(PATH_SAVE, function (args)
					      if args ~= nil then
						 frame_canvas.objects = {}
						 absolute_start_game(GameStarter.in_loading_game,frame_canvas,args)
					      end
						      end)
      browse:move(GUI.SCREEN.width / 2 - browse.bound_box.w/2,
		  GUI.SCREEN.height / 2 - browse.bound_box.h/2)
      GUI.compose_object(GUI.main_window,browse)  
   end
   local function on_click_controlls(self, mouse)
      local f = assert(io.open(PATH_TEXT .. "controlls2", "r")) 
      local t= f:read("*all")	 
      f:close()    
      local frame
      local but = GUI.make_static_text(t,700)

      local function on_cl_d(self)
	 GUI.send_event(frame,"on_destroy")
      end
      local lay = GUI.make_layout({but},{0,0,0,300})
      frame = GUI.make_frame({0,0,0,0},lay, make_layout_buttons({{"CANCLE", on_cl_d}}),
			     {10,10,20,255})
      frame:move(0,20)

      GUI.compose_object(GUI.main_window,frame)
   end
   local function on_click_input_box(self,mouse)
      GUI.compose_object(GUI.main_window, GUI.make_input_box(200, "input"))
   end
   local function on_start_server(self, args)
      absolute_start_game(GameStarter.startServer, frame_canvas, args, "server")
   end
   local function on_click_start_server(self)

      local function apply(stats, inventory_items)
        GUI.send_event(self,"on_start_game",{["stats"] = stats, ["items"] = inventory_items})
      end
      GUI.add_event(self, "on_start_game", on_start_server)
      local msg = NGD.make(apply)
      msg:move(GUI.SCREEN.width/2 - msg.bound_box.w/2, GUI.SCREEN.height/2 - msg.bound_box.h/2)
      GUI.compose_object(GUI.main_window, msg)

   end

   local function on_start_client(self, args)

      absolute_start_game(GameStarter.connectServer, frame_canvas, args, "client")
   end
   local function on_click_start_client(self)

      local function apply(stats, inventory_items)
        GUI.send_event(self,"on_start_game",{["stats"] = stats, ["items"] = inventory_items})
      end
      GUI.add_event(self, "on_start_game", on_start_client)
      local msg = NGD.make(apply)
      msg:move(GUI.SCREEN.width/2 - msg.bound_box.w/2, GUI.SCREEN.height/2 - msg.bound_box.h/2)
      GUI.compose_object(GUI.main_window, msg)

   end
 
 


   main_frame = make_button_frame(GUI.SCREEN.width / 2 - 100,GUI.SCREEN.height/2 -200, 
				  200,50,GUI._BUTTON.button_color, GUI._BUTTON.text_color,
				  20, 10, {
				     {"Nová Hra",on_click_start},                  
				     {"Načíst hru", on_click_load},
			--	     {"Uložit hru", on_click_save},
                  {"Start server",on_click_start_server}, 				     
                  {"Connect to server",on_click_start_client}, 
				     {"Spustit editor", on_click_editor},
				     {"Ovládání hry", on_click_controlls},
				     {"Nastavení",on_click_options},						     
				     {"Konec",on_click_quit}}
   )
   main_frame["dock"] = true

--  main_frame.sprite = ERPG_sprite.make(PATH_SPRITES .. "/background.png")
--   local my_sprite = ERPG_sprite.make(PATH_SPRITES .. "/torch.png")
   pent = GUI.make_sprite(PATH_SPRITES .. "cave2.png")
   local w,h = pent.sprite:get_max_size()
   pent:move(GUI.SCREEN.width/2 - w/2, 90)
--   my_sprite:set_clips(4,1)
--   main_frame.sprite = my_sprite
   local i = 0
   local function on_my_iter(self)
   --   pent:copy_to_renderer()
      i = i + 1
   end
   
   pent["dock"] = true
   GUI.compose_object(GUI.main_window,pent)
   GUI.add_event(main_frame,"on_iter", on_my_iter)

--   main_frame.sprite:move(380,300)

   local cursor = ERPG_sprite.make(PATH_SPRITES .. "cursor3.png")
   cursor:set_clips(8,1)
   cursor:set_clip(1,0)

   GUI.set_cursor(cursor)

   
   return main_frame

end


