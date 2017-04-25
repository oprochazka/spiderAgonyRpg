local Client = {}

Client["sendActions"] = {}
Client["recieveActionList"] = {}
Client["pointer"] = 1

local iter = 0

function Client.loop()
	local game_machine = get_game_machine()
	local str = ERPG_Network.get_data()
	if str ~= nil then
		parser = Client.parser(str)
		local gm = get_game_machine()
      
	  	local u = gm:getUserUI()
	     u.heroEvents:add_text(str)
    	if parser[1] == "move" then
    		local element = DObj.get_element(parser[2])

    		element[parser[3]](element)
    	end
    	if parser[1] == "endMove" then
    		local element = DObj.get_element(parser[2])
    		if element then
	    		loadstring("temp =" .. parser[3])()
	    		element:endMove(temp)
	    	end
    	end
 		if parser[1] == "fight" then
    		local element = DObj.get_element(parser[2])
    		if element then	    		
	    		element:fight(parser[3])
	    	end
    	end
    	if parser[1] == "castSpell" then
    		local element = DObj.get_element(parser[2])
    		if element then	    		
	    		element:spell(parser[3], parser[4])
	    	end
    	end
    	if parser[1] == "setEquipment" then
    		local element = DObj.get_element(parser[2])

    		if element then

    			local item = element:getItemById(tonumber(parser[3]))
    			element:set_equipmentActivate(item)

   				local userUi = game_machine:getUserUI()
    			if element == userUi.connectedHero then
    				userUi.heroDialog:refresh()
    			end    			
    		end
    	end
    	if parser[1] == "unsetEquipmentInv" then
    		local element = DObj.get_element(parser[2])
    		print("heja ", element)
    		if element then
   				local userUi = game_machine:getUserUI()
   				print("----")
    			if element ~= userUi.connectedHero then
    				print("wtf_::::")
    				local item = element:getEquipById(tonumber(parser[3]))
    				print(item, parser[3])
	   				local result = element:unset_equipmentActivate(item)
					element:add_item_to_list(item)
    			end    			
    		end
    	end
    end    
    return str
end

