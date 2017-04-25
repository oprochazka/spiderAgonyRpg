dofile(PATH_LIB .. "utils.lua")
dofile(PATH_LIB .. "gui_elements.lua")

 function make_text_button(button_rect, size, text, color, color_text, margin_w, margin_h)
    local f_text = make_element_text(button_rect[1]+margin_w,button_rect[2]+margin_h,
				     size,text,color_text)
    local main_rect = create_rect( x,y,0,0)      
    local button = make_frame_element(button_rect, color)

    local function on_click(self, mouse)
       send_event(self.parrent, "on_click", mouse)
    end
    local function on_mouse_press(self,mouse)
       print("here")
       send_event(self.parrent, "on_press", mouse)
    end    
    
    function button:change_color(color)
        button.sprite:set_color(color[1],color[2],color[3], color[4])
    end

    add_event(f_text, "on_click", on_click)
    add_event(f_text, "on_press", on_mouse_press)
    compose_object(button, f_text )

    return button
 end

function make_cross(path_sprite, x,y)
   local cross = make_button(path_sprite, x,y)
   cross["print"] = function () print("cross") end
   local function on_click(self, mouse)      
      if mouse.release == "left" and intersect_point(self.bound_box,mouse.x,mouse.y) then
	 send_event(self.parrent.parrent,"on_destroy")
      end
   end  

   add_event(cross, "on_click", on_click)
   return cross
end

function make_arrow_up(path_sprite, x, y,fast)
   local arrow = make_button(path_sprite, x,y)
   arrow["print"] = function () print("arrow up") end

   local function on_click(self,mouse)
      if mouse == "left" then
	 send_event(self.parrent, "on_scroll_motion",-fast)
      end
   end
   add_event(arrow, "on_mouse_press", on_click)
   add_event(arrow, "on_motion", on_click)
   return arrow
end

function make_arrow_down(path_sprite, x, y,fast)
   local arrow = make_button(path_sprite, x,y)
   arrow["print"] = function () print("arrow down") end
   local function on_click(self,mouse)
      if mouse == "left" then
	 send_event(self.parrent, "on_scroll_motion",fast)
      end
   end
   add_event(arrow, "on_mouse_press", on_click)
   add_event(arrow, "on_motion", on_click)
   return arrow
end

function make_scroll_button(rect,color)
   local scroll = make_frame_element(rect,color)
   scroll["print"] = function () print("scroll button") end
   scroll["move"]= 
		   function (self, x,y)
		      self.sprite:move(x,y)
		      self.bound_box.x = self.bound_box.x + x
		      self.bound_box.y = self.bound_box.y + y
		   end

   local function on_motion(self, motion)
      send_event(self.parrent, "on_scroll_motion",  motion.y)
   end
   
   add_event(scroll,"on_motion", on_motion)
   return scroll
end

function make_scroll_bar(x,y,w,h, height_scroll,layout)
   local color = _SCROLL_BAR.color
   local scroll_bar = make_empty_frame({x,y,w,h})
   local fast = (1/20*height_scroll)
   local height_scroll = height_scroll
   local scroll_button =  make_scroll_button({x,y+w,w, height_scroll},color)
   local function on_wheel(self, wheel)
      send_event(self,"on_scroll_motion", -fast*wheel)
   end
   local rect


   compose_object(scroll_bar, make_arrow_up(PATH_GUI_IMG .. "arrow_up.png",x,y,fast))
   compose_object(scroll_bar, make_arrow_down(PATH_GUI_IMG .. "arrow_down.png",x,h+y-w,fast))
   compose_object(scroll_bar,scroll_button)
   
   local function on_scroll_motion(self, y2)
      if y2 ~= 0 then

	 local scroll = scroll_button
	 rect = scroll["bound_box"]
	 local bound_box = scroll_bar.bound_box
	 y2 = math.floor(y2+0.5)
	 local send_y = (y2*layout.bound_box["h"])/height_scroll
	 send_y = math.floor(send_y + 0.5)
	 y2 = math.floor(y2)
	 if bound_box["y"] + w > rect["y"]+y2  then
	    y2 = (bound_box["y"] +w) -rect["y"]
	    send_y = 0
	    send_event(layout,"on_min")
	 elseif bound_box["y"]+bound_box["h"]-w < rect["y"]+rect["h"]+y2  then
	    y2 = (bound_box["y"]+bound_box["h"]-w) - (rect["y"]+rect["h"])
	    send_y = 0
	    send_event(layout,"on_max")
	 end     
	 send_event(layout, "on_scroll", {0,-send_y})	 
	 scroll:move(0,y2)      
      end
   end
   local function on_change_height(self, height)
      local scroll = scroll_bar.objects[3]
    
      scroll_button:scale(0, height - scroll.bound_box["h"])
      height_scroll = height
      send_event(self, "on_scroll_motion", 0)
   end
   add_event(scroll_bar, "on_change_height", on_change_height)
   add_event(scroll_bar, "on_click", on_click)
   add_event(scroll_bar, "on_wheel", on_wheel)
   add_event(scroll_bar, "on_scroll_motion", on_scroll_motion)   

   return scroll_bar
end

