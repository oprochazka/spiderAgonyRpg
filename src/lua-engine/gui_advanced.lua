dofile(PATH_LIB .. "gui_config.lua")

function make_standart_text_button(text,fce_on_click,size)
   local x_in_w = 0
   local y_in_h = 0
   local button_size = {_BUTTON.w,_BUTTON.h}
   local color_b = _BUTTON.button_color
   local color_t = _BUTTON.text_color
   local size = size or _BUTTON.text_size
   local font = _BUTTON.font
   local txt_size = ERPG_text.get_size(font, text, size)
   local margin_w = _BUTTON.margin.x
   local margin_h = _BUTTON.margin.y
   local focus_color = _BUTTON.focus_color
   if button_size[1] < txt_size + 2*margin_w then button_size[1] = txt_size + 2*margin_w end
   local button = make_text_button(create_rect(0,0,
					       button_size[1], button_size[2]), size,text,
				   color_b, color_t,
				   margin_w, margin_h)

   local function on_mouse_press(self,mouse)
      if mouse.on_press ~= "none" then
	 button:change_color(focus_color)
      end
   end

   local function on_click(self, mouse)
      button:change_color(color_b)
      if mouse.release == "left" and intersect_point(self.bound_box,mouse.x,mouse.y) then
	 button:change_color(color_b)
	 if fce_on_click then
	    fce_on_click(self,mouse)
	 end

      end
   end
   
   local function on_destroy(self)   
      button:change_color(color_b)
   end

   add_event(button, "on_click", on_click)
   add_event(button, "on_press", on_mouse_press)
   add_event(button,"on_destroy",on_destroy)
   return button
end

function make_text_box(rect, text, color)
   local font = _TEXT.font
   local size = _TEXT_BOX.text_size
   local text_color = _TEXT_BOX.text_color 
   local font = _TEXT_BOX.font
   local w,h = ERPG_text.get_size(font,text,size)
   local txt = make_element_text(rect[1]+_TEXT_BOX.margin[1],rect[2]+rect[4]/2 - h/2, 
				 size, text, text_color, font)
   local color_back = color or _TEXT_BOX.frame_color
   local frame = make_frame_element(rect, color_back)

   frame["change_string"] = function (self, str) txt:change_string(str) end

   local function on_click(self, mouse)
      send_event(self.parrent, "on_click", mouse)
   end
   add_event(txt, "on_click", on_click)

   compose_object(frame,txt)

   return frame
end

function make_check_box(text, start_state, func_on, func_off,x,y)
   local x = x or 0
   local y = y or 0
   local font = _CHECK_BOX.font
   local font_size = _CHECK_BOX.text_size
   local w = _CHECK_BOX.size
   local h = _CHECK_BOX.size
   local on_margin = _CHECK_BOX["on_margin"]
   local margin = _CHECK_BOX.margin
   local text_color = _CHECK_BOX.text_color
   local text_w, text_h = ERPG_text.get_size(font, text, font_size)
   local box_color = _CHECK_BOX.box_color
   local box_on_color = _CHECK_BOX.box_on_color
   local frame = make_frame_element({text_w + x+margin,y,w,h},box_color)
   local text_elem = make_element_text(x,y,font_size,text,text_color)
   local in_frame =  make_frame_element(create_rect(text_w + x+margin+on_margin,y+on_margin,
						    w-on_margin*2,h-on_margin*2),
					    box_color)
   local last_state = start_state
   local function on_click_in(self, mouse)
      send_event(self.parrent, "on_click", mouse)
   end
   
   frame["print"] = function () print("check_box") end


   local function loading()
      if start_state then
	 frame["apply"]= func_on
	 in_frame.sprite:set_color(box_on_color[1],box_on_color[2],box_on_color[3],box_on_color[4])
      else
	 frame["apply"] = func_off
      end
   end
   
   local function nothing() end

   local function on_click(self, mouse)	
      if mouse.release == "left" then
	 if frame["apply"]  == func_on then
	    in_frame.sprite:set_color(box_color[1],box_color[2],box_color[3],box_color[4])	    
	    frame["apply"] = func_off
	    if last_state then
	       frame["func"] = func_off
	       last_state = nil
	    else
	       frame["func"] = nil
	    end
	 else	  
	    frame["apply"] = func_on
	    in_frame.sprite:set_color(box_on_color[1],box_on_color[2],box_on_color[3],box_on_color[4])
	    if last_state then
	       frame["func"] = nil
	    else
	       frame["func"] = func_on
	       last_state = true
	    end
	 end     	 
      end
   end

   loading()

   local function on_destroy ()
      if frame["func"] then
	 if last_state then
	    last_state = false
	 else
	    last_state = true
	 end	 	
      end
      frame["func"] = nil
   end

   add_event(frame, "on_click", on_click)
   add_event(in_frame,"on_click", on_click_in)
   add_event(frame, "on_destroy", on_destroy)

   compose_object(frame, text_elem)
   compose_object(frame,in_frame)   
   return frame
