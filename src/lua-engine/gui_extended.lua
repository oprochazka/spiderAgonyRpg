function make_static_counter_text(text, number)
   local bar_color = {0,0,0,255}
   local txt_color 
   local width = _COUNTER_BAR.name_width
   local height = _COUNTER_BAR.height
   local num_w = _COUNTER_BAR.height
   local margin = _COUNTER_BAR.margin
   local name_bar = make_text_box({0,0,width,height}, text, bar_color)
   local start_number = number or 0
   local num_bar = make_text_box(create_rect(width + margin, 0, num_w ,height),start_number, bar_color)
   local bar = make_empty_frame(create_rect(0,0,width+margin+num_w, height))

   function bar:change_number(num)
      num_bar:change_string(num)
   end

   compose_object(bar, name_bar)
   compose_object(bar, num_bar)
   
   return bar
end

function make_counter_bar(name, start_number,fce_plus,fce_minus)
   local bar
   local function on_click_plus(self, mouse)
      send_event(bar, "on_change_num", 1)
   end
   local function on_click_minus(self, mouse)
      send_event(bar, "on_change_num", -1)
   end
   on_click_minus = fce_minus or on_click_minus
   on_click_plus = fce_plus or on_click_plus
   local bar_color = {0,0,0,255}
   local txt_color 
   local width = _COUNTER_BAR.name_width
   local height = _COUNTER_BAR.height
   local num_w = _COUNTER_BAR.height
   local margin = _COUNTER_BAR.margin
   local name_bar = make_text_box({0,0,width,height}, name, bar_color)
   local start_number = start_number or 0
   local num_bar = make_text_box(create_rect(width + margin, 0, num_w ,height),start_number, bar_color)
   local plus_button = make_button(PATH_GUI_IMG .. "button_plus.png",nil,nil,on_click_plus)
   local minus_button = make_button(PATH_GUI_IMG .. "button_minus.png",nil,nil, on_click_minus)
   local w,h = plus_button.sprite:get_width_height()

   bar = make_empty_frame(create_rect(0,0,width+3*margin+num_w+2*w, height))
   height = _COUNTER_BAR.size_button
   plus_button:scale(-w+height,-h+height)
   minus_button:scale(-w+height, -h+height)
   plus_button:move(width+2*margin+num_w,0)
   minus_button:move(width+3*margin+num_w + _COUNTER_BAR.size_button, 0)
   
   bar["number"] = start_number

   local function on_change_num(self, x)
      local x = x or 0
      bar["number"] = bar["number"] + x
      num_bar:change_string(bar["number"])
   end

   local function on_set_num(self, x)

      local x = x or 0
      bar["number"] = x
      num_bar:change_string(bar["number"])
   end
   
   function bar:remove_plus()
      for k,v in ipairs(bar.objects) do
	 if v == plus_button then
	    table.remove(bar.objects,k)
	    break
	 end
      end
   end
   function bar:remove_minus()
      for k,v in ipairs(bar.objects) do
	 if v == minus_button then
	    table.remove(bar.objects,k)
	    break
	 end
      end
   end
   function bar:add_plus()
      self:remove_plus()
      GUI.compose_object(self,plus_button)
   end
   function bar:add_minus()
      self:remove_minus()
      GUI.compose_object(self,plus_minus)
   end
   function bar:change_num(x)
      bar["number"] = bar["number"] + x
      num_bar:change_string(bar["number"])
   end
   function bar:get_number()
      return  name,self.number
   end
   function bar:set_number(x)
      bar["number"] = x
      num_bar:change_string(bar["number"])
   end
   add_event(bar, "on_change_num", on_change_num)
   add_event(bar, "on_set_num", on_set_num)
   compose_object(bar, name_bar)
   compose_object(bar, num_bar)
   compose_object(bar, plus_button)
   compose_object(bar, minus_button)

   return bar
end
--{{name, start_number, fce-plus, fce-minus}
function make_counter_layout(counters)
   local margin = _LAYOUT_COUNTER.margin
   local height = 0
   local layout = make_empty_frame(create_rect(0,0,0,0))
   local current
   local states = {}
   
   for k,v in ipairs(counters) do      
      current= make_counter_bar(v[1],v[2], v[3], v[4])      
      current:move(0,height)      
      states[#states + 1] = current

      height = height + current.bound_box["h"] + margin
   
      compose_object(layout, current)
   end   
   layout.bound_box["w"] = current.bound_box["w"] + layout.bound_box["w"]
   layout.bound_box["h"] = layout.bound_box["h"] + height
   
   function layout:refresh( nums )
      for k,v in ipairs(self.objects) do
	 GUI.send_event(v, "on_set_num", nums[k])
	-- v:set_number(nums[k])
      end
   end

   function layout:get_stats_numbers()
      local out = {}
      for k,v in ipairs(states) do
	 out[#out + 1 ] = {v:get_number()}
      end
      return out
   end

   return layout
end