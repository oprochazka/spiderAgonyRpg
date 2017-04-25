local Console = {}

function Console.make()
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()
   local width = screen_w
   local height = 200
   local x = 0
   local y = game_machine.canvas.canvas_frame.bound_box.h
   local geom = ERPG_geometry.make_rectangle({0,0,screen_w,height*3}, {40,40,40,255}, 1)
   local texture = ERPG_sprite.compose_textures({geom}, width, height*3)
   local elem = GUI.make_element_with_sprite(texture)
   local input_txt = GUI.make_input_box(screen_w)

   local frame
   
   local texts = {}
   local last
   local layout = GUI.make_layout({elem}, {0,0,width,height}, 5)
   
   frame = GUI.make_frame({0,0,0,0},layout,nil,{45,30,30,255})

   input_txt:move(5,height-10)

   local iter = 0

   input_txt:set_color({0,0,0,255})

   function frame:add_text(text)
      local text = text or " "
      local txt = GUI.make_static_text(text, screen_w)
      local w,h = txt.bound_box.w,txt.bound_box.h

      
      local w1,h1 = elem.sprite:get_max_size()
      local rect = elem.sprite:get_current_size()

      local x,y = elem.sprite:get_position()
      elem.sprite:set_position(0,h)
      elem.sprite:set_size(0,0,w1,h1)

      local tmp = ERPG_sprite.compose_textures({elem.sprite,txt.sprite},width, height * 3)
      
      elem.sprite:unload_texture()
      tmp:move(x,y)
      tmp:set_size(rect.x,rect.y,rect.w,rect.h)

      elem.sprite = tmp
   end

   local function on_press_key(self, press_key)
      if press_key[1] == "Return" then
	 frame:add_text(input_txt:get_text())

	 local func = loadstring(input_txt:get_text())
	 print(func())

	 texts[#texts + 1] = input_txt:get_text()
	 input_txt:set_empty()
	 last = nil
      elseif press_key[1] == "Tab" then
	 local tmp = last or input_txt:get_text()
	 for k=(iter%#texts)+1,#texts do
	    iter = iter + 1
	    local current = texts[(k%#texts)+1]
	    if string.find(current,tmp .. ".*") then
	       last = tmp
	       input_txt:set_text(current)
	       break
	    end
	 end     	 
      else
	 if last then
	    if press_key[1] == "Space" then	    
	       input_txt:set_text(last)
	    end
	 end
	 last = nil
      end
   end   

   frame:unbind_panel()
   
   GUI.compose_object(frame, input_txt)

   frame:move(0,screen_h+5)

   local function on_input_key(self, key)
      GUI.send_event(input_txt, "on_input_key",key)
   end
   local function on_motion(self,motion)
      frame:move(motion.x,motion.y)
   end
   
   GUI.add_event(frame, "on_click", function (self, mouse) 
		    GUI.send_event(self.parrent,"on_activate", input_txt)
				    end)
   GUI.add_event(elem, "on_click", function (self, mouse) 
		    GUI.send_event(self.parrent.parrent,"on_activate", input_txt)
				    end)
   local function on_activate(self, who)
      GUI.send_event(self.parrent, "on_activate", who)
   end

   GUI.add_event(frame, "on_release_key", on_press_key)
   GUI.add_event(frame, "on_input_key", on_input_key)
   GUI.add_event(frame, "on_motion", on_motion)
   GUI.add_event(frame, "on_activate", on_activate)
   return frame
end

return Console