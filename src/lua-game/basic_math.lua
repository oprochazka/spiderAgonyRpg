local BasicMath = {}

function BasicMath.signum(num)
   if num > 0 then
      return 1
   end
   if num < 0 then 
      return -1
   end
   return 0
end

function BasicMath.get_intersect_lines(line1,line2)
   local x, y
   local mover = line2[2] - line1[1]
   local size_h = (line1[2] + line1[1])


   if line1[1] + line1[2] < line2[1] or line1[1] > line2[1] + line2[2] then
      return nil
   elseif line1[1] > line2[1] then
      if line1[1] > line2[1] + line2[2] then 
	 return nil
      elseif line1[1] + line1[2] < line2[1] + line2[2] then
	 x = 0
	 y = line1[2]
      else
	 x = 0
	 y = (( line2[2] - line2[1]) - line1[1])
      end
   else

      x = line1[2] - (line1[1]+line1[2] - (line2[1]))
      y = line1[2]

   end
   return math.abs(x),math.abs(y)
end

function BasicMath.get_intersect_rect(rect, screen)
   local out = {}

   local x,w= BasicMath.get_intersect_lines({rect.x,rect.w}, {screen[1],screen[3]})
   local y,h= BasicMath.get_intersect_lines({rect.y,rect.h}, {screen[2],screen[4]})
   
   if x and y and w and h then
      return {x,y,w,h}
   end
end

function BasicMath.get_position_h2(y,h,h2)
   local r
   return (h-h2)+y
end

function BasicMath.distance_point(p1, p2)
   return math.sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y - p2.y)*(p1.y - p2.y))
end

function BasicMath.intersectCircle(x, y, sX, sY, r)
   local oX = math.abs(x - sX)
   local oY = math.abs(y - sY) *2

   local result = math.sqrt(oX * oX + oY * oY)

   if result <= r then
      return true, r - result
   else
      return false
   end
end

return BasicMath
