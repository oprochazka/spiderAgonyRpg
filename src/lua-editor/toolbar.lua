local ToolBar = {}

function ToolBar.make_item(path,info)
   local info = info or path
   local out = GUI.make_sprite(path)
   out["info"] = info
   out["name"] = "toolbar_field"
   return out
end

function ToolBar.make_item_sprite(sprite, info)
   local out = GUI.make_element_with_sprite(sprite)
   
   out["info"] = info
   out["name"] = "toolbar_field"

   return out
end

function ToolBar.field_make(size_x,size_y, on_click_focus)
   local margin = 5
   local focus_color = {50,0,30,255}
   local un_focus_color = {30,30,30,255}
   local back_frame = GUI.make_frame_element({margin,margin, size_x, size_y}, 
					     {15,15,15,255})
   local focus_frame = GUI.make_frame_element({0,0, size_x+margin*2, size_y+margin*2},un_focus_color)

   local function on_click(self, mouse)
      GUI.send_event(self.parrent,"on_click", mouse)
   end

   function focus_frame:set_sprite(sprite_element)
      sprite_element:set_position(back_frame.bound_box.x,back_frame.bound_box.y)

      focus_frame["info"] = sprite_element.info

      GUI.add_event(sprite_element,"on_click", function (self,mouse)
		       GUI.send_event(self.parrent,"on_click", mouse) end)
      
      GUI.compose_object(focus_frame, sprite_element)
   end

   function focus_frame:un_focus()
      self:set_color(un_focus_color)
   end	 
   function focus_frame:focus()
      self:set_color(focus_color)
   end	 

   local function on_click_f(self, mouse)
      self.parrent.focus_field = self
      GUI.send_event(self.parrent,"on_click_field",self)

      if on_click_focus then
	 on_click_focus(self,mouse)
      end
   end


   GUI.add_event(back_frame,"on_click", on_click)
   GUI.compose_object(focus_frame, back_frame)
   GUI.add_event(focus_frame,"on_click",on_click_f)  

   return focus_frame
end

function ToolBar.make( toolbar_func )
   local margin = 5
   local color = {13,8,70,255}
   local empty = 30
   local bar = GUI.make_frame_element({0,0,2*margin,2*margin + empty},color)
   local max = 10
   local size_w = 0
   bar["focus_field"] = nil
   bar["fields"] = {}

   local function on_click(self,child)
      for k, v in ipairs(bar.fields) do
	 v:un_focus()
      end     
      child:focus()

      if toolbar_func then
	 toolbar_func(self)
      end
   end

   function bar:set_item(item)
      if position <= count then
	 palet_frame.fields[position]:set_sprite(item)
	 position = position + 1	 
      end
   end
   
   function bar:get_focus_info()
      if bar.focus_field then
	 return bar.focus_field.info
      end
   end
   
   function bar:add_item(item, on_click_field)
      local tmp = (#bar.fields + 1)/ max
      local on_click_field = on_click_field or 
	 function (self, mouse)
	    GUI.send_event(self.parrent, "on_click", mouse)
	 end

      local field = ToolBar.field_make(64,32,on_click_field)

      if tmp > size_w then
	 bar:scale(field.bound_box.w+margin, 0)
	 size_w = size_w + 1
      end

      GUI.compose_object(bar, field)
      local len = #bar.fields % max
      local position = (margin*len) + (len  * field.bound_box.h)

      field:set_position(margin+(size_w - 1)*(field.bound_box.w+margin),
			 position)
      if tmp <= 1 then
	 bar:scale(0, field.bound_box.h+margin)       
      end


      bar.fields[#bar.fields+ 1] = field

     
      field:set_sprite(item)
   end

   GUI.add_event(bar, "on_motion", 
	     function (self, motion) 
		bar:move(motion.x, motion.y) 
	     end
   )
   GUI.add_event(bar, "on_click_field", on_click)
  return bar
end


return ToolBar