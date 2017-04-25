local Tiles = {}

function Tiles.initialize(screen_map)
   local tile_size = {["w"] = 64, ["h"]=32}

   Tiles["tile_size"] = tile_size
   Tiles["test"] = {}
   Tiles["find_tile"] = {}

   local screen_map = screen_map or Tiles.screen_map
   local path = PATH_TILES .. "texture1.png"

   for k,v in ipairs(_PALET_ITEM) do
      Tiles.test[k] = ERPG_sprite.make(v[1], {255,0,255,255})
      Tiles.find_tile[v[1]] = k
   end

   Tiles["screen_map"] = screen_map
   Tiles["progress_x"] = 0
   Tiles["progress_y"] = 0

   return tiles
end

function Tiles.is_through_tile(x,y)
   local n = Tiles.get_element(x,y)
   if n then
      local d = _PALET_ITEM[n][2]
        return d
   else
      return 0
   end
end

function Tiles.generate_map(x,y, screen_map, n_tile)
   Tiles.initialize(screen_map)

   local field = {}
 
   for iter_y=1,y do
      for iter_x = 1, x do
	 if field[iter_y] == nil then field[iter_y] = {} end

	     field[iter_y][iter_x] = n_tile
      end
   end

   Tiles["x"] = 0
   Tiles["y"] = 0

   Tiles["fields"] = field
end

function Tiles.load_map(path,screen_map)
   Tiles.initialize(screen_map)

   local field = {}

   local input = assert(io.open(path,"rb"))
   local x = HelpFce.bytes_to_num(input:read(1),input:read(1))
   local y = HelpFce.bytes_to_num(input:read(1),input:read(1))

   for iter_y=1,y do
      for iter_x = 1, x do
	 if field[iter_y] == nil then field[iter_y] = {} end
	 local read = string.byte(input:read(1))

	 if Tiles.test[read] then
	    field[iter_y][iter_x] = read
	 else
	    field[iter_y][iter_x] = 1
	 end
      end
   end
   input:close()

   Tiles["x"] = 0
   Tiles["y"] = 0
   Tiles["fields"] = field

   return x, y
end

function Tiles.get_crop_screen()
   local screen_w, screen_h = machine.canvas:get_size() 
   return {Tiles.tile_size.w, Tiles.tile_size.h, screen_w, screen_h}
end

function Tiles.get_position_map()
   return Tiles.x + Tiles.progress_x, Tiles.y + Tiles.progress_y
end

function Tiles.get_element(x,y)
   if Tiles.fields[y] then
      return Tiles.fields[y][x]
   end
end

function Tiles.getPositionFromTile(x,y, x1, y1)
  local x1 = x1 or Map.x
  local y1 = y1 or Map.y
  local xPoint,yPoint = Tiles.tile_to_point(x,y)
         
  return xPoint-x1, yPoint-y1-Tiles.tile_size.h/2
end

function Tiles.set_element(x,y, path_sprite)
   local num = Tiles.find_tile[path_sprite]
   if Tiles.get_element(x,y) then
      if num then
	       Tiles.fields[y][x] = Tiles.find_tile[path_sprite]
      else
	       Tiles.fields[y][x] = Tiles.find_tile[1]
	       print("Tile not registred: " .. path_sprite)
      end
   end
end
function Tiles.get_move_y(y)
   return ((y+1) % 2) * Tiles.tile_size.h/2
end

function Tiles.get_move_x(y)
   return (y % 2) * Tiles.tile_size.w/2
end

function Tiles.point_line_to_tile(y)
   if y == 0 then return 1 end
   local result = (y / (Tiles.tile_size.h/2))+ 1

   if math.floor(result) ~= result then 
      return result
   end

   return result 
end

function Tiles.tile_to_point(x,y)
   local point_y = (y-1)*(Tiles.tile_size.h/2)
   local point_x = (x-1)*(Tiles.tile_size.w)+Tiles.get_move_x(y)

   return point_x, point_y
end

function Tiles.point_collumn_to_tile(x,y)
   if x == 0 then return 1 end
   
   local x = x 

   local result = (x / Tiles.tile_size.w ) + 1
 
   if result ~= math.floor(result) then 
      return result,true
   end

   return result
end

function Tiles.point_to_tile(x,y)
   return math.floor(Tiles.point_collumn_to_tile(x,y)), math.floor(Tiles.point_line_to_tile(y))
end

function Tiles.get_up(x,y)
   return x,y-2
