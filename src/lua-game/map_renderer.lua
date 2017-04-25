MpR = {}
MpR["max_h"] = 32*5
MpR["max_w"] = 0

local function get_start_load_size()
   local from_x = math.floor((Tiles.x)/ Tiles.tile_size.w)
   local from_y = math.floor((Tiles.y)/ (Tiles.tile_size.h/2) +1)   
   return from_x,from_y
end

local function get_end_load_size()
   local machine = get_game_machine()
   local screen_w,screen_h = machine.canvas:get_size()
   return math.floor((screen_w)/Tiles.tile_size.w+2 + MpR.max_w/Tiles.tile_size.w),
   math.floor((screen_h)/(Tiles.tile_size.h/2)+1 +2 + MpR.max_h/Tiles.tile_size.h)+4
end

function MpR.initialize(screen_map)   
   local max_w, max_h = get_end_load_size()
   MpR["lightField"] = {}
   MpR["screen_map"] = screen_map  
end

function MpR.set_element(x,y,element,layer)
   if MpR.fields[y] == nil then MpR.fields[y] = {} end

   if layer == nil then
      MpR.fields[y][x] = 0
      return
   end

   if MpR.fields[y] then
      if MpR.fields[y][x] == nil or MpR.fields[y][x] == 0 then
		 MpR.fields[y][x] = {0,0,0}
      end

      MpR.fields[y][x][layer] = element
   end
end

function MpR.set_empty(x,y,layer)
   if MpR.fields[y] == nil then MpR.fields[y] = {} end
   if layer == nil or layer == 0 then
      MpR.fields[y][x] = 0
   else
      MpR.fields[y][x][layer] = 0
   end
end

function MpR.get_elements(x,y)
   if MpR.fields[y] and MpR.fields[y][x] ~= 0 then
      return MpR.fields[y][x]
   end
end
function MpR.get_element(x,y,layer)
   if MpR.fields[y] == nil or MpR.fields[y][x] == nil then
      return 
   end

   if MpR.fields[y] and MpR.fields[y][x] ~= 0 then
      return MpR.fields[y][x][layer]
   end
   return 0
end

function MpR.remove_element(x,y,layer)
   if MpR.fields[y] and MpR.fields[y][x] ~= 0 and MpR.fields[y][x][layer] then
      local tmp = MpR.fields[y][x][layer]
      MpR.fields[y][x][layer] = 0
      local stop_rem 
      for k,v in ipairs(MpR.fields[y][x]) do
		if v ~= 0 then 
			stop_rem = true
			break
		end
      end
      if stop_rem == nil then 
	    MpR.fields[y][x] = 0
      end
      return tmp
   end
   return 0
end

function MpR.removeLightElement(x,y)
	MpR.lightField[y][x] = nil
end

function MpR.setLightElement(x,y, element)
	if MpR.lightField[y] ~= nil then
		MpR.lightField[y][x] = element
	end
end
function MpR.getLightElement(x,y)
	if MpR.lightField[y] ~= nil then
		return MpR.lightField[y][x]
	end
end

function MpR.make_map(w,h)
   local field = {} 
   local lightField = {}
   local iter = 1

   for iter_y=1,h do
      for iter_x = 1, w do
	 	if field[iter_y] == nil then field[iter_y] = {} end
	 	if lightField[iter_y] == nil then lightField[iter_y] = {} end

	 		field[iter_y][iter_x] = 0
	 		lightField[iter_y][iter_x] = nil
      end
   end     
 
   MpR["fields"] = field
   MpR["lightField"] = lightField
end

function MpR.load_map(path, stop_iter, folder)
   local field = {}
   local folder = folder or PATH_MAPS
   local gm = get_game_machine()  
   dofile(folder .. path .. ".3map")

   local input = assert(io.open(folder .. path .. ".2map","rb"))
   local x = HelpFce.bytes_to_num(input:read(1),input:read(1))
   local y = HelpFce.bytes_to_num(input:read(1),input:read(1)) 


   local field2 ={}
   local sizeOfLayers = 3
   local count = 0

   MpR.fields = {}

   for iter_y=1,y do
      for iter_x = 1, x do
         if field[iter_y] == nil then field[iter_y] = {} end

         if MpR.lightField[iter_y] == nil then MpR.lightField[iter_y] = {} end
	 		MpR.lightField[iter_y][iter_x] = nil

         local read = {}
         local is = nil
         for k=1,sizeOfLayers do
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
                  MpR.set_element(iter_x,iter_y, obj,k)
               elseif d_obj.type == "dynamic" then	
                  if gm.client == nil then
                     obj = DObj.load_object(d_obj, iter_x,iter_y, true)
                     if stop_iter then
                        obj:stop_iter()
                     end
                  end
               elseif d_obj.type == "SimpleObject" then
                  local obj = SO.make()
                  obj:load(d_obj)
               end
            end
         end
         else
            MpR.set_empty(iter_x,iter_y)
         end
      end
   end
   input:close()
end

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


function MpR.make_object_render()
   local machine = get_game_machine()
   local screen_w,screen_h = machine.canvas:get_size()
   local map = MpR.fields

   MpR.last_position = {Tiles.x, Tiles.y}
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

      tmp_line = Tiles.get_line(Tiles.x-Tiles.tile_size.w,base_h, nil,w+tmp,MpR.get_element)
      
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

function MpR.set_to_layer(static_objects)
   local machine = get_game_machine()
   local objects = MpR.make_object_render()
   MpR["objects"] = objects

  -- machine:replace_layer(SObj.objects, 2)
end

function MpR.save( path, folder )
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
         local num = MpR.get_elements(x,y)

         if num == nil or num == 0 then
            output:write(write_int(0))
            output:write(write_int(0))
            output:write(write_int(0))
	      else
            for k,v in ipairs(num) do
               if v == 0 or v[1] == 1  or (type(v) == "table" and v[1] == 1 or v[1] == 0) then
                  if type(v) == "table" and v[1] == 1 then
                     MpR.set_element(x,y,v[2],2)
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
      			            if (v1.x == x and v1.y ==y) == false then
      			               local tmp = MpR.get_element(v1.x,v1.y,2)
      			               MpR.set_element(v1.x,v1.y,{1,tmp},2)
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

return MpR