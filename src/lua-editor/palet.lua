local Palet = {}

function Palet.make_field_item(path)
   local out = GUI.make_sprite(path)
   out["info"] = path
   out["name"] = "palet_field"
   return out
end

local function on_lines(x,y)

end

function Palet.make(list, on_focus)
   local on_click = on_focus
   local count = #list
   local margin = 5
   local size_x, size_y = 64, 32
   local palet_frame = ToolBar.make(on_click)
   local position = 1
   local element = nil
   local game_machine = get_game_machine()

   function palet_frame:get_focus_info()
      if palet_frame.focus_field then
	 return palet_frame.focus_field.info
      end
   end   

   function palet_frame:set_item(item)
      if position <= count then
      	 palet_frame.fields[position]:set_sprite(item)
      	 position = position + 1	 
      end
   end 
   
   return palet_frame
end

function Palet.make_tile(list)   
   local function on_click(self, mouse)
      GUI.send_event(self.parrent,"on_change_tile", self:get_focus_info())
   end
   
   local palet_frame = Palet.make(list,on_click)

   for k,v in ipairs(list) do
      palet_frame:add_item(ToolBar.make_item(v[1]))
   end

   return palet_frame
end

function Palet.make_wall_look(item)
   local v = item

   if item ~= 0 then
      --local sprite = ERPG_sprite.make(v.path,{255,0,255,255})
      local sprite,x,count = SObj.get_sprite(item)
      -- sprite:set_clips(v.info.crop[1],v.info.crop[2])
      -- sprite:set_clip(v.info.current[1], v.info.current[2])
      local w, h = sprite:get_max_size()
      
      --   local x = w/v.info.crop[1]
      local y = h/count
      
      sprite:scale(-(w-64),-(y-32))
      return sprite, count
   end
   return ERPG_geometry.make_rectangle({0,0,64,32},{255,0,255,255},1),4
end
function Palet.make_monster_prew(item)
   local v = item

   return ERPG_geometry.make_rectangle({0,0,64,32},{255,0,255,255},1)
end
function Palet.make_walls(list)
   local function on_click(self, mouse)
      GUI.send_event(self.parrent,"on_change", self:get_focus_info())
   end

   local palet_frame = Palet.make(list,on_click)
   local tmp = 0
   for k,v in ipairs(list) do
      if tmp == 0 then
	 local sprite,count = Palet.make_wall_look(v)
	 tmp = ( 4 - count)
	 palet_frame:add_item(ToolBar.make_item_sprite(sprite,v))
      else
	 tmp = tmp -1
      end
   end

   return palet_frame
end

function Palet.make_monstres(list)
   local function on_click(self, mouse)
      GUI.send_event(self.parrent,"on_change_monster", self:get_focus_info())
   end
   
   local palet_frame = Palet.make(list, on_click)


   for k,v in pairs(list) do
      local sprite = ERPG_sprite.make(v.preview, {255,0,255,255})
      local rect = sprite:get_size()
      sprite:scale(-(rect.w - 64),-(rect.h-32))

      palet_frame:add_item(ToolBar.make_item_sprite(sprite, k))
   end

   return palet_frame
end


return Palet