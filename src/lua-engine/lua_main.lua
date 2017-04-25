module(..., package.seeall)


if PATH_LIB==nil then PATH_LIB="./" end
PATH = "./../../bin/"
dofile(PATH_LIB .. "header.lua")
dofile(PATH_LIB .. "frame.lua")
dofile(PATH_LIB .. "callbacks.lua")
dofile(PATH_LIB .. "function.lua")
dofile(PATH_LIB .. "gui_advanced.lua")
dofile(PATH_LIB .. "static_text.lua")
dofile(PATH_LIB .. "gui_extended.lua")

SCREEN = nil
--debug=true
function profiler(func, arg)
      local calls, total, this = {}, {}, {}
      debug.sethook(function(event)
		       local i = debug.getinfo(2, "Sln")
		       if i.what ~= 'Lua' then return end
		       local func = i.name or (i.source..':'..i.linedefined)
		       if event == 'call' then
			  this[func] = os.clock()
		       else
			  local time = os.clock() - this[func]
			  total[func] = (total[func] or 0) + time
			  calls[func] = (calls[func] or 0) + 1
		       end
		    end, "cr")

      func(arg)

      debug.sethook()
      
      -- print the results
      for f,time in pairs(total) do
	 print(("Function %s took %.3f seconds after %d calls"):format(f, time, calls[f]))
      end
end

function on_destroy_object_gui(self, object)
   for i=1, #self.objects do
      if object == self.objects[i] then table.remove(self.objects, i);end
   end
end

function start_engine()
   local window = ERPG_window
   local exit = nil
   local this_time
   window:toggle_fullscreen_cut()
   SCREEN = window:get_desktop_resolution()

   local function on_iter(self, main_window)
      if self.objects then
	 for key,value in pairs(self.objects) do
	    if value.callbacks.on_iter then 
	       value.callbacks.on_iter(value, main_window)	       
	    end
	    on_iter(value, main_window)
	 end
      end
   end
   
   local function on_destroy(self, object)
      for i=1, #self.objects do
	 if object == self.objects[i] then table.remove(self.objects, i);end
      end
   end

   local function on_render(object)
      local max = 0
      local object_max
      local function rendering( object,hold)
	 if object.objects then
	    for k,v in ipairs(object.objects) do	 
	       if hold or main_window.last_render_object ~= v then
		  if v.sprite then	 
		     if v.render_off == nil then  			
			local tmp = ERPG_Utils.get_time()
			
			v["sprite"]:copy_to_renderer()	
			
			if ERPG_Utils.get_time() - tmp > max then
			   max = ERPG_Utils.get_time() - tmp  
			   object_max = v
			end
		     end
		  end
		  if v.callbacks and v.callbacks.on_render then
		  v.callbacks.on_render()
		  end
		  
		  if v.objects then
		     rendering(v,hold)
		  end	
	       end
	    end
	 end     
      end
	 
      local time = ERPG_Utils.get_time()

      rendering(object)
      if (ERPG_Utils.get_time() - time ) > 700 then
	 print(ERPG_Utils.get_time() - time,"ms obecnej ",max)
	 for k,v in pairs(object_max) do
	    print(k,v)
	 end
	 object_max:print()
      end

      if main_window.last_render_object then
	 rendering({["objects"] = {main_window.last_render_object}},true)
     end
      
      if main_window.cursor then
	 main_window.cursor:set_position(mouse.x,mouse.y)
	 main_window.cursor:copy_to_renderer()
      end

   end

   local function on_load(main_window, obj)
      send_event(obj,"on_load",main_window)
   end
  
   
   main_window = {
      ["id"] = "main window",
      ["print"] = function () print("main_window") end,
      ["window"] = window,
      ["focus"] = nil,
      ["cursor"] =nil,
      ["holding"]=nil,
      ["last_render_object"] = nil,
      ["bound_box"] = {["x"]=0, ["y"]=0, ["w"] = SCREEN.w,["h"] = SCREEN.h},
      ["callbacks"] = {["on_iter"] = nil,
		       ["on_destroy"] = on_destroy,   
		       ["on_click"] = {},
		       ["on_load"] = on_load,
		       ["holding"] = nil,
		       ["on_exit"] = function () ERPG_Core.set_exit() end
      }}

   function main_window:set_last_render_object(object)
      main_window["last_render_object"] = object
   end
   function main_window:remove_last_render_object()
      main_window.last_render_object = nil
   end
   add_event(main_window, "on_render",on_render)

   return function (func)
      main_window.callbacks.on_iter = func
      main_window.callbacks["on_iter"] = func
      main_window.callbacks["on_iter"](main_window, mouse, keyboard)
      on_iter(main_window,main_window)
      
      ERPG_Audio.update_mixer()     
   end