function make_panel(rect)
   local color = _PANEL.color
   local out =  make_frame_element(rect,color)
   out["print"] = function () print("panel"); end
   out["name"] = "panel"
   local function on_iter(self)
   end

   add_event(out, "on_iter", on_iter)
   add_event(out, "on_click", on_click)
   add_event(out, "on_motion", 
	     function (self, motion) 
		self.parrent:move(motion.x, motion.y) 
	     end
   )
   compose_object(out, make_cross(PATH_GUI_IMG .. "cross.png",rect[1]+ rect[3]-rect[4], rect[2]))
  
   return out
end

function make_frame(rect, layout, layout_button, color)
   local panely = _PANEL.height
   local scroll_width = _SCROLL_BAR.size
   local margin = _FRAME.margin
   local layout = layout
   local height_scroll

   rect[2] = rect[2] - panely
   rect[4] = rect[4] + panely
   local color_frame = color or _FRAME.color
   local width, height = 0, 0
   if layout_button then
      width = layout_button.bound_box["w"] + 2 * margin
      height = layout_button.bound_box["h"] + 2* margin
   end
   if width + scroll_width > rect[3] then rect[3] = width + scroll_width +2*margin end
   if layout then
      if rect[3] < layout.bound_box["w"] + scroll_width then 
	 rect[3] = layout.bound_box["w"] + scroll_width +2* margin
      end

      if rect[4] < layout.bound_box["h"] then 
	 local h_b = (layout_button and layout_button.bound_box["h"]) or 0
	 rect[4] = layout.bound_box["h"]+h_b + margin * 4

      end

      layout:move(rect[1]+margin, rect[2]+margin+panely)
   end
   
   local frame = make_frame_element(create_rect(rect[1],rect[2],
						rect[3],rect[4] + height), color_frame)
  
   frame["layout"] = layout

   local scroll_bar
   local active_object
   local ex_scale = frame["scale"]
   frame["scale"] = function (self, w, h) 
      print(w,h)
      ex_scale(self,w,h)
      self["layout"]:scale(w,h)
      layout_button:scale(w,h)
   end

   local function on_iter(self)

   end

   local function on_destroy(self)
--      send_message_objects(self,"on_destroy", self)
  --    print("DESTROYING FRAME -------------")
      send_event(self.parrent, "on_destroy", self)
   end
   local function on_click(self, mouse)

   end   
   local function loading_scroll(self,layout)
      local y,w,h = panely,panely, rect[4]-panely
      local count = (layout["height"]/layout.bound_box["h"])

      if layout  then	 
	 if count < 1 then count = 1 end      
	 height_scroll = ((y-w + h-w-w) / count)

	 scroll_bar = make_scroll_bar(rect[1]+rect[3]-panely,rect[2]+panely,
				      scroll_width,rect[4]-panely, height_scroll,layout)

	 compose_object(frame, scroll_bar)
	 send_event(layout, "on_min")
      end
   end

   local function on_wheel(self, wheel_y)
      if scroll_bar then
	 send_event(scroll_bar, "on_wheel", wheel_y)
      end
   end
   if layout then
      loading_scroll(frame,layout)
   end
   local function on_input_key(self, key_value)
      if active_object then
	 send_event(active_object, "on_input_key", key_value)
      end
   end
   
   local function on_release_key(self, release_keys)
      if active_object then
	 send_event(active_object, "on_release_key", release_keys)
      end
   end
   local function on_activate(self,object)
      active_object = object
   end
   local function on_change_height(self, obj)
      local layout = obj
      if scroll_bar == nil then loading_scroll(self,layout) end

      local y,w,h = panely,panely, rect[4]-panely
      local count = (layout["height"]/layout.bound_box["h"])
      
      if layout and count > 1 then	 
	 if count < 1 then count = 1 end      
	 height_scroll = ((y-w + h-w-w) / count)
      end
      send_event(scroll_bar, "on_change_height", height_scroll)
   end

   function frame:unbind_panel(same_size)
      for k,v in ipairs(self.objects) do
	 if v.name == "panel" then
	    if same_size == nil then
	       frame.sprite = ERPG_geometry.make_rectangle({frame.bound_box.x, frame.bound_box.y + 20,
							    frame.bound_box.w, frame.bound_box.h - 20},
							   color,1)
	       frame.bound_box.y = frame.bound_box.y + 20
	       frame.bound_box.h = frame.bound_box.h - 20
	    end
	    table.remove(self.objects,k)
	 end
      end
   end
   function frame:unbind_scroll()
      for k,v in ipairs(frame.objects) do
	 if v == scroll_bar then
	    table.remove(frame.objects,k)
	 end
      end
     
   end


   add_event(frame, "on_change_height", on_change_height)
   add_event(frame, "on_iter", on_iter)
   add_event(frame, "on_click", on_click)
   add_event(frame, "on_render", on_render)
   add_event(frame, "on_destroy", on_destroy)
   add_event(frame, "on_wheel", on_wheel)
   add_event(frame, "active_scroll", on_active_scroll)
   add_event(frame, "on_input_key", on_input_key)
   add_event(frame, "on_release_key", on_release_key)
   add_event(frame, "on_activate", on_activate)
   
   compose_object(frame, make_panel({rect[1], rect[2], rect[3],panely}))
 
   if layout then
      frame["layout"] = layout
      compose_object(frame,layout)
   end
   if layout_button then
   --   print(layout_button.bound_box["h"])
      layout_button:move(rect[1] + margin,
			 rect[2] + rect[4] + panely)
      compose_object(frame, layout_button)
   end

   return frame
end

