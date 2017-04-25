local HelpFce = {}

function HelpFce.fast_garbage(e)
   local tmp = e
   local meta=getmetatable(tmp)
   meta.__mode = "v"
end

function HelpFce.append(t1, t2)
   for k,v in ipairs(t2) do
      t1[#t1+1] = v
   end
   return t1
end
function HelpFce.bytes_to_num(x1,x2)
   return string.byte(x1)*256^1+string.byte(x2)*256^0
end	

function HelpFce.bytes_to_int(x1,x2,x3,x4)
   return string.byte(x1)*256^3+string.byte(x2)*256^2+string.byte(x3)*256^1+string.byte(x4)*256^0
end

function HelpFce.is_click_none_transparent(sprite,rect, x,y)
   if (x and y ) == nil then return end

   local w, h = rect.w, rect.h

   if GUI.intersect_point(rect, x,y) then

      local pixel = sprite:get_pixel_color(x - rect.x, y -rect.y)
      if(pixel.r ~= 255 or pixel.g ~= 0 or pixel.b ~= 255) then
	 return true
      end
   end
   return false
end

return HelpFce