dofile(PATH_GAME .. "game_machine.lua")
dofile(PATH_GAME .. "gui_game_config.lua")
--dofile(PATH_GAME .. "items_config.lua")

Tiles = require(PATH_GAME .. "tiles")
Map = require(PATH_GAME .. "map")
Character = require(PATH_GAME .. "character")
Serialization = require(PATH_GAME .. "serialize")

Palet = require( PATH_EDITOR .. "palet")
Menu = require( PATH_EDITOR .. "editor_menu")
Mini_map = require( PATH_EDITOR .. "minimap")
ToolBar = require( PATH_EDITOR .. "toolbar")
Brush = require(PATH_EDITOR .. "brush")
Console = require(PATH_EDITOR .. "console")

local Editor = {}

local screen_map
local tile_cursor
local tile_info
local create_fce
local layer = 1
local brush_cursor = _BRUSH_TYPES[1].data
local mini_map 

local function set_cursor(data, path)
   local game_machine = get_game_machine()

   tile_info = path

   local sp = Brush.create_brush(brush_cursor,path, create_fce)

   sp:set_modulation_color(200,200,200,1)   
   sp:set_alpha(100,1) 
 
   if tile_cursor == nil then
      tile_cursor = make_graphic_element(x,y)
   end
   
   tile_cursor:set_sprite(sp)
   
   game_machine:replace_layer({tile_cursor}, 4)
end

local function on_change_tile(self, path)  
   local path = path
   layer = 1
   create_fce = nil
   if path then      
      set_cursor(brush_cursor, path)
   end
end

local function on_change_wall(self, info)
   create_fce = Palet.make_wall_look
   layer = 2
   if info then
      set_cursor(brush_cursor, info)
   end
end

local function on_change_monster(self, info)
   create_fce = Palet.make_monster_prew
   layer = 2
   if info then
      set_cursor(brush_cursor, info)
   end
end

local function on_change_brush(self,data)
   local game_machine = get_game_machine()

   if data then
      brush_cursor = data
   end
   if tile_info then
      set_cursor(brush_cursor, tile_info)
   end
end

