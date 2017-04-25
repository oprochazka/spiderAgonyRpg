BasicMath = require(PATH_GAME .. "basic_math")
Tiles = require( PATH_GAME .. "tiles")
SObj = require( PATH_GAME .. "static_objects")
DObj = require( PATH_GAME .. "dynamic_objects")
Lgt = require( PATH_GAME .. "light")
SO = require( PATH_GAME .. "simple_object")
MpR = require( PATH_GAME .. "map_renderer")
QuadTree = require( PATH_GAME .. "quadtree")

local Map = {}

function get_ids()
   local i = 0

   return function()
      i= i+1
      return i
   end
end

Map.get_id = get_ids()

local function worldIter(i)
 -- if i% 30 == 0 then
   Lgt.mapLight.r = 50
   Lgt.mapLight.g = 50
   Lgt.mapLight.b = 50
 -- end
end

function Map.Initialize_map(screen_map)
   local gm = get_game_machine()
   local screen_w,screen_h = gm.canvas:get_size()

   DObj.Initialize()
   Map["friends"] = {}
   Map["tile_size"] = {["w"] = 64, ["h"] = 32}
   Map["objects_renderer"] = {}
   Map["SObjMaxW"] = 64*2
   Map["SObjMaxH"] = 32*5 + 16
   Map["x"] = 0
   Map["y"] = 0
   Map["screen_map"] = screen_map
   Map["SObjCrop"] = {Map.SObjMaxW*2 + screen_w, Map.SObjMaxH+screen_h}
   Map["position"] = {0,0}
   Map["render_layer"] = nil 
   Map["size_hero"] = {64,64}
   Map["refresh_state"] = nil
   Map["iterator"] = make_element(0,0)

   local iterator = 0

   Map.iterator["name"] = "MAPA"

   local function on_iter(self)
      if iterator %1 == 0 then
--  collectgarbage("collect")
    --    collectgarbage("setstepmul",200)
--  collectgarbage("step", 400)
      end

      if gm.client then 
   --     Client.sendActionsToServer()
     --   Client.recieveActions()
      end
  

      worldIter(iterator)      
      Map.refresh()
      iterator = iterator + 1
   end

   gm:add_event(Map.iterator, "on_iter", on_iter)

   local x = screen_w/2-Map.size_hero[1]
   local y = screen_h/2- (Map.size_hero[2]+Map.tile_size.h)
   local w = Map.size_hero[1]
   local h = Map.size_hero[2] 

   Map["transparency_box"] = {x,y, w, h}

   SObj.create_hash(_OBJECTS_ITEM)

   Tiles.initialize(screen_map)
   MpR.initialize(screen_map)


end

function Map.make_id_object(x,y, static_dynamic_object)

end

