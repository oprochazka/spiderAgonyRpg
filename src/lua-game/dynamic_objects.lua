local DObj = {}

DObj.ObjectsList = {}

function DObj.remove_element(id)
   for k,v in ipairs(DObj.ObjectsList) do
      if v:getId() == id then
         table.remove(DObj.ObjectsList,k)
      end
   end
end

function DObj.get_element(id)
 for k,v in ipairs(DObj.ObjectsList) do

      if v:getId() == tonumber(id) then

         return v
      end
   end
end

DObj.convert_moveStr_moveInt = {
   ["down_left"] = 2,
   ["left"] = 3,
   ["up_left"] = 4,
   ["up"] = 5,
   ["up_right"] = 6,
   ["right"] = 7,
   ["down_right"] = 8,
   ["down"] = 1
}

function DObj.Initialize(screen_map)
   DObj["objects"] = {}
end

function DObj.get_y_line(obj)
   local b_x = obj:get_bound_box()
   local r =(b_x.y + b_x.h) - Tiles.tile_size.h

   return r
end

local function is_through(elems,self)
   if self.through then return true end
   local res = true 
   local self = self or {}
   if elems then
      for k,v in ipairs(elems) do
	 if v ~= 0 then	  
	    if v ~= self and v.through == nil 
	    then	
	       if type(v[1]) == "nubmer" and v[2].through ~= nil then
		  return true
	       end
	       res = nil
	       return nil
	    end
	 end
      end
   end
   return true
end