end

function make_combo_box(w, table_text_info,x,y)
   local x = x or 0
   local y = y or 0
   local color = _COMBO_BOX.color
   local font = _COMBO_BOX.font
   local focus_color = _COMBO_BOX.focus_color
   local background_color = _COMBO_BOX.background
   local font_size = 20
   local margin = 10
   local frame = make_frame_element(create_rect(x,y, 2*margin+w,2*margin), background_color)
   local max_w = 0
   local tmp,h = 0, 0
   local max_h = 0
   local function on_click_but(self, mouse)
      if mouse.release == "left" then	 
	 self.sprite:set_color(focus_color[1],focus_color[2],focus_color[3],focus_color[4])
	 send_event(frame, "on_click_but", self)
      end
   end
   local function loading()
      frame["print"] = function () print("combo box") end

      for k,tab in ipairs(table_text_info) do
	 max_h = max_h + h
	 local text = tab[1]
	 local x,y= x+margin, y+margin+max_h
	 tmp,h = ERPG_text.get_size(font, text, font_size)
	 local obj = make_text_box(create_rect(x,y,w,h), text, color)
	 
	 obj["apply"] = tab[2]
	 obj["info"] = tab[2]

	 frame.sprite:scale(0,h)
	 frame.bound_box["h"] = frame.bound_box["h"] +h 
	 compose_object(frame, obj)
	 
	 add_event(obj, "on_click", on_click_but)
      end 
   end
   local function on_click_in(self, sender)
      if self.last_sender and self.last_sender ~= sender then 
	 self.last_sender.sprite:set_color(color[1], color[2], color[3],color[4]); 
      end
      
      --self["info"] = sender.apply
      self["apply"] = sender.apply
      self["last_sender"] = sender      
   end
   function frame:get_focus_info()
      if self.last_sender then
	 return self.last_sender.info
      end
   end   

   loading()

   add_event(frame, "on_click_but", on_click_in)

   return frame
end

function render_off(self)
   self["render_off"] = 1
end
function render_on(self)
   self["render_off"] = nil
end


function make_cursor(rect, color)
   local swaping = 1
   local cursor = make_frame_element(rect, color)
   local last = 0

   local function on_iter(self)
  
      if swaping % 20 >= 10 then
	 cursor["sprite"]:set_color(0,0,0,0)
	 swaping = swaping + 1
      else
	 cursor["sprite"]:set_color(color[1],color[2],color[3],color[4])
	 swaping = swaping + 1
      end

   end
   add_event(cursor, "on_iter", on_iter)
   return cursor
