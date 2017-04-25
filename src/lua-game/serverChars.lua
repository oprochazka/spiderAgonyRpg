local ServerChars = {}

function ServerChars.setDobj(dobj)
   	function dobj:fight(side, args)    
      self:fightActivate(side, args)
   	end
   	function dobj:move(where)
      return Server.move(self, where)      
   	end
end

function ServerChars.setHero(hero)
	ServerChars.setDobj(hero)

   	function hero:set_equipment(item)
	    return Server.setEquipment(self, item)
	end
	function hero:unset_equipmentToInventory(item)    
	    return Server.unsetEquipmentInv(self, item)   
	end
	function hero:unset_equipment(item)
      return Server.setEquipment(self, item)
  	end
  	function hero:moveTo(strSide)
    	Server.move(self, "move_" .. strSide)      
  	end

  	hero:add_event("moveTo", hero.moveTo)    
end

return ServerChars