local function move_last_points(self, x,y)
   local tab = {}
   
   local d_x = x - self.last_point[1].x
   local d_y = y - self.last_point[1].y
   
   local new_x = self.last_point[1].x + d_x
   local new_y = self.last_point[1].y + d_y

   local newPointX,newPointY = Tiles.tile_to_point(new_x,new_y)
   local lastPointX,lastPointY = Tiles.tile_to_point(self.last_point[1].x,self.last_point[1].y)
   local standartPointX,standartPointY = newPointX-lastPointX, newPointY-lastPointY

   for k,val in ipairs(self.last_point) do
      tab[#tab +1] = {}
      
      local valuePointX, valuePointY = Tiles.tile_to_point(val.x,val.y)

      tab[#tab]["x"],tab[#tab]["y"] = Tiles.point_to_tile(valuePointX+standartPointX,valuePointY+standartPointY)
   end
   return tab
end

local function in_move_want(self, args)
   self["want_move"] = args
end

local function is_move_want(self, args)
   return self.want_move
end

local function set_null_move_want(self)
   self["want_move"] = nil
end

local function help_move(self,speed, x,y, side)
   local gm = get_game_machine()
   local p_x = x + self.last_point[1].x
   local p_y = 2*y + self.last_point[1].y

   local tab = move_last_points(self, p_x, p_y)
   local r = true

   for k,v in ipairs(tab) do
      local elems = MpR.get_elements(v.x,v.y)
      r = is_through(elems,self)
      
      if Tiles.is_through_tile(v.x,v.y) == 1 then
	      r = nil
      end

      if r == nil then break end
   end

   if self.through then r = true end

   local sp = math.floor(Tiles.tile_size.w / (speed*2))
   
   if r then
      local move_args = {{2*x,y},sp,tab, side, 
				     ["pixel_time"] = speed, ["last_time"] = gm:get_time(), 
				     ["pixel_count"] = 0}

      if self:is_event("on_move") then 
         self:send_event("on_move", move_args )
      else
         in_move_want(self, move_args)
      end
      return true
   end
end
local function help_move2(self, speed,x,y, side)
   local gm = get_game_machine()
   local t_x,t_y = Tiles.tile_to_point(self.last_point[1].x,self.last_point[1].y)

   t_x = t_x +  x * Tiles.tile_size.w/2
   t_y = t_y + y * Tiles.tile_size.h/2
   
   local t1_x, t1_y = Tiles.point_to_tile(t_x,t_y)
   local tab = move_last_points(self,t1_x,t1_y)

   local r = true
   for k,v in ipairs(tab) do
      local elems = MpR.get_elements(v.x,v.y)
      r = is_through(elems,self)

      if Tiles.is_through_tile(v.x,v.y) == 1 then
         r = nil
      end

      if r == nil then break end
   end

   if self.through then r = true end
   local sp = math.floor((Tiles.tile_size.w/2)/ (speed*2))
   local elems = elems or {}

   if r then
      local move_args = {{2*x, y}, sp, tab,side,
				  ["pixel_time"] = speed, ["last_time"] = gm:get_time(), 
				  ["pixel_count"] = 0}
      
      if self:is_event("on_move") then 
         self:send_event("on_move", move_args )
      else
         in_move_want(self, move_args)
      end
      return true
   end      
end

local function on_fight(self,side, args)
   local tmp = _Fight_one[side]
   local defenders = {}
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
      	       if v.on_defense and defenders[v] == nil and v ~= self then
                  v:on_defense(self, args)	    
                  defenders[v] = true
      	       end
      	    end
      	 end
      end
   end   

   self.flags.fight = nil
end

local function on_spell(self, side, args)
   local gm = get_game_machine()
   local x, y = Tiles["get_" .. side](self.last_point[1].x, self.last_point[1].y)
   
   local spell = Spells.make("fireball", side,x,y, self,self.name)  

   if gm.server then
      ServerChars.setDobj(spell)
   end

   spell:castSpell("fireball",side,x,y,self,self.name)
end



local function on_move(self,args)
   local vector_x,vector_y = args[1][1],args[1][2]
   local t1_x, t1_y = args[3][1].x,args[3][1].y
   self.flags["move"] = args
   self.animation.frame_time = 60

   if vector_y > 0 then
      for k,v in ipairs(self.last_point) do
	     MpR.set_element(v.x, v.y, {0,self},self.layer)
      end
      for k,v in ipairs(args[3]) do
	     MpR.set_element(v.x,v.y,self,self.layer)
      end	

      self.render_points = args[3]
   else
      for k,v in ipairs(args[3]) do
         MpR.set_element(v.x,v.y,{0,self},self.layer)
      end
      for k,v in ipairs(self.last_point) do
         MpR.set_element(v.x, v.y,self,self.layer)
      end
      self.render_points = self.last_point
      --	 MpR.set_element(t1_x,t1_y,{0,self},2)
   end
   
   local i,side,key = self.model:get_current_frame()
   local side = self.last_side
  
   if key ~= "move" or side ~= args[4] then
      self:set_animation("move",i,args[4])
   end

   --self.last_side = args[4]
   --self.animation.side = args[4]

    local gm = get_game_machine()
   --if gm.client ~= true then
      self:remove_event("on_move")
   --else
      print("client")
   --end
   self.flags.move["x"]=0
   self.flags.move["y"]=0
   DObj.in_move_new(self,self.flags.move)
end


function DObj.in_move_new(self,args)
   local gm = get_game_machine()
   local vector_x,vector_y = args[1][1],args[1][2]
   local speed = args["pixel_time"]
   local last_time = args["last_time"]
   local current_time = gm:get_time()
   local h = Tiles.tile_size.h/2      
   local delay = current_time - last_time
   local pixels = math.floor(delay/speed)
   local tmp =  delay % speed

   self.flags.move["last_time"] = current_time - tmp
   self.flags.move["pixel_count"] = self.flags.move["pixel_count"] + pixels
   self.bound_box.x = self.bound_box.x + pixels*vector_x
   self.bound_box.y = self.bound_box.y + pixels*vector_y 

   for k,v in ipairs(self.render_objects) do
      if v ~= 0 then
	 if v.move then
	    v:move(pixels*vector_x,pixels*vector_y)
	 end
      end
   end      

   self.flags.move["x"] = self.flags.move["x"] + pixels*vector_x 
   self.flags.move["y"] = self.flags.move["y"] + pixels*vector_y

   if math.abs(self.flags.move["pixel_count"]*vector_x) >= Tiles.tile_size.w or 
   math.abs(self.flags.move["pixel_count"]*vector_y) >= Tiles.tile_size.h 
   or
      (math.abs(self.flags.move["pixel_count"]*vector_x) >= Tiles.tile_size.w/2 and
	  math.abs(self.flags.move["pixel_count"]*vector_y) >= Tiles.tile_size.h/2) 
   then 	 

      for k,v in ipairs(self.last_point) do 
	     MpR.remove_element(v.x,v.y,self.layer)	 
      end


      self.tmp.x = args[3][1].x
      self.tmp.y = args[3][1].y      
      self:insert_to_field(args[3][1].x,args[3][1].y)
      self.flags.move = nil	 

      if gm.server then
         Server.endMove(self, args)
      end

      self:add_event("on_move",on_move)     

      return 
   end   
end

local function in_move(self, args)
   local gm = get_game_machine()
   local vector_x,vector_y = args[1][1],args[1][2]
   local speed = args[2]

   local h = Tiles.tile_size.h/2      

   if speed == 0 then 	 



      for k,v in ipairs(self.last_point) do 
	      MpR.remove_element(v.x,v.y,self.layer)	 
      end

      self.tmp.x = args[3][1].x
      self.tmp.y = args[3][1].y      

      self:insert_to_field(args[3][1].x,args[3][1].y)

      self:add_event("on_move",on_move)
      self.flags.move = nil	 
      return 
   end

   self.bound_box.x = self.bound_box.x +vector_x
   self.bound_box.y = self.bound_box.y +vector_y

   for k,v in ipairs(self.render_objects) do
      if v ~= 0 then
         if v.move then
          v:move(vector_x,vector_y)
         end
      end
   end      
end

local function on_iter(self)  
   
   self:callbacks_apply()
   if self.destroy then
--      self:update_animation()
      return
   end
   if self.iter_fce then
      self.iter_fce(self)
   end
   if self.flags.move then
      self.flags.move[2] = self.flags.move[2] - 1
	 DObj.in_move_new(self,self.flags.move)
   elseif self.flags.fight then
      local gm = get_game_machine()
      
      if (self.flags.fight[1]+ self.flags.fight[2]) < gm:get_time() then
         self:send_event("on_fight", self.flags.fight[3],self.flags.fight[4])
         self:add_event("on_move",on_move)
      end
   elseif self.flags.spell then
      local gm = get_game_machine()
      
      if (self.flags.spell[1]+ self.flags.spell[2]) < gm:get_time() then
          self:send_event("on_spell", self.flags.spell[3],self.flags.spell[4])
          self:add_event("on_move",on_move)
          self.flags.spell = nil
      end
   elseif self.flags.death then
      local gm = get_game_machine()
      if (self.flags.death[1]+ self.flags.death[2]) < gm:get_time() then
--	 self:send_event("on_death", self.flags.death[1],self.flags.death[2])
	      self:destroy_self()
         return
      end
   else
      
      local index,y,key = self.model:get_current_frame()
      
      if key ~= "stay" then
         self.animation.frame_time = 60
	      self:set_animation("stay",1,self.last_side)
      end
   end
   if self.iter_after_action then
      self.iter_after_action(self) 
   end
   
   self:callbacks_apply()
   self:update_animation()
   set_null_move_want(self)
end

local function is_flags_null(self)
   for k,v in pairs(self.flags) do
      if v then
	      return
      end
   end
   return true
end

function DObj.make_object(MODEL,x,y, layer)  

   local element = {}
   local game_machine = get_game_machine()
 --  local model = make_model(MODEL)
--   local size = model:get_size()
   
   element = {
      ["layer"] = 2,
      ["name"] = "dynamicObject",
      ["type"] = "dynamic",
      ["model"] = nil,
      ["last_point"] = {{["x"] = 0, ["y"] = 0}},
      ["render_objects"] = {},
      ["bound_box"] = {["x"] = 0, ["y"] = 0, ["w"] = 0, ["h"] = 0},
      ["render_points"] = {},
      ["in_renderer"] = nil,
      ["callbacks"] = {},
      ["apply_callbacks"] = {},
      ["flags"] = {
         ["move"] = nil,
         ["fight"] = nil,
         ["spell"] = nil,
         ["death"] = nil
      },
      ["equipment"] = {["model"] = {["model"] = nil}},
      ["tmp"] = {["x"] = 0, ["y"]= 0 },
      ["animation"] = {
         ["key_animation"] = nil,
         ["side"] = nil,
         ["frame"] = nil,
         ["last_time"] = nil,
         ["frame_time"] = 60
      },
      ["movementSpeed"] = 20,
      ["attackSpeed"] = 200,
      ["last_side"] = 1,
      ["iter_fce"] =nil,
      ["iter_after_action"] = nil,
      ["is_flags_null"] = is_flags_null,
      ["EId"] = IdG.getId()
   }
   DObj.ObjectsList[#DObj.ObjectsList + 1] = element
   function element:getId()
      return self.EId
   end
   function element:setId(eid)
      self.EId = eid 
   end

   function element:set_animation(key, frame, side)
      self.animation.key_animation = key
      self.animation.side = side
      self.animation.frame = frame
      self.last_side = side
      for k,v in pairs(self.equipment) do
      	 if v then
      	    v.model:set_animation(key,frame,side)
      	 end
      end
      for k,v in ipairs(_BINDING_EQUIPMENT[side]) do
   	 local equipment = self.equipment[v]

   	 if equipment then
   	    equipment = equipment.model
   	    self.render_objects[k] = equipment.graphic_element
   	 else
   	    self.render_objects[k] = 0
   	 end	 
      end      
   end
   function element:attachLight()

   end
   function element:next_animation(n)
      for k,v in pairs(self.equipment) do
	      v.model:next_animation(n)
      end      
   end

   function element:update_animation()
      game_machine:aktualize_time()
      local time = game_machine.get_time()
      local last_time = self.animation.last_time
      local divide      

      if last_time then
   	 if time - last_time > self.animation.frame_time then
   	    divide = (time-last_time) / self.animation.frame_time
   	    self:next_animation(1)
   	    self.animation.last_time = time - (time- last_time - 
   						  (math.floor(divide)*self.animation.frame_time))
   	    return
   	 end
      else
	     self.animation.last_time = time
      end      
   end

   function element:set_field(x,y)
      local w,h = Map.tile_size.w/2,Map.tile_size.h/2      
      local tab_m = self.model:get_matricies_collision()
      local n

      if self.flags.move then
--	 n = self.flags.move[3]
         n = move_last_points(self, x,y)	 
      else
         n = move_last_points(self, x,y)	 
      end

      for k,v in ipairs(n) do
         MpR.set_element(v.x,v.y,self,self.layer)
      end

      self.last_point = n

      local x,y = Tiles.tile_to_point(x,y)      
      local last_b_x, last_b_y = self.bound_box.x,self.bound_box.y

      self.render_points = self.last_point
      
      self.bound_box.x = x
     -- print(self.bound_box.h)
      self.bound_box.y = y - self.bound_box.h + h
      
   --   print(self.bound_box.x, self.bound_box.y, h)
      for k,v in pairs(self.render_objects) do
   	 if v ~= 0 then
   	    v:move(self.bound_box.x, self.bound_box.y)
   	 end
      end
   end

   function element:insert_to_field(x,y)
      local w,h = Map.tile_size.w/2,Map.tile_size.h/2
      local tab_m = self.model:get_matricies_collision()
      local n

      if self.flags.move then
         n = self.flags.move[3]
      else
         n = move_last_points(self, x,y)	 
      end

      for k,v in ipairs(n) do
         MpR.set_element(v.x,v.y,self,self.layer)
      end

      self.last_point = n

      local x,y = Tiles.tile_to_point(x,y)      
      local last_b_x, last_b_y = self.bound_box.x,self.bound_box.y

      self.render_points = self.last_point

      self.bound_box.x = x
      self.bound_box.y = y - self.bound_box.h + h
      
      for k,v in pairs(self.render_objects) do
   	 if v ~= 0 then
   	    v:move(self.bound_box.x - last_b_x, self.bound_box.y- last_b_y)
   	 end
      end

   end  

   function element:fightActivate(side, args)
      local gm = get_game_machine()
      local speed = self.attackSpeed
     
      if self:is_flags_null() then
	      self:set_animation("attack", 1, DObj.convert_moveStr_moveInt[side])
         local count = self.model:get_count_frame()

         self.animation.frame_time = math.floor(speed/count)
         
         local time = game_machine:get_time()
         self.flags.fight = {speed, time, side, args}
         self:remove_event("on_move")
         
         return true
      end
   end

   function element:fight(side, args)     
      element:fightActivate(side, args)
   end

   function element:spell(speed, side, args)
      if self:is_flags_null() then
   	 if self:try_spell("fireball") == nil then
   	    return 
   	 end
   	 self:set_animation("attack", 1, DObj.convert_moveStr_moveInt[side])
   	 local count = self.model:get_count_frame()

   	 self.animation.frame_time = math.floor(speed/count)
   	 local gm = get_game_machine()
   	 local time = game_machine:get_time()
   	 self.flags.spell = {speed, time, side, args}
   	 self:remove_event("on_move")
       return true
      end
   end

   function element:move(where)
      return self[where](self)
   end

   function element:move_right()
      local speed = self.movementSpeed
   
      return help_move(self, speed,1,0,DObj.convert_moveStr_moveInt["right"]) and self.callbacks["on_move"]
   end
   function element:move_down()
      local speed = self.movementSpeed
   
      return help_move(self, speed,0,1,DObj.convert_moveStr_moveInt["down"]) and self.callbacks["on_move"]
   end
   function element:move_left()
      local speed = self.movementSpeed
    
      return help_move(self, speed,-1,0,DObj.convert_moveStr_moveInt["left"]) and self.callbacks["on_move"]
   end
   function element:move_up()
      local speed = self.movementSpeed
    
      return help_move(self, speed,0,-1,DObj.convert_moveStr_moveInt["up"]) and self.callbacks["on_move"]
   end
   function element:move_up_right()
      local speed = self.movementSpeed
   
      return help_move2(self, speed,1,-1,DObj.convert_moveStr_moveInt["up_right"]) and self.callbacks["on_move"]
   end
   function element:move_down_right()
      local speed = self.movementSpeed
     
      return help_move2(self, speed,1,1,DObj.convert_moveStr_moveInt["down_right"]) and self.callbacks["on_move"]
   end
   function element:move_down_left()
      local speed = self.movementSpeed
    
      return help_move2(self, speed,-1,1,DObj.convert_moveStr_moveInt["down_left"]) and self.callbacks["on_move"]
   end
   function element:move_up_left()
      local speed = self.movementSpeed
    
      return help_move2(self, speed,-1,-1,DObj.convert_moveStr_moveInt["up_left"]) and self.callbacks["on_move"]
   end
   function element:apply_fce_to_tiles_object(fce,args,tiles)
      for k,v in ipairs(tiles) do
	      fce(args,v.x,v.y)
      end
   end   

   function element:set_iter_function(fce)
      self.iter_fce = fce
   end
   function element:set_iter_function_after(fce)
      self.iter_after_action = fce 
   end

   function element:get_bound_box()
      return element.bound_box
   end

   function element:get_map_bound_box()
      return element.bound_box
   end

   function element:set_destroy_flag()
      self.in_renderer = nil

      for k,v in ipairs(element.render_objects) do
--	 v.bound_box = self:get_map_bound_box()
      end
   end   
   
   function element:destroy_self()
      self.destroy = true
      for k,v in ipairs(self.last_point) do
	      MpR.remove_element(v.x,v.y, self.layer)
      end
      for k,v in ipairs(self.render_points) do
	      MpR.remove_element(v.x,v.y, self.layer)
      end
     if self.flags.move then
   	 for k,v in ipairs(self.flags.move[3]) do
   	    MpR.remove_element(v.x, v.y, self.layer)
   	 end
	      --self.flags.move = nil
      end
      DObj.remove_element(element:getId())


   end

   function element:is_event(key)
      if self.callbacks[key] then
	     return true
      end
   end
   function element:add_event(key,fce)
      self.callbacks[key] = fce
   end
   function element:remove_event(key)
      self.callbacks[key] = nil
   end
   function element:send_event(key,args)
      local fce = self.callbacks[key]

      if fce then
	     self.apply_callbacks[#self.apply_callbacks + 1] = {fce, args}
      end
   end
   function element:get_id()
      return self.id
   end
   function element:callbacks_apply()
      for k,v in ipairs(element.apply_callbacks) do
         v[1](self,v[2])
      end
      self.apply_callbacks = {}
   end

   local function on_destroy(self)
      self:destroy_self()
   end

   function element:endMove(args)
      for k,v in ipairs(self.last_point) do 
        MpR.remove_element(v.x,v.y,self.layer)   
      end

      self.tmp.x = args[3][1].x
      self.tmp.y = args[3][1].y      
      self:insert_to_field(args[3][1].x,args[3][1].y)
      self.flags.move = nil 
      self:add_event("on_move",on_move)       

   end

   function element:dump2()
      local e = self
      local dump_obj = {}
      
      dump_obj["id"] = Map.get_id()
      dump_obj["type"] = "dynamic"
      dump_obj["name"] = e.name
      dump_obj["EId"] = self.EId

      return dump_obj
   end
   
   function element:dump()    
      local dump = {
   	 ["id"] = Map.get_id(),
   	 ["name"] = self.name,
   	 ["type"] = self.type,
   	 ["bound_box"] = self.bound_box,
   	 ["last_point"] = self.last_point,
   	 ["render_points"] = self.render_points,
   	 ["flags"] = self.flags,
   	 ["animation"] = self.animation,
   	 ["last_side"] = self.last_side,
       ["EId"] = self.EId
      }     

      return dump
   end

   function element:load2(load_dump)
      local gm = get_game_machine()
      --[[
      for k,v in ipairs(self.last_point) do
	 SObj.remove_element(v.x,v.y, 2)
      end
      for k,v in ipairs(self.render_points) do
	 SObj.remove_element(v.x,v.y, 2)
      end
      ]]
      self.sprite = nil
      self.render_objects = {}
   --   if model == nil then
      self.model = self.model
   --   end
      self["equipment"] = {
	     ["model"] = {["model"] = self.model}
      }

      if gm.client ~= nil then
       self.EId = load_dump.EId
      end

      self.id = load_dump.id
      self.bound_box = load_dump.bound_box
      self.last_point = load_dump.last_point
      self.render_points = load_dump.render_points
      self.flags = load_dump.flags
      self.animation = load_dump.animation
      self.last_side = load_dump.last_side
      self.animation.last_time = nil
      self.name = load_dump.name
      self:set_animation(self.animation.key_animation, self.animation.frame,self.last_side)
      self:set_field(self.last_point[1].x,self.last_point[1].y)    

      if self.flags.move then
      	self.bound_box.x = self.bound_box.x + self.flags.move["x"]
      	self.bound_box.y = self.bound_box.y + self.flags.move["y"]

      	for k,v in ipairs(self.render_objects) do
      	  if v ~= 0 then
   	       if v.move then
   		        v:move(self.flags.move["x"], self.flags.move["y"])
   	       end
   	    end
   	   end      
      end

      game_machine:add_event(self,"on_iter", on_iter)
         
      if self:is_flags_null() then
         element:add_event("on_move", on_move)
      end

  --    element:insert()
   --      element:add_event("on_fight", on_fight)
   end

   function element:stop_iter()
      game_machine:remove_event(element,"on_iter")
   end

   function element:setModel(model)
      local model = make_model(model)
      element.model = model
      element.equipment["model"]["model"] = model

      local size = model:get_size()
      
      element.bound_box.w = size.w
      element.bound_box.h = size.h

      if model:get_matricies_collision() then
         element["last_point"] = {{["x"] = 1,
               ["y"] = 1},
                   {["x"] = 1,
               ["y"] = 2},
                   {["x"] = 2,
               ["y"] = 2},
                   {["x"] = 1,
               ["y"] = 3}}
      end
      
      game_machine:add_event(element, "on_iter", on_iter)
      element:add_event("on_move", on_move)
      element:add_event("on_fight", on_fight)
      element:add_event("on_spell", on_spell)
      element:add_event("on_destroy", on_destroy)   
      element:set_animation("stay",1,1)

      --print(on_iter, on_move, on_fight,)

   end
   function element:insert(x,y)     
      element:insert_to_field(x,y)
   end

   return element
end


function DObj.load_object(dump_object,iter_x,iter_y, is_new)
   local obj = dump_object
   local out 
   local gm = get_game_machine()

   if _NPC[obj.name] then
      out = NPC.make()
      out:load(dump_object)
   elseif obj.name == "hero" then
      out = make_hero()
      out:loadWithoutCalls(obj) 
      if gm.server then
         ServerChars.setHero(obj)
      end
   elseif _BESTIAR[obj.name] then
      out = Character.make()
      out:load(obj,is_new)
      if gm.server then
         ServerChars.setDobj(obj)
      end
   elseif _SPELLS[obj.name] then
      out = Spells.make(obj.name,side, iter_x, iter_y)
      out:load(obj)      
      if gm.server then
         ServerChars.setDobj(obj)
      end
   end  
 
   return out
end

function DObj.add_object(object)
   DObj.objects[#DObj.objects+1] = object
end

return DObj