end
function make_input_box(width,input_txt) 
   local txt_size = _INPUT_BOX.text_size
   local tmp_str = ""
   local color = _INPUT_BOX.frame_color
   local margin = _INPUT_BOX.margin
   local input_txt = input_txt or ""
   local color_text = _INPUT_BOX.text_color
   local cursor_color = _INPUT_BOX.cursor_color
   local rect = create_rect(0,0, width+2*margin, txt_size + 2 * margin)
   local frame = make_frame_element(rect, color)
   local text_elem = make_element_text(margin, margin,txt_size,input_txt, color_text)
   local str = input_txt
   local cursor = make_cursor(create_rect(margin,margin,2,txt_size + margin), cursor_color)
   local h = 0
   local font = _INPUT_BOX.font
   local char_c = 0
   local cursor_pozition = 0
   local current_key
   local size = 0
   local w = 0
   local key_bind = {
		     ["Backspace"] = function ()
			if frame.string ~= "" then
			   str = utf8removeLast(str, 1)
			   w = ERPG_text.get_size( font,str, txt_size)
			   cursor:move(w - size,0)		
			   size = w
			   frame["string"] = str
			end
			return end		
		    }
		     
   local function on_press_key(self, press_key)
   end
   
   local function on_click(self, mouse)
      send_event(self.parrent, "on_activate", self)
   end
   w = ERPG_text.get_size( font,str, txt_size)
   size = w
   cursor:move(w, 0)
   local function on_input_key(self, press_key)     
      local char = press_key
      w = ERPG_text.get_size(font,str .. char, txt_size)
      if w < width then	
	 cursor:move(w-size,0)
	 str = str .. char
	 text_elem:change_string(str)
	 size = w
	 frame["string"] = str
      end
   end

   local function on_release_key(self, release_key)
      func = key_bind[release_key[1]]
      if func then func() text_elem:change_string(str) end

      GUI.send_event(frame.parrent,"on_release_key", release_key)
   end
   
   function frame:set_empty()
      frame.string = ""
      str = ""
      text_elem:change_string(str)

      w = ERPG_text.get_size(font,str, txt_size)
      cursor:move(w-size,0)            
      size = w       
   end
   
   function frame:set_text(txt)
      if txt == "" then frame:set_empty() return end
      frame.string = txt
      str = txt
      text_elem:change_string(str)

      w = ERPG_text.get_size(font,str, txt_size)
      
      cursor:move(w-size,0)            
      size = w       
   end

   function frame:get_text()
     return self.string
   end

   frame["string"] = str
   frame["name"] = "input_box"

   add_event(frame, "on_press_key", on_press_key)
   add_event(frame, "on_input_key", on_input_key)
   add_event(frame, "on_release_key", on_release_key)
   add_event(frame, "on_click", on_click)
   compose_object(frame, text_elem)
   compose_object(frame, cursor)
   return frame
end

