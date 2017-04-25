local format_text_copy = {}

function make_static_text_sprite(str, width, back_color)
   local out ={}
   local nums ={}
   local elements = {}
   local size = 20
   local current
   local fce = function() end
   local w, h
   local key
   local back_color = back_color or {30,30,30,255}
   for key,value in pairs(_FORMAT_TEXT) do
      format_text_copy[key] = value
   end

   str = str .. " "
   str = string.gsub(str,"\n","<n>")
--   "<.->"
   for name, value in string.gmatch(str, "%b<>") do
      current = nil
      local name2 = name
    --  print(name)
      name = name:gsub("%?", "%%?")

      current = string.match(str,"(.-)" .. name)          

      local tmp = current .. name2
      tmp = tmp:gsub("%?", "%%?")
      str = string.gsub(str, tmp, "",1)

      local a = string.sub(name2,2, -2)
      local key = string.match(a, "%a+") 
      a = string.gsub(a, key,"",1)
      a = a .. ","
      a = string.gsub(a, ":", ",", 1)
      for k,v in string.gmatch(a, ",*(.-),") do
	 nums[#nums+1] = k      
      end
      elements[#elements+1] = {current, {key,nums}}
      out[#out+1] = {key, nums}
      nums={}
   end
   if #elements == 0 then elements[1] = {str, nil }
   else
      elements[#elements+1] = {str, nil}
   end
   local element,w,h = find_largest_text(elements, width)
   
   format_text_copy = {}

   return ERPG_sprite.compose_textures({ERPG_geometry.make_rectangle({0,0,width,h}, back_color,1), unpack(element)},width,h)
end
function find_largest_text(elements, width)
   local w,h = 0, 0
   local current_w = 0
   local current_h = 0
   local max_w = 0
   local new_elements = {}
   local space_elem = {}
   local order = 1
   local lines = {{}}
   local job
   local new_element
   local max_h = 0
   local result
   
   for k,v in ipairs(elements) do
      local words = v[1] .. " "

      for k,v in string.gmatch(words, ".-%s") do
	 local current = k .. " "
	 if current ~= "  " and current ~= " "  then
	    w, h = ERPG_text.get_size(format_text_copy.font, current, format_text_copy.size)
	    if w > max_w then
	       max_w = w
	    end
	    if h > max_h then
	       max_h = h
	    end
	    if current_w + w <= width then
	       new_element = ERPG_text.make_text(format_text_copy.font, 
						 current, current_w,
						 current_h,
						 format_text_copy.size,
						 format_text_copy.color) 
	    
	       new_elements[#new_elements + 1] = new_element
	       current_w = current_w + w
	       if max_w < current_w then
		  max_w = current_w
	       end
	    else
	       current_w = 0
	       current_h = current_h + max_h
	       new_element = ERPG_text.make_text(format_text_copy.font, 
						 current, current_w,
						 current_h,
						 format_text_copy.size,
						 format_text_copy.color) 

	       new_elements[#new_elements + 1] = new_element
	       current_w = w
	       max_h = h
	    end
	 end
      end
      if v[2] and v[2][1] then
	 result =  _FORMAT_FUNCTION[v[2][1]](v[2][2],lines)	 
      end
      if result == "next_line" then
	 current_h = current_h + max_h
	 current_w = 0
	 max_h = 0
      end
   end
   
   current_h = current_h + max_h    

   return new_elements,max_w,current_h
end


_FORMAT_FUNCTION = {
   ["color"] = function (nums) if #nums == 3 then nums[4] = 255 end format_text_copy.color = nums   
   end,
   ["size"] = function (size, line) 
        
          format_text_copy.size = size[1] end,
   ["n"] = function (n, line,w, h) return "next_line" end,
   ["sp"] = function (size, line)  _FORMAT_FUNCTION["size"](_FORMAT_TEXT["size"] + size, line) end,
   ["sl"] = function (size, line)  _FORMAT_FUNCTION["size"](_FORMAT_TEXT["size"] - size, line) end,
   ["font"] = function (font, line) format_text_copy.font = font end,
}

function make_static_text(str, width)
   local sprite = make_static_text_sprite(str, width)
   local w,h = sprite:get_max_size()
   local out = {}
   
   out["sprite"] = sprite
   out["bound_box"] = {["x"] = 0, ["y"] = 0, ["w"] = w, ["h"] = h }
   out["move"] = function (self, x ,y)
		    self.sprite:move(x,y)
		    self.bound_box.x = self.bound_box.x + x
		    self.bound_box.y = self.bound_box.y + y		    
   end
   out["print"] = function () print("static text") end
   out["scale"] = function (self,w,h) 
		    self.sprite:scale(w, h)
		    self.bound_box.w = self.bound_box.w + w
		    self.bound_box.h = self.bound_box.h + h
   end
   
   return out
end

function add_format_function(key, func)
   _FORMAT_FUNCTION[key] = func
end