local function frame_on_iter(self)
   local game_machine = get_game_machine()
    
   if tile_cursor and GUI.intersect_point(game_machine:get_canvas_frame().bound_box, mouse.x, mouse.y) 
   then
      local mouse = {["x"] =  mouse.x - math.floor(#brush_cursor[1]/2)*Tiles.tile_size.w, 
		     ["y"] = mouse.y- math.floor(#brush_cursor/2)*(Tiles.tile_size.h/2)}
       
      v = Tiles.get_position_tile_point(mouse.x,
					mouse.y)
	 
	 ---math.floor(#brush_cursor/2 - 0.5)
      --	 -math.floor(#brush_cursor[1]/2 - 0.5)
      if v then
	 local x,y = Tiles.tile_to_point(v[1],
					 v[2])

	 x = (x - Tiles.x) - Tiles.progress_x - Tiles.tile_size.w + screen_map.bound_box.x
	 y = (y - Tiles.y) - Tiles.progress_y - Tiles.tile_size.h + screen_map.bound_box.y    

	 tile_cursor:render_on()
	 tile_cursor:set_position(x,y)      
      end
   else
      if tile_cursor then
	 tile_cursor:render_off()
      end
   end      
end

local function on_click_map(self,mouse_pos)	
   if keyboard.press[1] == "Left Ctrl" then
      local mouse = {["x"] = mouse.x, 
		     ["y"] = mouse.y}

      v = Tiles.get_position_tile_point(mouse.x,
					mouse.y)      
      
      local elems = MpR.get_elements(v[1],v[2])
      _CONSOLE:add_text("Field: x=" .. v[1] .. ", y=" .. v[2])
      if elems then	 
	 if type(elems[1]) == "table" then
	    _ELEMENT_FIRST = elems[1]
	    local str = elems[1].name or ""
	    _CONSOLE:add_text("Prompt: _ELEMENT_FIRST :" .. str)
	 end
	 if type(elems[2]) == "table" then
	    _ELEMENT_SECOND = elems[2]
	    local str = elems[2].name or ""
	    _CONSOLE:add_text("Prompt: _ELEMENT_SECOND :" .. str)
	 end
	 if type(elems[3]) == "table" then
	    _ELEMENT_THIRD = elems[3]
	    local str = elems[3].name or ""
	    _CONSOLE:add_text("Prompt: _ELEMENT_THIRD :" .. str)
	 end
      end
      
   else
      GUI.send_event(self.parrent,"on_activate", self)
      if GUI.intersect_point(self.bound_box, mouse.x,mouse.y) then
	 local mouse = {["x"] = mouse.x - math.floor(#brush_cursor[1]/2)*Tiles.tile_size.w, 
			["y"] = mouse.y- math.floor(#brush_cursor/2)*(Tiles.tile_size.h/2)}

	 v = Tiles.get_position_tile_point(mouse.x,
					   mouse.y)      
	 local path = tile_info
	 if path and v then

	    Brush.write_data(brush_cursor,tile_info, v,layer)
	    Mini_map.refresh(mini_map,v[1],v[2],brush_cursor)

	 end
      end
   end
end
local add = 0
function Editor.start(frame)
   dofile(PATH_GAME .. "game_machine.lua")
   dofile(PATH_GAME .. "window_machine.lua")

   local width, height = 1024, 768
   local game_machine = make_game_machine(frame,width,height)
   local iter =1
   local canvas_frame = game_machine:get_canvas_frame()
   _CONSOLE = Console.make()
   local console = _CONSOLE
   Editor["activate"] = nil

   game_machine:create_layer()
   game_machine:create_layer()
   game_machine:create_layer()
   game_machine:create_layer()

   GUI.compose_object(frame, canvas_frame)   
   
   screen_map = make_graphic_element(width,height)
   Map.Initialize_map(screen_map)

   Map.generate(200,400,5)
   Map.render(64,64)
   game_machine:set_layer({render_map}, 1)

   game_machine:set_layer({screen_map}, 1)

   
   local palet = Palet.make_tile(_PALET_ITEM)

   local palet2 = Palet.make_walls(SObj.create_hash(_OBJECTS_ITEM))  
   GUI.compose_object(frame, palet2)   

   local palet3 = Palet.make_monstres(_DObjects)
   GUI.compose_object(frame, palet3)
   
   local palet4 = Palet.make_monstres(_NObjects)
   GUI.compose_object(frame, palet4)


   local function on_iter(self)
      if keyboard.press[1] == "Up" then
	 Map.move(0,-8)
      end
      if keyboard.press[1] == "Down" then
	 Map.move(0,8)
      end	    
      if keyboard.press[1] == "Left" then
	 Map.move(-16,0)
      end
      if keyboard.press[1] == "Right" then
	 Map.move(16,0)
	 add = add + 4
      end
   end

   local v = nil
   local function on_input_key(self, press_key)
  --    for k, v in ipairs(self.objects) do
--	 GUI.send_event(v,"on_input_key", press_key)
    --  end
      GUI.send_event(Editor.activate,"on_input_key", press_key)
   end

   local function on_release_key(self, release)
      if release[1] == "Escape" then
	 GUI.send_event(frame,"on_resume")
      else
--	 for k, v in ipairs(self.objects) do
--	    GUI.send_event(v,"on_release_key", release)
--	 end
	 GUI.send_event(Editor.activate,"on_release_key", release)
      end
   end

   game_machine:add_event(screen_map, "on_iter", on_iter)

   GUI.add_event(canvas_frame, "on_click", on_click_map)
   GUI.add_event(canvas_frame, "on_motion", on_click_map)

   GUI.add_event(frame, "on_input_key", on_input_key)
   GUI.add_event(frame, "on_release_key", on_release_key)

   GUI.add_event(frame,"on_change_tile", on_change_tile)
   GUI.add_event(frame,"on_change", on_change_wall)
   GUI.add_event(frame,"on_change_monster", on_change_monster)
   GUI.add_event(frame,"on_change_brush", on_change_brush)
   GUI.add_event(frame, "on_click_save", function ()
		    print("SAVING...")
						end)
   GUI.add_event(frame, "on_activate", function(self, who)
		    Editor.activate = who
				       end)
		    
   mini_map = Mini_map.make()

   GUI.compose_object(frame,mini_map)
   GUI.compose_object(frame, Menu.make())
   GUI.compose_object(frame, palet)
   GUI.compose_object(frame, console)
   
   local function on_change_mini_map()
      Mini_map.set_new(mini_map,field)
   end

   GUI.add_event(frame,"on_change_map", on_change_mini_map)

   screen_map:move(0,20)
   canvas_frame:move(0,20)
  
   local tool = Brush.make(_BRUSH_TYPES)
   
   GUI.compose_object(frame, tool)
   tool:move(200+width +200, 100)
   palet:move(100+width + 200, 100)
   mini_map:move(100+width + 200,600)
   local sps = {}

   Editor.activate = canvas_frame

   return function(self)	 

      game_machine:refresh_game_mouse(frame)
--      local v = Tiles.get_position_tile_point(100,100) 
 --  collectgarbage('stop')
      iter = iter + 1
      game_machine:apply_callbacks()

      frame_on_iter()
      if v then

      end
   end
end

return Editor
