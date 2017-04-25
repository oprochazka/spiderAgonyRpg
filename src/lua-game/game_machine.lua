local GAME_MACHINE = {   
   
}   

function make_canvas(canvas_x,canvas_y,canvas_width,canvas_height,field_w, field_h)
   local canvas = {
      ["x"] = canvas_x,
      ["y"] = canvas_y,
      ["width"] = canvas_width,
      ["height"] = canvas_height,
      ["field_width"] = field_w,
      ["field_height"] = field_h,		   
      ["canvas_frame"] = GUI.make_empty_frame({canvas_x,canvas_y,canvas_width,canvas_height},
					      {50,50,50,255}),
      ["clip"] = { canvas_x,canvas_y}
   }

   local function on_render()
      GAME_MACHINE:rendering()
   end

   add_event(canvas.canvas_frame, "on_render", on_render)

   canvas.canvas_frame.dock = true

   function canvas:move(x,y)
      canvas.clip[1] = canvas.clip[1] + x
      canvas.clip[2] = canvas.clip[2] + y
   end

   function canvas:set_position(x,y)
      canvas.clip.x =  x
      canvas.clip.y =  y
   end

   function canvas:get_size()
      return self.width,self.height
   end
   function canvas:get_clip()
      return self.clip[1],self.clip[2]
   end

   return canvas
end

function GAME_MACHINE:setServer(promp)
      GAME_MACHINE["server"] = promp
end

function GAME_MACHINE:setClient(promp)
  GAME_MACHINE["client"] = promp
end

function make_game_machine(main_frame,canvas_width, canvas_height)

    GAME_MACHINE["canvas"] = nil
    GAME_MACHINE["gui_objects"] = {}
    GAME_MACHINE["main_frame"] = nil
    GAME_MACHINE["callbacks_iter"] = {}
    GAME_MACHINE["callbacks"] = {}
    GAME_MACHINE["callbacks_destroy"] = {}
    GAME_MACHINE["layers"] = {}
    GAME_MACHINE["iterate?"] = true
    GAME_MACHINE["time"] = 0
    GAME_MACHINE["last_time"] = 0
    GAME_MACHINE["mouse"] = {["x"] = 0, ["y"] = y,
		   ["press"] = "none",
		   ["release"] = "none",
		   ["on_press"] = "none",
		   ["wheel_x"] = 0,
		   ["wheel_y"] = 0}

    GAME_MACHINE["keyboard"] = {}

    GAME_MACHINE["userUI"] = nil

    GAME_MACHINE["server"] = nil
    GAME_MACHINE["client"] = nil
   

   GAME_MACHINE["canvas"] = make_canvas(0,0,canvas_width,canvas_height, 64, 32)
   GAME_MACHINE["main_frame"] = main_frame
   return GAME_MACHINE
end

function GAME_MACHINE:setUserUI(userUI)
  GAME_MACHINE.userUI = userUI
end

function GAME_MACHINE:getUserUI()
  return GAME_MACHINE.userUI
end

function get_game_machine()
   return GAME_MACHINE
end
function GAME_MACHINE:get_main_frame()
   return GAME_MACHINE.main_frame
end
function GAME_MACHINE:get_canvas_frame()
   return GAME_MACHINE.canvas.canvas_frame
end