end

function create_window(iter_function,on_load)
   local first = true
   local last_mouse = mouse
   local count = 0

   local function browse(self, mouse)
      for i=#(self.objects or {}), 1, -1 do
	 value = self.objects[i]
	 if value and value.bound_box and intersect_point(value.bound_box, mouse.x, mouse.y) then
	    if value.callbacks.on_click then		     		    
	    end				  	
	    main_window.holding = value
	    main_window.focus = value
	    
	    browse(value,mouse)
	    return i
	 end	       
      end
   end

   local function on_click(main_window, mouse, last_mouse)
      

      if mouse.release ~= "none" or last_mouse.press == "left" and mouse.press == "none" then
	 count = count + 1
	 main_window.holding = nil
	 if main_window.focus then
	    send_event(main_window.focus,"on_click", mouse)
	 else
	    browse(main_window, mouse, last_mouse)
	    if main_window.focus then send_event(main_window.focus,"on_click", mouse) end
	 end
	 
	 main_window.focus = nil
      end
      if  mouse.press ~= "none" and mouse.press_motion =="none"  then
	 index = browse(main_window,mouse, last_mouse)
	 if main_window.focus then 
	    if mouse.on_press ~= "none" then
	       send_event(main_window.focus, "on_press", mouse.on_press)
	    end
	    send_event(main_window.focus, "on_mouse_press", mouse.press) 
	 end
	 if mouse.press ~= "none" or last_mouse.press == "none" then
	    if  index and main_window.objects[index]["dock"] == nil then
	       main_window.objects[#main_window.objects] = table.remove(main_window.objects, index)
	       for k,v in ipairs(main_window.objects) do
		  if v.main_frame then		     
		     index = browse(v, mouse,last_mouse)
		     if index and v.objects[index]["dock"] == nil then
			v.objects[#v.objects] = table.remove(v.objects, index)
		     end
		  end
	       end
	    end
	 end
      end
   end     

   local function create_mouse( mouse)
      local game_mouse = {}
      game_mouse.x = mouse.x
      game_mouse.y = mouse.y      
      game_mouse.press = mouse.press
      game_mouse.release = mouse.release
      game_mouse.on_press = mouse.on_press
      game_mouse.wheel_x = mouse.wheel_x
      game_mouse.wheel_y = mouse.wheel_y   

      return game_mouse
   end

   local function on_motion(main_window, mouse, last_mouse)
      if (last_mouse.press_motion ~= "none" and mouse.press_motion == "none") or
	 (last_mouse.press_motion ~= mouse.press_motion) or (main_window.holding ~=
	 main_window.last_holding)
      then
--	 print("ON RELEASE MOTION----------")
	 local holding = main_window.holding
	 local focus = main_window.focus
	 local index = browse(main_window,mouse,last_mouse)
	 if main_window.last_holding then
	    send_event(main_window.last_holding,"on_release_motion",{mouse, main_window.focus})
	 end
	 main_window.focus = focus
	 main_window.holding = holding
      end

      if mouse.press_motion ~= "none" then
	 if main_window.holding == nil then
	    local mouse1 = create_mouse(mouse)
	    mouse1.press = "left"
	    mouse1.on_press = "left"
	    mouse1.press_motion = "none"
	    on_click(main_window, mouse1, last_mouse)
	 end
      end
      if (mouse.release ~= "none" or mouse.press ~= last_mouse.press) and 
      last_mouse.press_motion ~= "none" then
--[[
	 local holding = main_window.holding
	 local focus = main_window.focus
	 local index = browse(main_window,mouse,last_mouse)
	 if holding then
	    send_event(holding,"on_release_motion",{mouse, main_window.focus})
	 end
	 main_window.focus = focus
   main_window.holding = holding]]
      end
      if main_window.holding and mouse.press_motion ~= "none" then
	 local motion = {["x"] = mouse.x - last_mouse.x,
			 ["y"] = mouse.y - last_mouse.y, ["press_motion"] = mouse.press_motion}
			 
	 send_event(main_window.holding,"on_motion", motion)
--	 main_window.last_holding = main_window.holding
      else
	 main_window.holding = nil
      end
      main_window["last_holding"] = main_window.holding
   end

   local function on_press_key(main_window, keyboard)
      if #keyboard.press > 0 then
	 send_event(main_window.objects[#main_window.objects], "on_press_key", keyboard.press)
      end
   end

   local function on_input_key(main_window, keyboard)
      if keyboard.input_key then
	 send_event(main_window.objects[#main_window.objects], "on_input_key", keyboard.input_key)	
      end
   end   
   
   local function on_release_key(main_window, keyboard)
      if #keyboard.release > 0 then
	 send_event(main_window.objects[#main_window.objects], "on_release_key", keyboard.release)
      end
   end

   local function on_wheel(main_window, mouse)
      if mouse.wheel_y ~= 0 then
	 send_event(main_window.objects[#main_window.objects],"on_wheel", mouse.wheel_y)
      end
   end
   local function on_events(self, main_window)
      local copy_table = {}
      local function on_events_rek(self)
	 if self.objects then
	    for key,value in pairs(self.objects) do	    
	       on_events_rek(value)
	       if value.callbacks.events_load then
		  for k,v in ipairs(value.callbacks.events_load) do
		     copy_table[k] = v
		  end
		  value.callbacks.events_load = {}
		  for key,event in ipairs(copy_table) do
		     event.func(value, event.parametrs)
		  end
		  copy_table = {}
	       end
	       if value.callbacks.events then
		  for k,v in ipairs(value.callbacks.events) do
		     copy_table[k] = v
		  end
		  value.callbacks.events = {}
		  for key,event in ipairs(copy_table) do

		     event.func(value, event.parametrs)
		  end
		  copy_table = {}
	       end
	       if value.callbacks.events_destroy then
		  for k,v in ipairs(value.callbacks.events_destroy) do
		     copy_table[k] = v
		  end
		  value.callbacks.events_destroy = {}
		  value.callbacks_events = {}
		  for key,event in ipairs(copy_table) do
		     event.func(value, event.parametrs)
		  end
		  copy_table = {}
	       end

	    end
	 end
      end
	 on_events_rek(self)
   end
   
   return function(main_window, mouse,keyboard)
      if first then
	 last_mouse = mouse
	 on_load(mouse,keyboard)
	 main_window.window.start_input_text()
	 first = false
      end
  

     if main_window.objects then
--	 send_event(main_window, "on_render") 
	 on_wheel(main_window, mouse)
	 on_press_key(main_window, keyboard)
	 on_input_key(main_window, keyboard)
	 on_release_key(main_window, keyboard)

	 on_motion(main_window,mouse, last_mouse)	 	 
	 on_click(main_window, mouse, last_mouse)

	 on_events({["objects"] = {main_window}}, main_window)

	 iter_function( mouse, keyboard)

	 main_window.callbacks.on_render(main_window)
	 --on_press_click(main_window,mouse,last_mouse

    end
	 last_mouse = mouse
   end
end

function get_active_object_by_mouse_position(objects_from)
   local x,y = mouse.x,mouse.y
   local out 
   local function find_object(self)
      if self.objects then
	 for k=#self.objects,1,-1 do
	    local v = self.objects[k]
	    if intersect_point(v.bound_box,x,y) then
	       out = v	 
	       return v
	    end	    
	 end
      end
   end

   find_object(objects_from)
   return out
end


START_CYCLE = start_engine()

function game_main(main_window, mouse,keyboard)
  -- print " HEJ"
end


function set_cursor(sprite)
   if main_window.cursor == nil then
      ERPG_window:show_cursor(0)
   end

   main_window.cursor = sprite
end
function get_cursor()
   return main_window.cursor
end

--START_CYCLE(30,create_engine(game_main, main_load))

