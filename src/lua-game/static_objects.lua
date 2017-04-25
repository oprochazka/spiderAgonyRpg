local SObj = {}

function SObj.make_static_object(x,y,id)
   local element = make_graphic_element(x,y)
   
   element["name"] = "static object"
   element["on_iter"] = nil
   
   return element
end

function SObj.get_all_objects()
   local count = #SObj.hash_object * 8
   local iter = 1
   return function ()
      if iter <= count then
         return SObj.get_sprite(iter)
      end
   end
end

--!! static objects please get out from this class
function SObj.create_hash(static_objects)
   local hash_table = {}
   local count= {}
   for k,v in ipairs(static_objects) do
      hash_table[#hash_table+1] = v
      for k=1,4 do
         count[#count + 1] = #count 
      end
   end
   count[#count+1] = #count
   SObj["hash_object"] = hash_table
   return count, hash_table
end

function SObj.get_sprite_by_name(name)
   for k,v in ipairs(SObj.hash_object) do
      if v.name == name then
   	 local result = v
   	 local path = result.path

   	 path = PATH_SObj .. path .. ".png"

   	 local sprite = ERPG_sprite.make(path, {255,0,255})
   	 local count = result.count or 4

   	 sprite:set_clips(1,count)
   	 sprite:set_clip(0, 0)

   	 return sprite,result.move_x,count,result.on_draw,result.layer,result.name, result.through
      end
   end

end

function SObj.get_sprite(num)
   if type(num) == "string" then
      return SObj.get_sprite_by_name(num)
   end
   if SObj.hash_object == nil or SObj.hash_object[math.floor((num-1)/4)+1] == nil then 
      return 
   end
   local result = SObj.hash_object[math.floor((num-1)/4)+1]
   local path = result.path

   path = PATH_SObj .. path .. ".png"

   local sprite = ERPG_sprite.make(path, {255,0,255})
   local count = result.count or 4

   sprite:set_clips(1,count)
   sprite:set_clip(0, num % count)

   return sprite,result.move_x,count,result.on_draw,result.layer,result.name, result.through
end

local SObjDef = {}

local function storeStaticObject(self)
   self["slot"] = {}

   function self:add_item(item)
      self["slot"][#self.slot+1] = item
   end
end

function SObjDef.chest(self)
   storeStaticObject(self)
end

function SObj.load_object(num,iter_x, iter_y, slot)
   if num ~= 0 then
      local w,h = Map.tile_size.w/2,Map.tile_size.h/2
      local x,y = Tiles.tile_to_point(iter_x,iter_y)
      local sprite,mov_x,count,on_draw,layer,name,through = SObj.get_sprite(num)	      

      local gm = make_graphic_element()
      gm:set_sprite(sprite)

      x = x  + mov_x
      y = y - gm.bound_box.h + h

      gm:set_position(x,y)
      gm["type"] = "static"
      gm["num"] = num
      gm["on_draw"] = on_draw
      gm["name"] = name
      gm["through"] = through
      gm["EId"] =  IdG.getId()
      function gm:remove_slot()
   	 gm.slot = nil
      end

      function gm:dump()
      	 local dump = {}
      	 dump["id"] = Map.get_id()
      	 dump["type"] = "static"
      	 dump["name"] = self.num

      	 if self.slot and type(self.slot) == "table" then	
      	    dump["slot"] = self.slot
      	 end

      	 return dump
      end

      if SObjDef[gm.name] then
         SObjDef[gm.name](gm)
      end
      if slot then
         gm["slot"] = slot
      end

      gm:set_position(x,y)      
   
      return gm, layer
   end
   return 0
end

return SObj