
local Brush = {}

function Brush.create_brush(data, info, make_sprite_fce)
--   local path = data_brush.path
   local path = info
   local data = data
   local w = #data[1]
   local h = #data
   local sp
   local max_w = (Tiles.tile_size.w*w)
   local max_h = (Tiles.tile_size.h/2)*(h+1)
   local sprites = {ERPG_geometry.make_rectangle({0,0,max_w+(Tiles.tile_size.w/2),max_h},{0,0,0,0},1)}

   local brush = make_graphic_element(0,0)
   
   for y = 2, h+1 do
      if y%2 == 1 then
	 front = w-1
      else
	 front = w
      end

      for k=1, w do
	 if data[y-1][k] ~= 0 then
	    local x,y = Tiles.tile_to_point(k,y)
	    local sprite 

	    if make_sprite_fce then
	       sprite = make_sprite_fce(info)
	    else
	       sprite = ERPG_sprite.make(path,{ 255,0,255,255})
	    end

	    sprites[#sprites + 1] = sprite

	    sprites[#sprites]:move(x,y - (Tiles.tile_size.h/2))
	 end
      end
   end   

   return ERPG_sprite.compose_textures(sprites,max_w+(Tiles.tile_size.w/2), max_h)
end

function Brush.write_data(brush_data,path, first_tile, layer)
   local first = first_tile[2] % 2
   local sprites = {}
   for k, v in ipairs(brush_data) do
      for k1,v1 in ipairs(v) do
	 if brush_data[k][k1] ~= 0 then
	    local x1, x2 = first_tile[1] + (first * ((k+1)%2))+(k1-1), first_tile[2] + (k-1)
	    if Map.get_element(x1,x2,layer) then
	       Map.set_element(x1, x2, path,layer)
	       
	       if layer == 1 then
		  local x,y = Tiles.tile_to_point(x1,x2)
		  print(x1, x2, path, layer)
		  local sp = ERPG_sprite.make(path, 
					      { 255,0,255,255})
		  sp:move((x - Tiles.x) - Tiles.progress_x - Tiles.tile_size.w, 
			  (y - Tiles.y) - Tiles.progress_y -Tiles.tile_size.h)
		  
		  sprites[#sprites + 1 ] = sp
		  
		  HelpFce.fast_garbage(sp)
	       else

	       end
	    end
	 end
      end
   end
   Map.set_dirty_rect(sprites,layer)
end

function Brush.make(list)
   local function on_click(self)
      GUI.send_event(self.parrent, "on_change_brush", self:get_focus_info())
   end

   local brush_frame = ToolBar.make(on_click)  


   for k,v in ipairs(list) do
      brush_frame:add_item(ToolBar.make_item(v.path,v.data))
   end

   return brush_frame

end

return Brush