function Client.parser(string)
	local deParseStr = {}
	  for name, value in string.gmatch(string, ";*(.-);") do
	      deParseStr[#deParseStr + 1] = name            
	   end
   return deParseStr
end


function Client.sendHero(hero)
	output = Serialization.serializeToString(hero:dump())
    ERPG_Network.add_data("Connect;" .. output .. ";")
    local str = ""
    local parser = {}
    while true do 		

    	--print(output)
    	local str = ERPG_Network.get_data()
    	
    	if str ~= nil then
    		iter = iter + 1
    		print(iter, str)
    		parser = Client.parser(str)
			
	    	if parser[1] == "Hero" then
	    		loadstring("temp =" .. parser[2])()
	    		if temp.name == hero.name then
	    			hero:load(temp)    
		    		ClientChars.setHero(hero)
	    			return			
	    		end
	    	elseif parser[1] == "loadDobj" then
	    		--print(p)
	    		loadstring("temp =" .. parser[2])()

	    		print(temp.last_point[1].x,temp.last_point[1].y)
	    		local obj = DObj.load_object(temp, temp.last_point[1].x,temp.last_point[1].y, true)	   
	    		if obj == nil or obj.setId == nil then
	    			print(temp.name)
	    			end          
	    		obj:setId(temp.EId)
	    	end
	    end
    end
end
local counter3 = 0;
function Client.move(hero, where)	
	local self = hero
	local possibleToMove = false
    if self.flags.move then
	    local args = self.flags.move
	    local vector_x,vector_y = args[1][1],args[1][2]

	    if math.abs(self.flags.move["pixel_count"]*vector_x) >= Tiles.tile_size.w or 
	     math.abs(self.flags.move["pixel_count"]*vector_y) >= Tiles.tile_size.h 
	     or
	        (math.abs(self.flags.move["pixel_count"]*vector_x) >= (Tiles.tile_size.w/2 - 4) and
	      math.abs(self.flags.move["pixel_count"]*vector_y) >= (Tiles.tile_size.h/2) - 4) then
	        possibleToMove = true
	      end
	end

	if (self.flags.move == nil or possibleToMove == true) then
		ERPG_Network.add_data("move;" .. hero:getId() .. ";" .. "move_" .. where .. ";")
	end

	counter3 = counter3 + 1
end

function Client.fight(hero, side)
	ERPG_Network.add_data("fight;" .. hero:getId() ..";"  .. side .. ";")
end
function Client.castSpell(hero, strSide, spell)
	ERPG_Network.add_data("castSpell;" .. hero:getId() .. ";900;".. strSide ..";")
end
function Client.setEquipment(self, item)
	ERPG_Network.add_data("setEquipment;" .. self:getId() .. ";".. item:getId() ..";")
end
function Client.unsetEquipmentInv(self, item)
	local result = self:unset_equipmentActivate(item)
	self:add_item_to_list(item)
	ERPG_Network.add_data("unsetEquipmentInv;" .. self:getId() .. ";".. item:getId() ..";")
end

local counter2 = 0
function Client.recieveActions()
	local gm = get_game_machine()   
	local UserUI = gm:getUserUI();
	local action
	local x
	local y
	local layer
	local strArgs
	local str = true
	
	while str ~= nil do
		str = ERPG_Network.get_data(200)

		

		if str == nil or tostring(str) == "connection" then 
			end 
		if str ~= nil then

			UserUI.heroEvents:add_text(str)
		end
	end 
		--[[else
		UserUI.heroEvents:add_text(str)

			local deParseStr = {}

			for name, value in string.gmatch(str, ";*(.-);") do
				deParseStr[#deParseStr + 1] = name
				
			end

			if #deParseStr >= 1 then 
				print(str)
				print(counter2, "Inputpair")
				counter2 = counter2 + 1
				action = deParseStr[1]
				x = tonumber( deParseStr[2] )
				y = tonumber(deParseStr[3])
				layer = tonumber(deParseStr[4])

				 	local object = MpR.get_element(x,y, layer)
				 	print(object)
				 	
				 		if Client[action] then
				 	
				 			Client[action](x,y, layer, deParseStr[5], deParseStr[6], deParseStr[7])
				 		else
				 			if object ~= nil and type(object) ~= "number" then
				 				print(object, deParseStr[5], deParseStr[6], deParseStr[7])
				 				if object[action] then
				 					object[action](object, deParseStr[5], deParseStr[6], deParseStr[7])
				 				end
				 			end
				 		end
			 end
			end
		end]]
		

end


function Client:addAction(action, x, y, layer, args)
	local strArgs = ""

	if args then
		for k,v in ipairs(args) do
			strArgs = v .. ";"
		end
	end

	Client.sendActions[Client.pointer] = action .. ";".. x .. ";" .. y .. ";" .. layer .. ";" .. strArgs
	Client.pointer = Client.pointer + 1

end

function Client.insert_hero(x,y, layer)
      local conf = {
   	 ["experience"] = 0,
   	 ["stats"] = {
   	    ["strengh"] = 10,
   	    ["dexterity"] = 10,
   	    ["health"] = 10*3,
   	    ["wisdom"] = 10,
   	    ["mana"] = 10},
   	 ["level_points"] = 10,
   	 ["items"] = {},
   	 ["level"] = 1,
   	 ["health"] = 10*3,
   	 ["mana"] = 10*3
      }

      hero = make_hero()  
      hero:setConfiguration(conf)
      hero:insert(x,y)
end
local counter = 0

function Client.sendActionsToServer()
	for k = 1, #Client.sendActions do
		if Client.sendActions[k] == nil then
			break
		end	
		ERPG_Network.add_data(Client.sendActions[k])
		print(counter, "pair")
		Client.sendActions[k] = nil
		counter = counter + 1
	end

	Client["pointer"] = 1
end

return Client