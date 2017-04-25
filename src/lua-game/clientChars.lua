local ClientChars = {}

function ClientChars.setHero(hero)
	local hero = hero

	function hero:moveTo(strSide)
		Client.move(self, strSide)
	end
	function hero:castSpellTo(strSide, spell)
    	Client.castSpell(self, strSide)
  	end
  	function hero:fightTo(strSide)
    	Client.fight(self, strSide)
  	end
  	function hero:set_equipment(item)    
    	return Client.setEquipment(self, item)    
  	end
  	function hero:unset_equipmentToInventory(item)        
    	return Client.unsetEquipmentInv(self, item)         
  	end
  	function hero:unset_equipment(item)    
    	return Client.setEquipment(self, item)   
  	end

  	hero:add_event("moveTo", hero.moveTo)
    hero:add_event("fightTo", hero.fightTo)
    hero:add_event("castSpellTo", hero.castSpellTo)
    --hero:add_event("useManaPotion", hero.useManaPotion)
    --hero:add_event("useHealPotion", hero.useHealPotion)
end

return ClientChars