function Map.create_hash(objects_by_num, objects_by_id)
   local count, hash = SObj.create_hash(objects_by_num)
   local hash_table = {}
   for k,v in ipairs(objects_by_id) do
      hash_table[#hash_table + 1] = v
   end

   Map["hash_object_num"] = hash
   Map["hash_object_id"] = hash_table
end

function Map.add_id_object(object)
   Map.hash_object_id[#Map.hash_object_id + 1] = object
end

function Map.get_transparency_box()
   return { Map.transparency_box[1] + Map.x, Map.transparency_box[2]+Map.y, 
       Map.transparency_box[3],Map.transparency_box[4]}
end

function Map.hide_walls()
   Map.render_layer = 1
   Map.refresh()
end

function Map.show_walls()
   Map.render_layer = nil
   MpR.make_object_render()
   Map.refresh()
end

function Map.insert_line(line,y)
   local y = y or 0
   local l = {}
   l["line"] = line
   l["y"] = y

   for k,v in ipairs(Map.objects_renderer) do
      if v.y > y then
    table.insert(Map.objects_renderer, k, l)
    return
      elseif v.y == y then
    HelpFce.append(v.line, l.line)
    return
      end      
   end
   Map.objects_renderer[#Map.objects_renderer+1] = l
end
function Map.line_free()
   for k,v in pairs(Map.objects_renderer) do
      for k2,v2 in pairs(v.line) do
    if v2 then
       v2:set_destroy_flag()
    end
      end      
   end
   
   Map["objects_renderer"] = {}
end
function Map.remove_line(y)
  for k, v in pairs(Map.objects_renderer) do
    if v.y == y then   
      for k,v1 in ipairs(v.line) do       
         v1:set_destroy_flag()
      end
      table.remove(Map.objects_renderer, k)
      break
    end
  end
end

function Map.check_transparency(v2)
   local line_y = BasicMath.get_position_h2(v2.bound_box.y,v2.bound_box.h,Tiles.tile_size.h)
   local coord = v2:get_map_bound_box()

   local result_transparency = BasicMath.get_intersect_rect(coord, Map.get_transparency_box())

   local box = Map.get_transparency_box()
   if Map.y+line_y-(Map.tile_size.h+box[4]) < 
   BasicMath.get_position_h2(box[2],box[4], Map.tile_size.h) then
      result_transparency = nil
   end
   return result_transparency
end


local colorTableOut = {["r"] = 0, ["g"] = 0, ["b"] = 0}
local colorBasic = {["r"] = 0, ["g"] = 0, ["b"] = 0}

local function applyRenderGraphicElement(graphic_element, renderObject, render_table,x ,y)
   if graphic_element.sprite then
    local bound_box = graphic_element:get_bound_box()

    local lightElement = MpR.getLightElement(x,y)
    local colorObject = renderObject.color or colorBasic
    local RGBLight
    
    if lightElement then
      RGBLight = Lgt.getRGBLight(lightElement.RGBLight, colorTableOut)

      colorTableOut.r = colorObject.r + RGBLight.r
      colorTableOut.g = colorObject.g + RGBLight.g
      colorTableOut.b = colorObject.b + RGBLight.b

      RGBLight = Lgt.getCorrectRGB(colorTableOut, colorTableOut)

      graphic_element.sprite:set_modulation_color(
          RGBLight.r,
          RGBLight.g,
          RGBLight.b, 1)
    else
      colorTableOut.r = colorObject.r + Lgt.mapLight.r
      colorTableOut.g = colorObject.g + Lgt.mapLight.g
      colorTableOut.b = colorObject.b + Lgt.mapLight.b

      RGBLight = Lgt.getCorrectRGB(colorTableOut, colorTableOut)
      graphic_element.sprite:set_modulation_color(RGBLight.r,RGBLight.g,RGBLight.b,1)
    end

    graphic_element.sprite:set_position(bound_box.x - Map.x, bound_box.y -Map.y)
     
     if graphic_element.transparent then
        graphic_element.sprite:set_alpha(150,1)
        graphic_element.transparent = nil
     else
        graphic_element.sprite:set_alpha(255,1)
     end

    -- render_table[#render_table + 1] = graphic_element.sprite  
     render_table[#render_table + 1] = graphic_element.sprite  
  --        graphic_element.sprite:copy_to_renderer()
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



local function apply_rendering(graphic_element, render_table,x,y)
  local renderObject = graphic_element
  local graphics_elements =  graphic_element.render_objects 

  if graphics_elements == nil then
    applyRenderGraphicElement(graphic_element,renderObject, render_table[2], x, y)
    return
  end

   for k,graphic_element in pairs(graphics_elements) do          
      if graphic_element ~= 0 then
        if graphic_element.render_objects then
           apply_rendering_object(graphic_element, render_table,x,y)
        end
        applyRenderGraphicElement(graphic_element,renderObject, render_table[2], x, y)
      end
   end
end


function Map.get_texture(sprites)
   local cl = os.clock()
   local sprites = sprites or {}
   local result
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()

   Tiles.texture:set_position(Tiles.tile_size.w,Tiles.tile_size.h/2)

   Tiles.texture:set_modulation_color(Lgt.mapLight.r,Lgt.mapLight.g,Lgt.mapLight.b,1)

   local tab = {ERPG_geometry.make_rectangle({0,0,Map.SObjCrop[1],Map.SObjCrop[2]},{0,0,0,255},1),
        Tiles.texture}

   result = ERPG_sprite.compose_textures({tab,sprites[1],sprites[2]} ,Map.SObjCrop[1],Map.SObjCrop[2])
    
   Tiles.texture:set_modulation_color(255,255,255,1)

   result:set_size(Tiles.tile_size.w,Tiles.tile_size.h/2,screen_w,screen_h)

   return result
end
               


function Map.rendering()
  --collectgarbage("setpause",10000)
  local gm = get_game_machine()
  local screen_w,screen_h = gm.canvas:get_size()
  local x = Map.x - Map.SObjMaxW
  local y = Map.y
  local w = Map.x + Map.SObjMaxW + screen_w
  local h = Map.y + Map.SObjMaxH + screen_h

  local t1x, t1y = Tiles.point_to_tile(x,y)
  local t2x, t2y = Tiles.point_to_tile(w,y)
  local t3x, t3y = Tiles.point_to_tile(w,h)
  local t4x, t4y = Tiles.point_to_tile(x,h)
  local timer = ERPG_Utils.get_time()
  local timeTile = 0
  local tile
  local tileLen = 0

  Map.sprites = {{},{},{}}

  Map.friends = {}
  local outTable = {["r"] = 0, ["g"] = 0, ["b"] = 0}
  for y = t1y, t4y do
    for x = t1x, t3x do
      
      local lightElement = MpR.getLightElement(x,y)

      if lightElement then
        if lightElement.tile == nil then
          tile = ERPG_sprite.duplicite(Tiles.test[Tiles.get_element(x,y)])
          lightElement["tile"] = tile
        end 
        tile = lightElement.tile

        lightElement = Lgt.getRGBLight(lightElement.RGBLight, outTable)

        tile:set_modulation_color(lightElement.r,lightElement.g,lightElement.b, 1)
        local xPoint,yPoint = Tiles.getPositionFromTile(x,y)
         
        tile:set_position(xPoint,yPoint)
        
       local test = ERPG_Utils.get_time()
        Map.sprites[1][tileLen + 1] = tile
        timeTile = timeTile + (ERPG_Utils.get_time() - test)
        tileLen = tileLen + 1
      end
     

      local tile;
        --tile= ERPG_sprite.make(PATH_TILES .. "grass3.png")
        --if(type(Tiles.get_element(x,y)) == "number") then
         -- tile = ERPG_sprite.duplicite(Tiles.test[Tiles.get_element(x,y)])
         -- Tiles.fields[y][x] = tile
        --else
         -- tile = Tiles.fields[y][x]
        --end
        --tile:set_position( (x*64 + ((y%2)*32 )) - Map.x ,  y * 16  - Map.y )
  
        --Map.sprites[#Map.sprites + 1] = tile
      local light = nil

      if MpR.fields[y] and MpR.fields[y][x] and MpR.fields[y][x] ~=0 then
        local elem = MpR.get_elements(x,y)
        if elem then
          for k,v in ipairs(elem) do
            if v ~= 0 then
              if  v[1] ~= 0 then
                if v[1] == 1 then
                  MpR.set_element(x,y,v[2],2)
                else          
                  if v.friend_ship_state == "friend" then
                    Map.friends[#Map.friends+1] = v
                  end

                  local tmp  = ERPG_Utils.get_time()
                  apply_rendering(v,Map.sprites,x,y)    
                

                  if v.on_draw then
                     v.on_draw(v,x,y)
                  end
                  if v.render_points then
                    if #v.render_points >= 4 then
                      for k,v1 in ipairs(v.render_points) do
                        if (v1.x == x and v1.y ==y) == false and 
                         (v1.x <= t3x and v1.y <= t4y) and
                         (v1.x >= t1x and v1.y >= t1y)
                        then
                          MpR.set_element(v1.x,v1.y,{1,v},2)
                        end
                      end
                    end
                  end
                    timeTile = timeTile + ERPG_Utils.get_time() - tmp
                end
              end
            end
          end
        end
      end
    end
  end
 -- print(collectgarbage("count")*1024)

  --print("first", timeTile)
  r = Map.get_texture(Map.sprites)
--  print("second", ERPG_Utils.get_time() - timer)
  return r
end


function Map.drawing_callbacks(element,func)
   element["drawing_callback"] = func
end

function Map.load2(path)
   Map.get_id = get_ids()

   collectgarbage("collect")
   Tiles.load_map( path .. ".map")
   MpR.load_map2( path .. ".2map")
--   collectgarbage("setpause")
end

function Map.load(path,stop_iter)
   Map["name"] = path
   Map.get_id = get_ids()
   local w, h = Tiles.load_map( PATH_MAPS .. path .. ".map")
   Tiles.screen_box(0,0)
   print("texture", Tiles.texture)
   Map["size_map"] = {w,h}
   MpR.load_map( path , stop_iter, PATH_MAPS)
 --  Map.render(0,0)
   collectgarbage("collect")


   --collectgarbage("setpause")
end

function Map.generate(x,y, tile)
   local tile = tile or 1

   Map["size_map"] = {x,y}
   Map.get_id = get_ids()

   Tiles.generate_map(x,y, Map.screen_map,tile)
   MpR.make_map(x,y)   
end

function Map.want_refresh()
   Map.refresh_state = true
end

function Map.refresh()  
  local machine = get_game_machine()
  local game_sprite = make_graphic_element()
  local result = Map.rendering()

  if Map.screen_map.sprite then
    Map.screen_map.sprite:unload_texture()      
  end

  Map.screen_map:set_sprite(result)   

  
end

function Map.render(x,y)
   local machine = get_game_machine()

   Map.x = x
   Map.y = y

   Tiles.screen_box(x,y)
end

function Map.move_on_screen(x,y)
   Map.position[1] = Map.position[1] + x
   Map.position[2] = Map.position[2] + y
end

function Map.move(x,y)
   if x == 0 and y == 0 then return end
   local x = x
   local y = y
   Map.x = Map.x + x
   Map.y = Map.y + y

--[[
   if Map.x < 0 or Map.y < 0 then 
      Map.x = 0
      Map.y = 0
      Tiles.screen_box(0,0)
      return 
   end
]]
   local tmp_time = ERPG_Utils.get_time()

   local m_x = Map.x / Tiles.tile_size.w
   local m_y = Map.y / Tiles.tile_size.h
   local t_x = x / Tiles.tile_size.w
   local t_y = y / Tiles.tile_size.h

   if  t_x > 10 or t_x < -10  or t_y > 10 or t_y < -10 then
      Tiles.screen_box(math.floor(m_x)*Tiles.tile_size.w, math.floor(m_y)*Tiles.tile_size.h)

      x = (m_x - math.floor(m_x))*Tiles.tile_size.w
      y = (m_y - math.floor(m_y))* Tiles.tile_size.h

   end
   
   Tiles.move(x,y)  
end

function Map.set_element(x,y,element,layer)
  if layer == 1 then
      Tiles.set_element(x, y, element)
  elseif layer >= 2 then
    if type(element) == "number" then
      local element,layer = SObj.load_object(element,x,y)
      MpR.set_element(x,y,element,layer)
    elseif type(element) == "string" then
      if _BESTIAR[element] then
        local d = Character.make()
        d:setConfiguration(element)
        d:insert(x,y)
        d:stop_iter()
      elseif _NPC[element] then
        local npc = NPC.make()
        npc:setConfiguration(element)
        npc:insert(x,y)
      end   
    end
  end
end
function Map.get_friend_draw()
   return Map.friends
end
function Map.get_element(x,y,layer)
   if layer == 1 then
      return Tiles.get_element(x,y)
   end
   if layer >= 2 then
      return MpR.get_element(x,y,layer-1)
   end
end

function Map.set_dirty_rect(table_sprites, layer)
   Map.screen_map.sprite:set_position(0,0)
   if layer == 1 then
      Tiles.set_dirty_rect(table_sprites)
   elseif layer == 2 then
    
   end
--   Map.refresh()
end
return Map