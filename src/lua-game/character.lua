local Character = {}

local configurationObjects = _BESTIAR

function Character.attack(defender,attacker)
   local stats_d = defender.stats
   local stats_a = attacker.stats

   local r = (stats_a.strengh *2+stats_a.dexterity+attacker.attack) - 
      (stats_d.strengh/4 + stats_d.dexterity)

   return r
end


function Character.make(name,x,y)
   local game_machine = get_game_machine()
   local dobj = DObj.make_object()

   dobj["friend_ship_state"] = "enemy"
 
   function dobj:setConfiguration(name)
      local conf = configurationObjects[name]

      if conf == nil then
         error("non registrate object in _BESTIAR: ", name)
         return 
      end

      self["name"] = conf.name
      dobj["stats"] = conf.stats
      dobj["health"] = conf.stats.health
      dobj["experience"] = conf.experience 
      
      dobj["range"] = conf.range
      dobj["config"] = conf
      dobj["color"] = conf.color
      dobj["movementSpeed"] = conf.movementSpeed
      dobj["attackSpeed"] = conf.attackSpeed

      dobj:setModel(conf.animation)

      if conf.on_iter and game_machine.client == nil then      
         dobj:set_iter_function(conf.on_iter)
      end

      if conf.on_draw then
         dobj.on_draw = conf.on_draw
      end
   end

   function dobj:sum_stats()
      return dobj.stats
   end
   
   local dump_tmp = dobj.dump
   
   function dobj:dump()
      local dumping = dump_tmp(self)
      dumping["health"] = dobj.health
      return dumping
   end
   local load_tmp = dobj.load2
   function dobj:load(obj, is_new)
      self:setConfiguration(obj.name)

      load_tmp(self, obj)
     

      if obj.health and is_new == nil then
	     self.health = obj.health
      end
   end

   function dobj:on_defense(attacker)      
      local hurt = 0
      if attacker.spell_type then
	     hurt = Attack.count_spell_attack(attacker, dobj:sum_stats())
      else
	     hurt = Attack.count_mellee_attack(attacker:sum_stats(), dobj:sum_stats())
      end
      
      dobj:add_health(-hurt)
      if attacker.add_text_event or attacker.who == "hero" then
         attacker = attacker.creater or attacker
	     attacker:add_text_event("<color:100,100,100>Působíš zranění: " .. math.floor(hurt))
      end

      if dobj.health <= 0 then
         local x,y = dobj.last_point[1].x,dobj.last_point[1].y
	  
         if attacker.add_experience then
          attacker:add_experience(dobj.experience)
         end

   	 dobj:destroy_self()
   	 local tab = {}
   	 for k,v in pairs(_ITEMS) do
   	    if v.type ~= "quest_item" then
   	       local x = math.random(4)
   	       if x == 1 then
   		  tab[#tab + 1] = k
   	       end
   	    end
	  end
	 local obj = MpR.get_element(x,y,1)

   	 if type(obj) ~= "number" and obj.name == "drop_item" then
   	    HelpFce.append(obj.slot,tab)
   	 else
   	    local tmp = SObj.load_object("drop_item",x,y,tab)
   	    MpR.set_element(x,y,tmp,1)
   	    
   	    game_machine:add_event(tmp,"on_iter", function (self)               
   				      if #tmp.slot == 0 and tmp.open == nil then
   		    			   MpR.remove_element(x,y,1)
   			            tmp.destroy = true
   				      end
   					end)
        end	 
      end
   end

   function dobj:add_health(health)
      self.health = self.health + health
      if self.health > self.stats.health then
	     self.health = self.stats.health
      end
   end

 
   return dobj
end


return Character