end
function Tiles.get_down(x,y)
   return x,y+2   
end
function Tiles.get_left(x,y)
   return x-1,y
end
function Tiles.get_right(x,y)
   return x+1,y
end
function Tiles.get_up_right(x,y)
   local x_p,y_p = Tiles.tile_to_point(x,y)
   return Tiles.point_to_tile(x_p+Tiles.tile_size.w/2,y_p-Tiles.tile_size.h/2)
end
function Tiles.get_up_left(x,y)
   local x_p,y_p = Tiles.tile_to_point(x,y)
   return Tiles.point_to_tile(x_p-Tiles.tile_size.w/2,y_p-Tiles.tile_size.h/2)   
end
function Tiles.get_down_left(x,y)
   local x_p,y_p = Tiles.tile_to_point(x,y)
   return Tiles.point_to_tile(x_p-Tiles.tile_size.w/2,y_p+Tiles.tile_size.h/2)   
end
function Tiles.get_down_right(x,y)
   local x_p,y_p = Tiles.tile_to_point(x,y)
   return Tiles.point_to_tile(x_p+Tiles.tile_size.w/2,y_p+Tiles.tile_size.h/2)   
end

function Tiles.get_line(x,y, w_start, w_fin, fce_get_elem_tbl)  
   local machine = get_game_machine()
   local screen_w, screen_h = machine.canvas:get_size() 
   local line = Tiles.point_line_to_tile(y)
   local first = w_start or math.floor(Tiles.point_collumn_to_tile(x,y))
   local last = w_fin or math.floor(Tiles.point_collumn_to_tile(x + screen_w+(Tiles.tile_size.w), y)+0.5) - line%2
   local sprite
   local tiles = {}
   local it = 1

   for i = first, last  do
      local element = {}
      local x, y = Tiles.tile_to_point(i, line)

      element["value"] = fce_get_elem_tbl(i,line)
      element["x"] = x-Tiles.x
      element["y"] = y-Tiles.y
      element["position"] = it

      if element.value and element.value ~= 0 then 
	 tiles[#tiles+1] = element
      else 
	 element.value = 5
	 tiles[#tiles+1] = element
      end

      it = it + 1
   end

   return tiles
end

function Tiles.get_collumn(x,y,h_start,h_fin, fce_get_elem_tbl)
  local machine = get_game_machine()
  local screen_w, screen_h = machine.canvas:get_size() 
  local collumn,what = Tiles.point_collumn_to_tile(x)
  local first = h_start or math.floor(Tiles.point_line_to_tile(y))
  local last = h_fin or math.floor(Tiles.point_line_to_tile(y+screen_h + (Tiles.tile_size.h))+ 0.5)
  local add = 1
  local tiles = {}

  collumn = math.floor(collumn)
  if what then add = 0 end 
  local add2 = 0
  local kr = 0
  local it = 1
  if Tiles.y % Tiles.tile_size.h ~= 0 then
     add2 = Tiles.tile_size.h/2
     kr = 1
  end

  for i = first+add-kr, last+1,2 do 
     local element = {}
     local move_x,move_y = Tiles.tile_to_point(collumn, i)
     
     element["value"] = fce_get_elem_tbl(collumn,i)
     element["x"] = move_x-Tiles.x
     element["y"] = move_y-Tiles.y
     element["position"] = it

     if element.value and element.value ~= 0 then
	tiles[#tiles+1] = element     
     else 
	element.value = 5
	tiles[#tiles+1] = element
     end
     it = it + 1
  end
   
  return tiles
end

local function create_line_coll(elem)
   local sprite = ERPG_sprite.duplicite(Tiles.test[elem.value])
   sprite:move(elem.x, elem.y)
   HelpFce.fast_garbage(sprite)
   return sprite
end

function Tiles.screen_box(x,y)
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()
   local max_w, max_h = screen_w + (Tiles.tile_size.w*2), screen_h + (Tiles.tile_size.h * 2)
   local lines = {}
   local lines_sprite = {}
   local sprite = {ERPG_geometry.make_rectangle({0,0,max_w,max_h},{0,0,0,255},1)}
   Tiles.x = x
   Tiles.y = y 
   Tiles.progress_x = 0
   Tiles.progress_y = 0
   local element

   for i = y, y+max_h-Tiles.tile_size.h,Tiles.tile_size.h/2 do
      local line = Tiles.get_line(x, i,nil,nil, Tiles.get_element)
      for k,e in pairs(line)  do
	 sprite[#sprite+1] = create_line_coll(e)
      end
   end
   tmp = Tiles.texture
   
   Tiles["texture"] = ERPG_sprite.compose_textures(sprite, max_w, max_h)
   if tmp then
      tmp:unload_texture()
   end

   Tiles.texture:set_size(Tiles.tile_size.w,Tiles.tile_size.h,screen_w,screen_h)
end

function Tiles.move_y(y)
  local game_machine = get_game_machine()
  local screen_w, screen_h = game_machine.canvas:get_size()
  local max_w, max_h = screen_w + (Tiles.tile_size.w*2), screen_h + (Tiles.tile_size.h * 2)
  local lines = {}
  local lines_sprite = {}
  local sprite = {ERPG_geometry.make_rectangle({0,0,max_w,max_h},{0,0,0,255},1), Tiles.texture}
  Tiles.y = Tiles.y + y
  local w,h = Tiles.texture:get_max_size()
  local move_y = Tiles.y

  Tiles.texture:set_size(0,0,w,h)

  Tiles.texture:set_position(0,0)
  Tiles.texture:move(0,-y)

  if y > 0 then move_y = Tiles.y + screen_h+Tiles.tile_size.h end

  local line = Tiles.get_line(Tiles.x,move_y,nil,nil, Tiles.get_element)

  for k,e in pairs(line)  do  
     sprite[#sprite+1] = create_line_coll(e)
  end

  HelpFce.fast_garbage(Tiles.texture)
  tmp = Tiles.texture
  Tiles["texture"] = ERPG_sprite.compose_textures(sprite,max_w,max_h)
  
  tmp:unload_texture()
end

function Tiles.move_x(x)
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()
   local max_w, max_h = screen_w + (Tiles.tile_size.w*2), screen_h + (Tiles.tile_size.h * 2)
   local lines = {}
   local lines_sprite = {}
   local sprite = {ERPG_geometry.make_rectangle({0,0,max_w,max_h},{0,0,0,255},1), Tiles.texture} 
   local move_x 
   Tiles.x = Tiles.x + x

   local w,h = Tiles.texture:get_max_size()
   Tiles.texture:set_size(0,0,w,h)

   Tiles.texture:set_position(0,0)
   Tiles.texture:move(-x,0)

   move_x = Tiles.x     

   if x > 0 then move_x = Tiles.x + screen_w + Tiles.tile_size.w end
   
   local collumn = Tiles.get_collumn(move_x, Tiles.y,nil,nil, Tiles.get_element)

   for k,e in pairs(collumn) do
      sprite[#sprite+1] = create_line_coll(e)
   end
   HelpFce.fast_garbage(Tiles.texture)

   tmp = Tiles.texture
   Tiles["texture"] = ERPG_sprite.compose_textures(sprite,max_w,max_h)
   tmp:unload_texture()
end

function Tiles.sign(n)
   if n >= 0 then
      return 1
   else
      return -1
   end
end

function Tiles.move_prev(x,y)
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()
   local max_w, max_h = screen_w + (Tiles.tile_size.w*2), screen_h + (Tiles.tile_size.h * 2)
   local x_size, y_size = Tiles.tile_size.w/2, Tiles.tile_size.h/2
   local w_size,h_size = screen_w, screen_h
   Tiles["progress_x"] = Tiles.progress_x + x
   Tiles["progress_y"] = Tiles.progress_y + y
   Tiles.texture:set_position(0,0)
   Tiles.texture:set_alpha(255,1)

   if Tiles.progress_x < x_size and Tiles.progress_x > -(x_size) then
      x_size = Tiles.tile_size.w +Tiles.progress_x
   else
      local tmp = math.abs(Tiles.progress_x) - (Tiles.tile_size.w/2)

      Tiles.move_x(Tiles.tile_size.w/2 * Tiles.sign(Tiles.progress_x))
      Tiles.progress_x = tmp * Tiles.sign(Tiles.progress_x) 	 

      x_size = Tiles.tile_size.w + Tiles.progress_x
   end
   

   if Tiles.progress_y < y_size and Tiles.progress_y > -y_size then
      y_size = Tiles.tile_size.h + Tiles.progress_y
   else
      local tmp = math.abs(Tiles.progress_y) - (Tiles.tile_size.h/2)

      Tiles.move_y(Tiles.tile_size.h/2 * Tiles.sign(Tiles.progress_y))
      Tiles.progress_y = tmp * Tiles.sign(Tiles.progress_y)

      y_size = Tiles.tile_size.h + Tiles.progress_y
   end
  
   
   if x~= 0 or y ~= 0 then      
      Tiles.texture:set_size(x_size,y_size,screen_w,screen_h)
 --     collectgarbage("collect")
   end
end

function Tiles.move(x,y)
   local x_count = math.floor(math.abs(x)/(Tiles.tile_size.w/2))
   local y_count = math.floor(math.abs(y)/(Tiles.tile_size.h/2))
   local x_rest = math.abs(x) % (Tiles.tile_size.w/2)
   local y_rest = math.abs(y) % (Tiles.tile_size.h/2)

   while x_count > 0 or y_count > 0 do
      if x_count > 0 and y_count > 0 then
	 Tiles.move_prev((Tiles.tile_size.w/2)*Tiles.sign(x), (Tiles.tile_size.h/2)*Tiles.sign(y))
	 x_count = x_count - 1
	 y_count = y_count - 1      
      elseif x_count > 0 then
	 Tiles.move_prev((Tiles.tile_size.w/2)*Tiles.sign(x), 0)
	 x_count = x_count - 1
      elseif y_count > 0 then
	 Tiles.move_prev(0, (Tiles.tile_size.h/2)*Tiles.sign(y))
	 y_count = y_count - 1
      end
   end

   Tiles.move_prev(x_rest * Tiles.sign(x),y_rest*Tiles.sign(y))

end

local function get_five_tiles(x,y)
   local y_a = math.floor(y/(Tiles.tile_size.h/2))+1
   local x_a = math.floor((x - Tiles.get_move_x(y_a)) / Tiles.tile_size.w)+1

   local add = (y_a + 1) % 2
   local add2 = (add+1) % 2

   return {{x_a, y_a}, {x_a - add,y_a-1}, {x_a - add, y_a + 1}, 
	   {x_a+add2, y_a -1}, {x_a + add2, y_a + 1}}
end

local function intersect_tile(x,y,point_x,point_y)
   local tmp_x,tmp_y = Tiles.tile_to_point(x,y)

   local norm_x = point_x - tmp_x
   local norm_y =  (Tiles.tile_size.h/2) -  (point_y - tmp_y)

   local p1 = norm_x - (2 * norm_y)
   local p2 = -norm_x - (2 * norm_y) + Tiles.tile_size.w
   local p3 = -norm_x + (2 * norm_y) + Tiles.tile_size.w
   local p4 = norm_x + (2 * norm_y)

   if p1 >= 0 and p2 >= 0 and p3 >= 0 and p4 >= 0 then     
      return true
   end

   return false
end

function Tiles.get_position_tile_point(x,y)
   local pos_x, pos_y = Map.screen_map.bound_box.x, Map.screen_map.bound_box.y
   local x = x+Tiles.x+Tiles.tile_size.w + Tiles.progress_x - pos_x
   local y = y + Tiles.y + Tiles.tile_size.h + Tiles.progress_y - pos_y

   local fives = get_five_tiles(x,y)
   
   for k,v in ipairs(fives) do
      if intersect_tile(v[1],v[2], x,y) then
	 return v
      end
   end      
end

function Tiles.set_dirty_rect(table_sprites)
   local comp_sprite ={}
   local w,h = Tiles.texture:get_max_size()
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()

   Tiles.texture:set_size(0,0,w,h)
   Tiles.texture:set_position(0,0)
   
   comp_sprite[1] = Tiles.texture
   for k,v in ipairs(table_sprites) do
--      v:move(Tiles.tile_size.w-Tiles.screen_map.bound_box.x+Tiles.progress_x,
--	     Tiles.tile_size.h-Tiles.screen_map.bound_box.y+Tiles.progress_y)
      v:move(Tiles.tile_size.w+Tiles.progress_x,
	     Tiles.tile_size.h+Tiles.progress_y)

      comp_sprite[#comp_sprite+1] = v
   end
   
   HelpFce.fast_garbage(Tiles.texture)
   local tmp = Tiles.texture
   Tiles.texture = ERPG_sprite.compose_textures(comp_sprite, w,h)	     
   if tmp then
      tmp:unload_texture()
   end
   Tiles.texture:set_size(Tiles.tile_size.w+Tiles.progress_x,
			  Tiles.tile_size.h+Tiles.progress_y,screen_w,screen_h)
 --  Tiles.screen_map:set_sprite(Tiles.texture)

   
end

return Tiles
