Mini_map = {}

function Mini_map.create(fields)
      local shapes = {}
      for y=1, #Tiles.fields do
	 for x=1, #Tiles.fields[1] do
	    local color = Tiles.get_element(x,y)
	    color = Tiles.test[color]:get_pixel_color(32,16)
	    shapes[#shapes+1] = ERPG_geometry.make_rectangle({x,y,1,1},{color.r,color.g,color.b,255},1)
	 end
      end
      return ERPG_sprite.compose_textures(shapes,#Tiles.fields[1],#Tiles.fields)
end

function Mini_map.make()
   local game_machine = get_game_machine()
   local screen_w,screen_h = game_machine.canvas:get_size()
   local gp_elem = GUI.make_empty_frame({0,0,#Tiles.fields[1],#Tiles.fields})

   local cursor_w = screen_w/Tiles.tile_size.w + 2
   local cursor_h = screen_h/(Tiles.tile_size.h/2) + 2
   local cursor = GUI.make_empty_frame({0,0,cursor_w,cursor_h})

   gp_elem["cursor"] = cursor

   gp_elem["sprite"] = Mini_map.create(fields)

   GUI.add_event(gp_elem, "on_motion", function (self, motion) 
		self:move(motion.x, motion.y) 
	     end )

   cursor.sprite = ERPG_geometry.make_empty_rectangle({0,0,
							cursor_w,
							cursor_h}, {0,0,0,255},1)

   GUI.add_event(cursor, "on_iter", function (self) 
		    self:set_position((Tiles.x/Tiles.tile_size.w ),
					     (Tiles.y/(Tiles.tile_size.h/2)))
				    end)
   GUI.add_event(cursor, "on_click", function (self, mouse) 
		    GUI.send_event(self.parrent,"on_click",mouse)
				     end)
   GUI.add_event(gp_elem,"on_click", function (self, mouse)
		    if mouse.release == "right" then
		       self.cursor:set_position((mouse.x - self.bound_box.x ),
						(mouse.y - self.bound_box.y))
		       Map.render((mouse.x - self.bound_box.x )*Tiles.tile_size.w,
					(mouse.y - self.bound_box.y)*(Tiles.tile_size.h/2))
		    end
				     end)
   GUI.compose_object(gp_elem, cursor)
   return gp_elem
end

function Mini_map.set_new(mini_map,fields)
   mini_map["sprite"] = Mini_map.create(fields)
   mini_map.sprite:set_position(mini_map.bound_box.x,mini_map.bound_box.y)
end
   

function Mini_map.refresh(mini_map,x,y, brush_data)
  
   local shape={mini_map.sprite}

   for k=1, #brush_data+1 do
      for x2=1, #brush_data[1]+1 do
	 local color = Tiles.get_element(x+x2,y+k)
	 if color then
	    color = Tiles.test[color]:get_pixel_color(32,16)
	    shape[#shape+1] = ERPG_geometry.make_rectangle({x+x2,y+k,1,1},
							   {color.r,color.g,color.b,255},1)
	 end
	 	 
      end
   end
   local x = mini_map.bound_box.x
   local y = mini_map.bound_box.y

   mini_map:move(-x,-y)
   
   mini_map["sprite"] = ERPG_sprite.compose_textures( shape,#Tiles.fields[1],
						     #Tiles.fields)
   mini_map:move(x,y)
end

return Mini_map