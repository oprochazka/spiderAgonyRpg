function create_rect(x,y,w,h)
   return {x,y,w,h}
end

function get_object(object)
   return object["object"]
end

function intersect_point(rect, x,y)   
   if  x >= rect.x and y >= rect.y and x <= rect.x+rect.w and y <= rect.y+rect.h  then    
      return true
   end
   return false
end	

function is_click_button(button, mouse)
   local rect = button:get_position_rect()
   local w, h = button:get_width_height()

   if intersect_point(rect, mouse.x,mouse.y) then
      local pixel = button:get_pixel_color(mouse.x - rect.x, mouse.y -rect.y)
      if(pixel.r ~= 255 or pixel.g ~= 0 or pixel.b ~= 255) then
	 return true
      end
   end
   return false
end

function all_objects(self)
   local list = {}
   if self.objects then
      for k,v in ipairs(self.objects) do
	 list[#list+1] = v
	 if v.objects then
	    local tab = all_objects(v)
	    local size = #list
	    for k,v in ipairs(tab) do list[size + k] = v end 
	 end
      end
   end
   return list
end

function send_message_objects(self,message,args)
   if self.objects then
      for k,v in ipairs(self.objects) do
	 if v.objects then
	    send_message_objects(v,message,args)
	    send_event(v,message,args)
	 end
      end
   end
end


List = {}
function List.new ()
   return {first = 0, last = -1}
end

function List.pushleft (list, value)
   local first = list.first - 1
   list.first = first
   list[first] = value
end

function List.pushright (list, value)
   local last = list.last + 1
   list.last = last
   list[last] = value
end

function List.popleft (list)
   local first = list.first
   if first > list.last then error("list is empty") end
   local value = list[first]
   list[first] = nil        -- to allow garbage collection
   list.first = first + 1
   return value
end

function List.popright (list)
   local last = list.last
   if list.first > last then error("list is empty") end
   local value = list[last]
   list[last] = nil         -- to allow garbage collection
   list.last = last - 1
   return value
end

