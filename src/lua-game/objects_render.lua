local SObj = {}
SObj["max_h"] = 32*5
SObj["max_w"] = 0

function SObj.make_static_object(x,y,id)
   local element = make_graphic_element(x,y)
   
   element["name"] = "static object"
   element["on_iter"] = nil
   
   return element
end

local function get_start_load_size()
   local from_x = math.floor((Tiles.x)/ Tiles.tile_size.w)
   local from_y = math.floor((Tiles.y)/ (Tiles.tile_size.h/2) +1)   
   return from_x,from_y
end

local function get_end_load_size()
   local machine = get_game_machine()
   local screen_w,screen_h = machine.canvas:get_size()
   return math.floor((screen_w)/Tiles.tile_size.w+2 + SObj.max_w/Tiles.tile_size.w),
   math.floor((screen_h)/(Tiles.tile_size.h/2)+1 +2 + SObj.max_h/Tiles.tile_size.h)+4
end

function SObj.initialize(screen_map)   
   local max_w, max_h = get_end_load_size()

   SObj["screen_map"] = screen_map     
end

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

function SObj.get_all_objects()
   local count = #SObj.hash_object * 8
   local iter = 1
   return function ()
      if iter <= count then
	 return SObj.get_sprite(iter)
      end
   end
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



function SObj.get_sprite2(id)
   

end

function SObj.set_element(x,y,element,layer)
   if SObj.fields[y] == nil then SObj.fields[y] = {} end

   if layer == nil then
      SObj.fields[y][x] = 0
      return
   end

   if SObj.fields[y] then
      if SObj.fields[y][x] == nil or SObj.fields[y][x] == 0 then
	 SObj.fields[y][x] = {0,0,0}
      end

      SObj.fields[y][x][layer] = element
   end
end

function SObj.set_empty(x,y,layer)
   if SObj.fields[y] == nil then SObj.fields[y] = {} end
   if layer == nil or layer == 0 then
      SObj.fields[y][x] = 0
   else
      SObj.fields[y][x][layer] = 0
   end
end

function SObj.get_elements(x,y)
   if SObj.fields[y] and SObj.fields[y][x] ~= 0 then
      return SObj.fields[y][x]
   end
end
function SObj.get_element(x,y,layer)
   if SObj.fields[y] == nil or SObj.fields[y][x] == nil then
      return 
   end

   if SObj.fields[y] and SObj.fields[y][x] ~= 0 then
      return SObj.fields[y][x][layer]
   end
   return 0
end

function SObj.remove_element(x,y,layer)
   if SObj.fields[y] and SObj.fields[y][x] ~= 0 and SObj.fields[y][x][layer] then
      local tmp = SObj.fields[y][x][layer]
      SObj.fields[y][x][layer] = 0
      local stop_rem 
      for k,v in ipairs(SObj.fields[y][x]) do
	 if v ~= 0 then 
	    stop_rem = true
	    break
	 end
      end
      if stop_rem == nil then 
	 SObj.fields[y][x] = 0
      end
      return tmp
   end
   return 0
end