function GAME_MACHINE:create_layer()
   self.layers[#self["layers"] + 1] = {}

   return #self["layers"]
end

function GAME_MACHINE:get_canvas_box()
   local box = GAME_MACHINE.canvas
   return {["x"] = box.x, ["y"] = box.y, ["w"] = box.width, ["h"] = box.height}
end

function GAME_MACHINE:set_layer(graphics_elements, layer)
   local position_layer = self.layers[layer]
   
   if position_layer then
      self.layers[layer][#self.layers[layer]+1] = graphics_elements
   else
      print("Layer: " .. layer .. " non exist")
   end
end

function GAME_MACHINE:replace_layer(graphics_elements, layer)
   local position_layer = self.layers[layer]

   if position_layer then
      self.layers[layer] = {}
      self.layers[layer][#self.layers[layer]+1] = graphics_elements
   else
      print("Layer: " .. layer .. " non exist")
   end
end

function GAME_MACHINE:set_order(graphics_elements, order, current_layer)   
   local move
   local current_layer = self.layers[current_layer]

   if order > #current_layer then order = #current_layer end
   if order < 1 then order = 1 end
   
   for k,v in ipairs(current_layer) do
      if graphics_elements == v then
	 move = order - k
	 local mover = 1

	 if move < 0 then mover = -1; end
	 if move == 0 then break; end

	 for i = 0, math.abs(move) do
	    current_layer[k+(i * mover)], current_layer[k+((i + 1) * mover)] =
	       current_layer[k+((i + 1) * mover)], current_layer[k+(i * mover)]
	 end
      end
   end   
end

function GAME_MACHINE:move_order(graphics_elements, n, current_layer)
   local current_layer = self.layers[current_layer]
   for k,v in ipairs(current_layer) do
      if graphics_elements == v then
	 GAME_MACHINE:set_order(graphic_element, k+n, current_layer)
      end
   end
end

function GAME_MACHINE:set_other_layer(graphics_elements, layer, current_layer)
   local current_layer = self.layers[current_layer]
   local move_layer = self.layers[layer]
   local obj
   for k,v in ipairs(current_layer) do
      if graphics_elements == v then
	 obj = table.remove(current_layer, k)
	 if move_layer then
	    move_layer[#move_layer + 1] = obj
	 else	    
	    print("Layer: " .. layer .. "non exist")
	 end
      end
   end
end

function GAME_MACHINE:rendering()
   for k,v in ipairs(self.layers) do
      for k,graphics_elements in ipairs(v) do
	 for k,graphic_element in ipairs(graphics_elements) do
	    if graphic_element.render then
	       if graphic_element.sprite then
		  graphic_element.sprite:set_position(graphic_element.bound_box["x"],
						      graphic_element.bound_box["y"])
		  graphic_element.sprite:copy_to_renderer()	       
	       end
	       if graphic_element.sound then	       
		  if graphic_element.sound[1] > 0 and graphic_element.sound[2] then
		     if _OPTIONS.sound then
			graphic_element.sound[2]:stop()
			graphic_element.sound[2]:copy_to_mixer()
		     end
		     graphic_element.sound[1] = graphic_element.sound[1]-1
		  end
	       end
	    end
	 end
      end	 
   end		      
end

function GAME_MACHINE:remove_object(obj, current_layer)
   local current_layer = self.layers[current_layer]

   for k,v in ipairs(current_layer) do
      if v == obj then
	 table.remove(current_layer, k)
      end
   end
end



function GAME_MACHINE:apply_callbacks()
   local count = 0
   for k,v in ipairs(GAME_MACHINE.callbacks_iter) do
      count = count + 1
      v.callback_iter(v)
      
      if v.destroy then
	 table.remove(GAME_MACHINE.callbacks_iter,k)
      end    
   end

   for k,v in ipairs(GAME_MACHINE.callbacks) do
      v[2](v[1],v[3])
   end

   for k,v in ipairs(GAME_MACHINE.callbacks_destroy) do
      v[1].callback_destroy(v[1], v[2])
   end

   GAME_MACHINE.callbacks_destroy = {}
   GAME_MACHINE.callbacks = {}
end

function GAME_MACHINE:add_event(obj, name_event, func)

   if name_event == "on_iter" then
      obj["callback_iter"] = func
      local exist = nil
      for k,v in ipairs(GAME_MACHINE.callbacks_iter) do
    	 if v == obj then
    	    return
    	 end
      end     
      GAME_MACHINE.callbacks_iter[#GAME_MACHINE.callbacks_iter + 1] = obj      
      
      return
   elseif name_event == "on_destroy" then
      obj["callback_destroy"] = func
      return
   end

   if obj.callbacks == nil then
      obj.callbacks = {}
   end
   obj.callbacks[name_event] = func
 
end

function GAME_MACHINE:send_event(obj, name_event, args)
   if name_event == "on_destroy" then
      for k,v in ipairs(GAME_MACHINE.callbacks_iter) do
	 if v == obj then
	    table.remove(GAME_MACHINE.callbacks_iter, k)
	    break
	 end
      end

      GAME_MACHINE.callbacks_destroy[#GAME_MACHINE.callbacks_destroy + 1] = {obj, args}
      return
   end
   
   if obj.callbacks then
      local func_callback = obj.callbacks[name_event]
      if func_callback then
    	 GAME_MACHINE.callbacks[#GAME_MACHINE.callbacks + 1] = {obj, obj.callbacks[name_event], args}
    	 return
      end      
   end
--   print("Callback: " .. name_event .. " non_exist")
end

function GAME_MACHINE:remove_event(obj, name_event)
   if name_event == "on_iter" then
      for k,v in pairs(self.callbacks_iter) do
	 if v == obj then
	    table.remove(self.callbacks_iter, k)
	 end
      end
   end
   if obj.callbacks then
      obj.callbacks[name_event] = nil
   end
end

function GAME_MACHINE:aktualize_time()
   if GAME_MACHINE.last_time then
      GAME_MACHINE.time = GAME_MACHINE.time + (ERPG_Utils.get_time() - GAME_MACHINE.last_time)
   end
   GAME_MACHINE.last_time = ERPG_Utils.get_time()
end

function GAME_MACHINE:start_time()
   GAME_MACHINE.last_time = ERPG_Utils.get_time()
end

function GAME_MACHINE:stop_time()
   GAME_MACHINE:aktualize_time()
   GAME_MACHINE.last_time = 0
end

function GAME_MACHINE:get_time()
   return GAME_MACHINE.time
end

function GAME_MACHINE:set_time(time)
   GAME_MACHINE.time = time
   GAME_MACHINE.last_time = ERPG_Utils.get_time()
end

local function set_mouse(game_mouse, mouse)
     game_mouse.x = mouse.x
     game_mouse.y = mouse.y
     game_mouse.move_x = mouse.x + Map.tile_size.w
     game_mouse.move_y = mouse.y +Map.tile_size.h/2
     game_mouse.press = mouse.press
     game_mouse.release = mouse.release
     game_mouse.on_press = mouse.on_press
     game_mouse.wheel_x = mouse.wheel_x
     game_mouse.wheel_y = mouse.wheel_y   
end

function GAME_MACHINE:set_mouse_canvas()
   local c_frame = GAME_MACHINE:get_canvas_frame()
   local game_mouse = GAME_MACHINE.mouse
   local canvas = GAME_MACHINE.canvas
   local function on_click(self,mouse)
      set_mouse(game_mouse,mouse)
   end
   local function on_motion(self,mouse)
      set_mouse(game_mouse,mouse)
   end
   local function on_press(self,mouse)
      set_mouse(game_mouse,mouse)
   end
   
   local function on_mouse_press(self,mouse)
      set_mouse(game_mouse,mouse)
   end
   local function on_wheel(self, mouse)
      set_mouse(game_mouse,mouse)
   end

   GUI.add_event(c_frame"on_click", on_click)
   GUI.add_event(c_frame"on_motion", on_motion)
   GUI.add_event(c_frame"on_press", on_press)
   GUI.add_event(c_frame"on_mouse_press", on_mouse_press)
   GUI.add_event(c_frame"on_wheel", on_wheel)   
end

function GAME_MACHINE:refresh_game_mouse(main_frame)
  local object = GUI.get_active_object_by_mouse_position(main_frame)
  local game_mouse = GAME_MACHINE.mouse
  local canvas_frame = GAME_MACHINE:get_canvas_frame()
  if object == canvas_frame then
     game_mouse.x = mouse.x
     game_mouse.y = mouse.y
     game_mouse.move_x = mouse.x + Map.tile_size.w
     game_mouse.move_y = mouse.y +Map.tile_size.h/2
     game_mouse.press = mouse.press
     game_mouse.release = mouse.release
     game_mouse.on_press = mouse.on_press
     game_mouse.wheel_x = mouse.wheel_x
     game_mouse.wheel_y = mouse.wheel_y   

--     if mouse.press_motion ~= "none" then
--	game_mouse.on_press = "none"
 --    end
  else
     if game_mouse.press ~= "none" then
	game_mouse.release = game_mouse.press
     else
	game_mouse.release = "none"
     end
     game_mouse.press= "none"

     game_mouse.on_press = "none"
     game_mouse.wheel_x = 0
     game_mouse.wheel_y = 0
  end
end

function GAME_MACHINE:get_mouse()
   return GAME_MACHINE.mouse
end