function make_layout(object_list, clip_rect, margin)
   local width,height = 0, 0
   local list = {}
   local margin = margin or _LAYOUT.margin
   local x,y,w,h = clip_rect[1], clip_rect[2], clip_rect[3], clip_rect[4]
   local layout = make_empty_frame(create_rect(0,0,w,h))
   width = w
   local function all_sprites(object_list, func)
	 for k,v in ipairs(object_list) do 
	    if v.print then
	    end
	    if func then
	       func(v)
	    end
	    if v.objects then

	       all_sprites(v.objects,func)	       
	    end
	 end
   end
 
  local function loading()
     local counter_y = 0
     layout["scroll"] = {["x"] = 0, ["y"] = 0}
     layout["bound_box"] = {["x"] = x,["y"]=y,["w"]=w,["h"]=h}
     layout["print"] = function () print("layout") end     
      height = -margin
      for key,value in ipairs(object_list) do
	 if value.bound_box["x"] + value.bound_box["w"] > width then 
	    width = value.bound_box["x"] + value.bound_box["w"] 
	 end
	 value:move(x,height+margin+y)

	 value["default_y"] = height+margin

	 height = height + value.bound_box["h"] +margin
      end     
      layout["height"] = height
      local function on_click(self)
	 print("here")
      end
   --   layout["position"] = layout.bound_box["y"]
    
  end

   local function on_scroll (self, tab)
	 local x,y = tab[1], tab[2]

	 for key, value in ipairs(self.objects) do 
	    value:move(x,y) 	    
	 end
	 all_sprites(self.objects, 
		     function (v)
			if v["sprite"] then
			   local rect = v["sprite"]:get_size()		

			   local bottom = (v.bound_box["y"] + v.bound_box["h"]) -
			      (self.bound_box["y"] + self.bound_box["h"])

			   local top = self.bound_box["y"] - v.bound_box["y"]
	
			   if bottom > v.bound_box["h"]  or top >= v.bound_box["h"] then 	   
			      render_off(v)
			   else 
			      if bottom > 0  and 
			      top > 0  then
				 
				 local w, h = v["sprite"]:get_size()
				 v["sprite"]:set_size(rect["x"], top, rect["w"], 
						      self.bound_box.h)
				 local x,y = v["sprite"]:get_position()
				 v["sprite"]:set_position(x, v.bound_box["y"] + top)
				 render_on(v)
			      elseif bottom > 0  then
				 if bottom >= v.bound_box["h"] then bottom = v.bound_box["h"] end
				 v["sprite"]:set_position(v.bound_box["x"], v.bound_box["y"])
				 v["sprite"]:set_size(0,0,rect["w"], 
						      v.bound_box["h"]-bottom)
				 render_on(v)
			      elseif top > 1 then		
				 if top <= 0 then top = 0 end
				 local x,y = v["sprite"]:get_position()
				 v["sprite"]:set_position(x, v.bound_box["y"] + top)
				 v["sprite"]:set_size(rect["x"], top, 
						      rect["w"], v.bound_box["h"]-top)
				 	 render_on(v)
			      else 
				 local rect = v["sprite"]:get_size()

				 v["sprite"]:set_size(0,0,v.bound_box["w"], v.bound_box["h"])
				 v["sprite"]:set_position(v.bound_box["x"],v.bound_box["y"])
				 render_on(v)
			      end
			     
			   end
			end
		     end)
   end
   
   local function on_min(self)
      if layout.height > layout.bound_box.h then
	 for key,v in ipairs(self.objects) do 
	    v:move(0,layout.bound_box["y"] - v.bound_box["y"]+v["default_y"])
	 end
	 send_event(layout,"on_scroll",{0,0})
      end
   end
   local function on_max(self)
      local layout = self
      if layout.height > layout.bound_box.h then
	 local max = 0
	 local obj = self.objects[1]
	 for key,v in ipairs(self.objects) do
	    if v.default_y > max then max = v.default_y; obj = v end
	 end
	 for key,v in ipairs(self.objects) do 
	    v:move(0, ((layout.bound_box["y"] +layout["height"])
			  - (max+obj.bound_box["y"]+obj.bound_box["h"]))+ 
		      (layout.bound_box.h - (obj.bound_box.h)))

	 end
	 send_event(layout,"on_scroll",{0,0})
      end
   end


   loading()
   layout.bound_box["w"] = width
   print(layout.bound_box["w"])

   local function on_activate(self, object)
      if self.parrent then
	 send_event(self.parrent, "on_activate", object)
      end
   end
   
   layout["add_object"] =  function (self, object)
      local tmp = self.height
      object["default_y"] = self.height +margin
      self["height"] = margin + object.bound_box["h"] + self["height"]
      object:move(self.bound_box.x, tmp+self.bound_box.y + margin)
      compose_object(layout, object)
      send_event(self, "on_scroll", {0,0})    
      send_event(self.parrent,"on_change_height", self)
      
   end

   function layout:change(objects)
      self.objects = {}
      self.height = 0
      
      for k,object in ipairs(objects) do
	 local tmp = self.height
	 object["default_y"] = self.height +margin
	 self["height"] = margin + object.bound_box["h"] + self["height"]
	 object:move(self.bound_box.x, tmp+self.bound_box.y + margin)
	 compose_object(layout, object)	 
      end      
      send_event(self, "on_scroll", {0,0})    
      send_event(self.parrent,"on_change_height", self)
   end

   function layout:remove_last_object()      
      local obj = self.objects[#self.objects]

      table.remove(self.objects,#self.objects)

      self.height = self.height - (obj.bound_box.h + margin)
      send_event(self,"on_scroll", {0,0})
      send_event(self.parrent, "on_change_height",self)
   end

   add_event(layout,"on_max", on_max)
   add_event(layout,"on_min", on_min)
   add_event(layout,"on_scroll", on_scroll)
   add_event(layout,"on_click", on_click)
   add_event(layout, "on_activate", on_activate)
   for k,v in ipairs(object_list) do
      compose_object(layout, v)
   end
   on_scroll(layout,{0,0})
--   send_event(layout,"on_scroll",{0,0})
   return layout
end

function make_message_box(text, apply_fce)
   local SCREEN = ERPG_window.get_desktop_resolution()
   local size_txt = _MESSAGE_BOX.text_size
   local margin = _DEFAULT.marginx
   local button_size = {_BUTTON.w,_BUTTON.h}
   local rect = _MESSAGE_BOX.rect
   local msg_box
   local font = _MESSAGE_BOX.font
   if rect == nil then 
      local w,h = ERPG_text.get_size(font, text, size_txt)
      w = w+2*margin
      h = h+3*margin + button_size[2]
      if w < button_size[1]*2 + 3*margin then
	w = button_size[1]*2 + 3*margin	
      end
      rect = create_rect(SCREEN.width/2 -w/2 
			 , SCREEN.height/2 - h,w, h)
   end
   local color_txt =_TEXT.color
   local txt = make_element_text(rect[1]+margin,rect[2] + margin, size_txt, text, color_txt)
   local button_layout
   if apply_fce then
      button_layout = make_layout_buttons{{"Ano", apply_fce}, 
						{"Ne", function ()send_event(msg_box, "on_destroy") end}}
   else
      button_layout = make_layout_buttons{
					  {"Ok", function ()send_event(msg_box, "on_destroy") end}}      
   end
   msg_box = make_frame(rect, nil, button_layout)

   compose_object(msg_box, txt)
   return msg_box
end

function make_input_frame(text, height,txt_input,apply_fce, action_button_name)
   local SCREEN = ERPG_window.get_desktop_resolution()
   local size_txt = _MESSAGE_BOX.text_size
   local margin = _DEFAULT.marginx
   local button_size = {_BUTTON.w,_BUTTON.h}
   local rect = _MESSAGE_BOX.rect
   local msg_box
   local font = _MESSAGE_BOX.font   
   local color_txt =_TEXT.color
   local inp_txt = make_input_box(200,txt_input) 
   local txt = make_element_text(0,0, size_txt, text, color_txt)
   local layout = make_layout({txt,inp_txt},{0,0,200,height})
   local action_button_name = action_button_name or "Ok"

   local function aplicate(self)
      apply_fce(inp_txt:get_text())
      send_event(self.parrent, "on_destroy",self)
   end


   local button_layout = make_layout_buttons({{action_button_name, aplicate}, 		     
					      {"Cancle", 
					       function (self)
						  print("CANCLE")
						  send_event(self.parrent, "on_destroy",self) end}})

   msg_box = make_frame({0,0, 200,height},layout, button_layout)

   GUI.send_event(msg_box,"on_activate", inp_txt)   

   msg_box:move(0,20)
   return msg_box
end

--table button = {{"name", fce}..}
function make_layout_buttons(table_button)
   local w = _BUTTON.w
   local h = _BUTTON.h
   local count = #table_button
   local margin = _LAYOUT.margin
   local b_margin = _BUTTON.margin.y
   local tmp = 0
   local layout = make_empty_frame(create_rect(0,0,0, h + 2*b_margin))

   for key,value in ipairs(table_button) do
      local button = make_standart_text_button(value[1],value[2]) 
      w = button.bound_box["w"]
      button:move(tmp, 0)
      tmp = tmp + margin + w
      layout.bound_box["w"] = layout.bound_box["w"] + tmp
      compose_object(layout, button)
   end

   local function on_destroy(self,sender)
     for k,v in ipairs(self.objects) do
	 send_event(v, "on_destroy",self)
     end            
     
     send_event(self.parrent,
		"on_destroy",self)
   end
   
   add_event(layout,"on_destroy", on_destroy)

   return layout
end

function make_file_browser(path, func_ok)
   local files = ERPG_Utils.get_files_dir(path)
   local file = {}
   local n = 0
   local in_use = {}
   for k,v in ipairs(files) do
      if v == "." or v == ".." then
	 n = n + 1
      else
	 v =  string.match(v,"%w+")
	 if in_use[v] == nil then
	    in_use[v] = true
	    file[k-n] = {v, v}
	 else
	    n = n+1
	 end
      end
   end
   local comb = make_combo_box(400, file)

   local function on_okey(self,mouse)
      if func_ok then
	 func_ok(comb:get_focus_info())
      end
      send_event(self.parrent,"on_destroy",self)
   end


   local layout = make_layout({comb}, {0,0,400,300}, 5)
   local buttons = make_layout_buttons({{"Ok",on_okey}, {"Cancle", function (self,mouse)
							send_event(self.parrent,
								   "on_destroy",self)
							       end}})


   local frame = make_frame({0,0,0,0}, layout,buttons)
   frame:move(0,_PANEL.height)
   return frame
end