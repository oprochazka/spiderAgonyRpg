local AI = {}

local hash2 = {"right","down","left","up","up_right","down_right",
	       "down_left", "up_left"}
local hash_opposite = {"left","up","right","down","down_left","up_left",
	       "up_right", "down_right"}
local hash3 = {"up", "left", "down", "right","up_right", "up_left", "down_left", "down_right"}

function AI.random_inteligence(self) 
   local r = math.random(2)
   if r == 1 then
      local tmp = hash3[math.random(8)]
      self:fight(600,tmp)           
   else
      self[hash2[math.random(8)]](self,math.random(1)) 
   end
end

function AI.smart_inteligence(self)
   local enemy = Map.get_friend_draw()
   local n = #enemy

 --  if n == 0 then return end
   local hero = UserUI.connectedHero
   if self:is_flags_null() == nil then return end
   if hero == nil then  return end

  -- local x = math.random(n)
   local enemy = hero
   
   local last_point = enemy.render_points[1]
   local x,y = Tiles.tile_to_point(last_point.x, last_point.y)
   last_point = self.last_point[1]
   local x1,y1 = Tiles.tile_to_point(last_point.x, last_point.y)

   if BasicMath.distance_point({["x"] = x, ["y"] = y}, {["x"] = x1, ["y"] = y1}) > 800 then
      return 
   end

   if enemy.health <= 0 then 
      self:move("move_" .. hash2[math.random(#hash2)]) return 
   end

   local side = ""
   local side2 = ""
   local str = ""

   if x > x1 then
      side = "right"
   elseif x < x1 then
      side = "left"
   end
   
   if y > y1 then
      side2 = str .. "down"
   elseif y < y1 then
      side2 = str .. "up"
   end
   
   local t_x = last_point.x - enemy.render_points[1].x
   local t_y = last_point.y - enemy.render_points[1].y 

   if side ~= "" and side2 ~= "" then
      str = side2 .. "_" .. side
   else
      str = side2 .. side
   end

   local tmp = _Fight_one[str]
   local fight
   for k,v2 in ipairs(self.last_point) do
      local last_point_x = v2.x
      local last_point_y = v2.y   

      for k,v in ipairs(tmp) do
	 local x,y = Tiles["get_" .. v](last_point_x, last_point_y)
	 last_point_x = x
	 last_point_y = y

	 local elems = MpR.get_elements(last_point_x, last_point_y)
	 elems = elems or  {}

	 for k,v in ipairs(elems) do
	    if type(v) == "table"  then
	       if v[1] == 1 or v[1] == 0 then
		  v = v[2] 
	       end
	       if v.name == "hero" then
		  fight = true
	       end
	    end
	 end
      end
   end   

   if fight then
      self:fight(str)
   else
      local opposite = ""
      if self.ai_last_move then
	 for k,v in ipairs(hash2) do
	    if v == self.ai_last_move then
	       opposite = hash_opposite[k]
	    end
	 end
      end

      local result 
      if str ~= opposite then
         result = self:move("move_" .. str)         
      end
      if result == nil and side ~= "" and  side ~= opposite then
         result = self:move("move_" .. side)
         
         self.ai_last_move = nil
      end
      if result == nil and side2 ~= "" and  side2 ~= opposite then
        result = self:move("move_" .. side2)
   	 self.ai_last_move = nil
      end
      if result == nil then
	 if self.ai_last_move then
      result = self:move("move_" .. self.ai_last_move)
	 end
	 if result == nil then
	    for k,v in ipairs(hash2) do
          result = self:move("move_" .. v)	       
	       if result then 
		  self.ai_last_move = v 
		  break
	       end
	    end
	 end
      end
   end  
end

return AI