local Spells = {}

local configurationObjects = _SPELLS

function Spells.make(name, side,x,y,creater,who)
   local gm = get_game_machine()
   local spell_conf = _SPELLS[name]
   local who = ""
   local dyn_obj = DObj.make_object()
  
   dyn_obj["name"] = "spell"
   dyn_obj["layer"] = 3
   function dyn_obj:setConfiguration(name)
      local conf = configurationObjects[name]

      if conf == nil then 
         error("This spell non exist") 
         return 
      end

      self:setModel(conf.animation)

      self["spell_type"] = "spell"
      self["name"] = name
      self["movementSpeed"] = conf.movementSpeed

      self.stats = {["attack"] = conf.attack}
      self.power = conf.power or 1
   end

   function dyn_obj:castSpell(name, side, x, y, creater, who)
      self:setConfiguration(name)
      self.side = side
      gm:aktualize_time()
      self["born"] = gm:get_time()
      self["who"] = who or ""
      self.through = true
      self.creater = creater

      if creater then
         self.power = math.random(creater.stats.wisdom/3) + self.power
      else
         self.power = 1
      end
      dyn_obj.stats.attack =  dyn_obj.stats.attack + self.power
      
      self:insert(x,y)
   end

  local light = Lgt.make( 400, {["r"] = 255,["g"] = 255,["b"] = 100} ) 

   local function in_death(self,time_to_die)
      self.flags.death = {gm:get_time(),time_to_die}
   --   self.flags.move = nil
      self:set_iter_function(function () end)
      light:destroy()
   end

   local dump_tmp = dyn_obj.dump
   function dyn_obj:dump()
      local dumping = dump_tmp(self)
      dumping["side"] = side
      dumping["born"] = self.born
      dumping["who"] = self.who      
      dumping["stats"] = self.stats
      return dumping
   end
   function dyn_obj:load(loader)
      self:setConfiguration(loader.name)
      dyn_obj:load2(loader)
      side = loader.side
      self.born = loader.born
      self.stats = loader.stats
   end

   function dyn_obj:setIteration()
      self:set_iter_function(function (self)
   				local elems = MpR.get_elements(self.last_point[1].x, 
   								self.last_point[1].y) or {}
               light:setToField(self.render_points[1].x, self.render_points[1].y )
               light:turnOn()

   				for k,elem in ipairs(elems) do
   				   if type(elem) == "table" and elem ~= self and elem.through == nil 
   				      and elem[2] ~= self and elem[2] ~= self.creater and elem ~= self.creater
   				   then
   				      if elem.on_defense then
   			            elem:on_defense(self,args)				     
   				      elseif elem[2] and elem[2].on_defense then
   				         elem[2]:on_defense(self,args)
   				      end
   				         in_death(self,40)
   				      return
   				   end
   				   if type(elem) == "number" and elem ~= 0 then
   				      in_death(self,40)
   				      return
   				   end
   				end
   				if gm:get_time() - self.born > spell_conf.live then
   				   self:destroy_self()
                  light:destroy()
   				else
   				   self["move_" .. side](self)
   				end				

   			     end )
   end   

   dyn_obj:setIteration()

   return dyn_obj
end

return Spells