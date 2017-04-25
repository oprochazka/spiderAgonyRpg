local Server = {}
local iter = 0

function Server.loopAction()
 	local str = ERPG_Network_server.get_data(200) or {} 	

	  for k,string in pairs(str) do
		
     	local gm = get_game_machine()
      
	  	local u = gm:getUserUI()
	     u.heroEvents:add_text(k .. " : " .. string)

	    local deParseStr = {}
	    for name, value in string.gmatch(string, ";*(.-);") do
	      deParseStr[#deParseStr + 1] = name            
	    end

	    if deParseStr[1] == "Connect" then
	       Server.acceptConnection(deParseStr[2])
	    elseif deParseStr[1] == "move" then      
	        local element = DObj.get_element(deParseStr[2])        
	        Server.move(element, deParseStr[3])
		elseif deParseStr[1] == "fight" then
			local element = DObj.get_element(deParseStr[2]) 
			Server.fight(element, deParseStr[3])
	    elseif deParseStr[1] == "castSpell" then
	    	local element = DObj.get_element(deParseStr[2])            
	        local spellPossible = element:spell(deParseStr[3],deParseStr[4])

	        if spellPossible then
	        	ERPG_Network_server.add_broad_string("castSpell;" .. deParseStr[2] .. ";" .. deParseStr[3] .. ";" .. deParseStr[4] .. ";", "-1")            
	        end
	    elseif deParseStr[1] == "setEquipment" then
	    	local element = DObj.get_element(deParseStr[2])
    		if element then
    			local item = element:getItemById(tonumber(deParseStr[3]))

    			if item then
    				Server.setEquipment(element, item)
    			end
    		end
	    
	    elseif deParseStr[1] == "unsetEquipmentInv" then
	    	local element = DObj.get_element(deParseStr[2])
    		if element then
    			local item = element:getItemById(tonumber(deParseStr[3]))

    			if item then
    				Server.unsetEquipmentInv(element, item)
    			end
    		end
	    end
	  end
   
    return #str
end

function Server.acceptConnection(heroString)
	for k,v in ipairs(DObj.ObjectsList) do
		local output =""
	    output = Serialization.serializeToString(v:dump())

	    ERPG_Network_server.add_broad_string("loadDobj;" .. output .. ";---" .. iter, "1")

	    iter = iter + 1
	end
	--[[for k,v in ipairs(Item.items) do
		local output =""
	    output = Serialization.serializeToString(v:dump())

	    ERPG_Network_server.add_broad_string("loadItem;" .. output .. ";---" .. iter, "1")

	    iter = iter + 1
	end]]

	local hero = make_hero()  

	loadstring("temp =" .. heroString)()
	hero:loadWithoutCalls(temp) 
	hero:setId(IdG.getId())

    local output =""
    output = Serialization.serializeToString(hero:dump())

    ERPG_Network_server.add_broad_string("Hero;" .. output .. ";---" .. iter, "1")
    iter = iter + 1

    print("pocet",iter)
end

function Server.endMove(object, args)
	local output =""
    output = Serialization.serializeToString(args)
	ERPG_Network_server.add_broad_string("endMove;" .. object:getId() .. ";" .. output..  ";", "-1")
end

function Server.move(object, strSide)
	--local object = DObj.get_element(object)   
 --	local where = "move_" .. strSide   
	local movePossible = object[strSide](object)
	  
	if movePossible then
	  ERPG_Network_server.add_broad_string("move;" .. object:getId() .. ";" .. strSide .. ";", "-1") 	  
	end

	return movePossible
end

function Server.fight(object, strSide)
	local fightPossible = object:fightActivate(strSide)
    if fightPossible then
    	ERPG_Network_server.add_broad_string("fight;" .. object:getId() .. ";" .. strSide .. ";", "-1")            
    end
end

function Server.spell()

end

function Server.setEquipment(self, item)
	local result = self:set_equipmentActivate(item)
    if result then    	
    	ERPG_Network_server.add_broad_string("setEquipment;" .. self:getId() .. ";" .. item:getId() .. ";", "-1")            
    end
    return result
end

function Server.unsetEquipmentInv(self, item)
	local result = self:unset_equipmentActivate(item)
	self:add_item_to_list(item)
   	ERPG_Network_server.add_broad_string("unsetEquipmentInv;" .. self:getId() .. ";" .. item:getId() .. ";", "-1")            
 
    return result
end

return Server