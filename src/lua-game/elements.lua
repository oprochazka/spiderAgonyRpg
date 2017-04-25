function make_light_element(sprite)   
   local element = {
      ["name"] = "light element",
      ["sprite"] = sprite
   }
   return element
end

function make_element(x,y,w,h)
   local element = {
      ["name"] = "element",
      ["bound_box"] = {["x"]=x, ["y"] = y, ["w"] = w, ["h"] = h },
      ["callbacks_iter"] = nil,
      ["callbacks_destroy"] = nil,
      ["callbacks"] = {},
      ["move"] = function (self,x,y) 
   	 self.bound_box["x"] = x + self.bound_box["x"]
   	 self.bound_box["y"] = y + self.bound_box["y"]
      end,
      ["set_position"] = function (self,x,y) 
   	 self.bound_box["x"] = x
   	 self.bound_box["y"] = y
      end,
      ["scale"] = function (self,w,h) 
   	 self.bound_box["w"] = w + self.bound_box["w"]
   	 self.bound_box["h"] = h + self.bound_box["h"]
      end,
      ["set_size"] = function (self, w,h)
   	 self.bound_box["w"] = w
   	 self.bound_box["h"] = h	 
      end,
      ["set_destroy_flag"] = function (self)
	      self["destroy"] = true
      end,
      ["get_bound_box"] = function (self)
	  local move_x = self.move_x or 0
	 
	   return self.bound_box
      end,
      ["get_map_bound_box"] = function (self)
	 local move_x = self.move_x or 0


	 return {["x"] = self.bound_box.x + Map.x + move_x, 
		 ["y"] = self.bound_box.y + Map.y,
		 ["w"] = self.bound_box.w, 
		 ["h"] = self.bound_box.h
	 }
      end	 
   }

   return element
end

function make_graphic_element(w,h)
   local w = w or 0
   local h = h or 0
   local element = make_element(0,0,w,h)
   
   element["render"] = true
   element["sprite"] = nil
   element["sound"] = nil
   element["name"] = "graphic_element"

   function element.set_sprite(self, sprite)
      self["sprite"] = sprite

      if element.bound_box.w == 0 and element.bound_box.h == 0 then
   	 local tmp = self.sprite:get_size()
   	 local c_x, c_y = self.sprite:get_count_clips()

   	 local w, h = (tmp["w"])/c_x, (tmp["h"])/c_y

   	 if self.bound_box.x == nil then 
   	    self.bound_box.x = 0
   	    self.bound_box.y = 0 
   	 end
	     self:set_size(w,h)
      end
   end

   function element.render_off(self)
      self["render"] = nil
   end

   function element.render_on(self)
      self["render"] = true
   end

   function element.set_sound(self, sound, repl)
      self["sound"] = {repl, sound}
   end
   
   return element
end

function make_texture_elements(graphic_element_list, buffer_box, draw_box)   
   local elements = {}
   local element = {}
   local game_machine = get_game_machine()
   element["sprites"] = {}

   for y=1, buffer_box.h do
      for x = 1, buffer_box.w do
	 if elements[y] == nil then
	    elements[y] = {}
	 end
	 elements[x][y] = graphic_element[x+((y-1)*w)]
      end
   end

   function elements:replace_first_line(graphic_element_list)
      elements[1] = graphic_element_list
   end
   function elements:replace_last_line(graphic_element_list)
      elements[buffer_box.h] = graphic_element_list
   end
   function element:replace_first_collumn(graphic_element_list)
      for k,v in ipairs(elements) do
	 elements[1] = graphic_element_list(k)
      end
   end
   function element:replace_last_collumn(graphic_element_list)
      for k,v in ipairs(elements) do
	 elements[buffer_box.w] = graphic_element_list(k)
      end
   end

   function element:move_draw_box(x,y)

   end
   return element
end