function SObj.make_map(w,h)
   local field = {} 
   local iter = 1
   for iter_y=1,h do
      for iter_x = 1, w do
	 if field[iter_y] == nil then field[iter_y] = {} end
	 field[iter_y][iter_x] = 0
      end
   end     
 
   SObj["fields"] = field
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

      function gm:remove_slot()
	 gm.slot = nil
      end
      if name == "chest" then
	 gm["slot"] = {}

	 function gm:add_item(item)
	    gm["slot"][#gm.slot+1] = item
	 end
      end
      if slot then
	 gm["slot"] = slot
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

      gm:set_position(x,y)      
      
      return gm, layer
   end
   return 0
end

function SObj.load_map(path, stop_iter, folder)
   local field = {}
   local folder = folder or PATH_MAPS

   dofile(folder .. path .. ".3map")

   local input = assert(io.open(folder .. path .. ".2map","rb"))
   local x = HelpFce.bytes_to_num(input:read(1),input:read(1))
   local y = HelpFce.bytes_to_num(input:read(1),input:read(1))
 
   local field2 ={}

   local count = 0
   SObj.fields = {}

   for iter_y=1,y do
      for iter_x = 1, x do
	 if field[iter_y] == nil then field[iter_y] = {} end

	 local read = {}
	 local is = nil
	 for k=1,3 do
	    read[k] = HelpFce.bytes_to_int(input:read(1), input:read(1),input:read(1), input:read(1))
	    if read[k] ~= 0 then
	       is = true
	    end
	 end
	 
	 if is then
	    for k,v in ipairs(read) do
	       if v ~= 0 then
		  local d_obj = _LObjects[v]
		  local obj 
		  if d_obj.type == "static" then
		     obj = SObj.load_object(d_obj.name,iter_x,iter_y,d_obj.slot)
		     SObj.set_element(iter_x,iter_y, obj,k)
		  elseif d_obj.type == "dynamic" then	
		     obj = DObj.load_object(d_obj, iter_x,iter_y, true)
		     if stop_iter then
			obj:stop_iter()
		     end
		  end

	       end
	    end
	 else
	    SObj.set_empty(iter_x,iter_y)
	 end

      end
   end
   input:close()
end


--[[
function SObj.get_element(x,y)
   if SObj.fields[y] then
      return SObj.fields[y][x]
   end
end
]]
local function get_intersect_lines(line1, line2)
   
end


local function check_transparency(v2)
   local line_y = BasicMath.get_position_h2(v2.bound_box.y,v2.bound_box.h,Tiles.tile_size.h)
   local coord = {["x"] = v2.bound_box.x + Map.x,
		  ["y"] = v2.bound_box.y + Map.y,
		  ["w"] = v2.bound_box.w,
		  ["h"] = v2.bound_box.h}

   local offset = 0
   if v2.move_x then
      offset = v2.move_x
   end    
   coord["x"] = coord["x"] + offset
   local result_transparency = BasicMath.get_intersect_rect(coord, Map.get_transparency_box())

   local box = Map.get_transparency_box()
   if Map.y+line_y-(Map.tile_size.h+box[4]) < 
   BasicMath.get_position_h2(box[2],box[4], Map.tile_size.h) then
      result_transparency = nil
   end
   return result_transparency
end


function SObj.make_object_render()
   local machine = get_game_machine()
   local screen_w,screen_h = machine.canvas:get_size()



   local map = SObj.fields

   SObj.last_position = {Tiles.x, Tiles.y}
   local move_y = Tiles.y       

   local x,y = get_start_load_size()
   local w,h = get_end_load_size()
   local n,p = Tiles.tile_to_point(1,h)
   
   local base= Tiles.x-Tiles.tile_size.w
   local base_h = Tiles.y
   local tmp_line = {}
   local copy_line = {}

   Map.line_free()

   for k=y,y+h do
      local tmp = math.floor(Tiles.point_collumn_to_tile(Tiles.x-Tiles.tile_size.w,base_h))

      tmp_line = Tiles.get_line(Tiles.x-Tiles.tile_size.w,base_h, nil,w+tmp,SObj.get_element)
      
      if tmp_line and #tmp_line > 0 then
	 for k,v in ipairs(tmp_line) do
	    v = create_obj_l_c(v)
	    if v then
	       copy_line[#copy_line + 1 ] = v
	    end
	 end
	 Map.insert_line(copy_line, BasicMath.get_position_h2(copy_line[1].bound_box.y,
							      copy_line[1].bound_box.h,
							      Tiles.tile_size.h))
      end
      base_h = base_h + Tiles.tile_size.h/2
      copy_line = {}
   end 
end     

function SObj.set_to_layer(static_objects)
   local machine = get_game_machine()
   local objects = SObj.make_object_render()
   SObj["objects"] = objects

  -- machine:replace_layer(SObj.objects, 2)
end

function SObj.save( path, folder )
   local w, h = Map.size_map[1], Map.size_map[2]
   local size_map = Map.size_map
   local id = 0
   local dump_objs = {}
   local folder = folder or PATH_MAPS
   output = assert(io.open(folder .. path .. ".2map", "wb"))

   output:write(bytes(size_map[1]))
   output:write(bytes(size_map[2]))  

   for y = 1, h do
      for x=1, w do
	 local num = SObj.get_elements(x,y)

	 if num == nil or num == 0 then
	    output:write(write_int(0))
	    output:write(write_int(0))
	    output:write(write_int(0))
	 else
	    for k,v in ipairs(num) do
	       if v == 0 or v[1] == 1  or (type(v) == "table" and v[1] == 1 or v[1] == 0) then
		  if type(v) == "table" and v[1] == 1 then
		     SObj.set_element(x,y,v[2],2)
		  end
		  output:write(write_int(0))
	       else
		  local dump = v:dump()
		  id = id + 1
		  dump_objs[#dump_objs + 1] = dump

		  output:write(write_int(id))

		  if v.render_points then
		     if #v.render_points >= 4 then
			for k,v1 in ipairs(v.render_points) do
			   if (v1.x == x and v1.y ==y) == false				
			   then
			      local tmp = SObj.get_element(v1.x,v1.y,2)
			      SObj.set_element(v1.x,v1.y,{1,tmp},2)
			   end
			end
		     end
		  end
	       end
	    end
	 end      
      end
   end
   output:close()
   
   output = assert(io.open(folder .. path .. ".3map", "w"))
   output:write("_LObjects = {")

   for k,v in ipairs(dump_objs) do
      Serialization.serialize(v,output)   
      output:write(",")
   end

   output:write("}")
   output:close()
end

return SObj