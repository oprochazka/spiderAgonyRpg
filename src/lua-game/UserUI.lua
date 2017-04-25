local UserUI = {}



local function on_change_item_chest(self,item)
   self.chest.slot[#self.chest.slot + 1] = item.item.name
   
   self.hero:remove_item_from_list(item)

   GUI.remove_event(item,"on_click")
end

local function on_remove_item(self,item)
   for k,v in ipairs(self.chest.slot) do
      if v == item.item.name then
        table.remove(self.chest.slot, k)
        if self.hero then
          self.hero:add_item_to_list(item.item)
          break
        end
      end
   end
end

local function on_click_item_inventory(self, mouse)
	local hero = self.connectedHero
	if hero == nil then
		return
	end

	if mouse.release == "right" and (mouse.release ~= "left" and mouse.press ~= "left") then
	  if self.item.item_config.on_activate then
	    self.item.item_config:on_activate(hero, self) 
	    GUI.send_event(self.parrent,"remove_item")
	  end
	end
end

local function angle_apply(norm_x,norm_y, fce_1,fce_2,fce_3,self,args)
  local tmp = norm_x+norm_y
  local x_p = (norm_x/tmp)*100

  local p1,p2,p3 = 66.6, 33.3, 0

  if x_p > p1  then
    return fce_1
  end
  if x_p <= p1 and x_p >= p2 then
    return fce_2
  end
    return fce_3  
end

local function get_side(hero, x,y)
  local game_machine = get_game_machine()
  local screen_w, screen_h = game_machine.canvas:get_size()
  local w, h = screen_w, screen_h
  local hero_x = w/2 
  local hero_y = h/2 - (hero.bound_box.h) + Tiles.tile_size.h
  local mid_x, mid_y = hero_x, hero_y+Tiles.tile_size.h/2
  local x,y = x - mid_x, mid_y - y
  local result 
  if x > 0 and y > 0 then
    result =  angle_apply(x,y,"right", "up_right","up")
  elseif x < 0 and y >0 then
    result = angle_apply(math.abs(x),y,
        "left", "up_left","up")
  elseif x < 0 and y < 0 then
    result = angle_apply(math.abs(x),math.abs(y),
        "left", "down_left","down")
  elseif x > 0 and y < 0 then
    result = angle_apply(x,math.abs(y),
        "right", "down_right","down")
  end
  return result
end

local function set_move_cursor(move_key)
  local result = move_key
  local cursor = GUI.get_cursor()
  if result == "right" then
   cursor:set_clip(7,0)
  end
  if result == "left" then
   cursor:set_clip(0,0)
  end
  if result == "up_right" then
   cursor:set_clip(3,0)
  end
  if result == "up" then
   cursor:set_clip(2,0)
  end
  if result == "down" then
   cursor:set_clip(5,0)
  end
  if result == "up_left" then
   cursor:set_clip(1,0)
  end
  if result == "down_left" then
   cursor:set_clip(4,0)
  end
  if result == "down_right" then
   cursor:set_clip(6,0)
  end
end


local function on_iterControlls(self)
  local gm = get_game_machine()

  if gm.client then
    local str = ""
    while str ~= nil do
      
      str = Client.loop()
    end
  end
  if gm.server then
    local len = 1
    while len ~= 0 do          
      len = Server.loopAction()      
    end
  end 

  local open_item = self.openItem
  local cursor = GUI.get_cursor()
  local hero = self.connectedHero

  cursor:set_clip(1,0)

  if mouse.press == "right" then
    local result = get_side(hero,mouse.x,mouse.y)
    if result then      
      hero:send_event("moveTo", result)
      set_move_cursor(result)
    end   
    if self.openItem then
      if self.openItem.chest then
         self.openItem["chest"].open = nil
      end
      GUI.send_event(self.openItem,"on_destroy")
      self.openItem = nil
    end
    elseif keyboard.press[1] == "Left Ctrl" then
      local result = get_side(hero,mouse.x,mouse.y)
      set_move_cursor(result)
      if result and mouse.on_press == "left" then
      	hero:send_event("castSpellTo", result)
      end 
    elseif keyboard.press[1] == "Left Shift" then
      local result = get_side(hero,mouse.x,mouse.y)
      set_move_cursor(result)
      if result and mouse.on_press == "left" then
      	hero:send_event("fightTo", result)
      end
    elseif mouse.release ~= "none" then
      local cursor = GUI.get_cursor()
      cursor:set_clip(1,0)
    end

    if keyboard.press[1] == "S" and mouse.on_press == "left" then
        hero:send_event("useHealPotion")
    elseif keyboard.press[1] == "D"  and mouse.on_press == "left" then
        hero:send_event("useManaPotion")
  end
end

local function activate_object(self, object)
  local game_machine = get_game_machine()   
  local open_item = self.openItem

  if self.openItem then
    if self.openItem.chest then
       self.openItem.chest.open = nil
    end
    GUI.send_event(self.openItem,"on_destroy")
    self.openItem = nil
  end
  if object.name == "chest" or object.name == "drop_item" then
    self.openItem = make_inventory(18)
    for k,v in ipairs(object.slot) do
       self.openItem:add_item(make_inventory_item(Item.make_item(_ITEMS[v])))
    end
    self.openItem["chest"] = object
    object["open"] = true
    self.openItem["hero"] = self.connectedHero
    GUI.add_event(self.openItem,"change_item", on_change_item_chest)
    GUI.add_event(self.openItem,"remove_item", on_remove_item)
    GUI.add_event(self.openItem,"on_destroy", 
      function (self) 
        self:on_destroy()
        object["open"] = nil
        end)

    GUI.compose_object(game_machine:get_main_frame(), self.openItem)
  elseif object.type and object.type == "dynamic" then
    if self.openItem then else
      self.openItem = NPC.make_dialog(object,self)
      GUI.compose_object(game_machine:get_main_frame(), self.openItem)
    end
  end
end

local function on_activate_item(self, args)
   local x = args.x
   local y = args.y
   local object = args.object
   
   for k1,v1 in ipairs(_Activate_object) do
      local x1,y1 = Tiles["get_" .. v1](x,y)
      local elems = MpR.get_elements(x1,y1)
      elems = elems or {}
      for k,v in ipairs(elems) do
       if type(v) == "table" and v.name == "hero" then
          activate_object(self, args.object)
          return
       end
      end
   end
  if self.connectedHero then
    self.connectedHero:add_text_event("Jsi daleko od objektu který chceš aktivovat musíš být vzdálen přesně 1 políčko")   
  end
end
local function on_click_send(msg)
  local gm = get_game_machine()
  local i = 0
  if gm.server then

    while i < 40000 do
      ERPG_Network_server.add_broad_string(msg, "-1")
      i = i + 1

    end
    
  end
  if gm.client then
    while i < 40000 do
      ERPG_Network.add_data(msg)
      i = i + 1
    end
  end
end
function UserUI.make(type)
	local game_machine = get_game_machine()

	local element = {
		["heroDialog"] = nil,
		["healthBar"] = nil,
		["manaBar"] = nil,
		["heroDialog"] = nil,
		["heroEvents"] = nil,
		["inventory"] = nil,
		["connectedHero"] = nil,
		["heroEvents"] = nil,
		["heroLastItems"] = nil,
		["menuBar"] = nil,
		["improveStats"] = nil,
    ["openItem"] = nil
	}

	function element:initializeUI(positionX)
		element.improveStats  = HeroDialog.improve_stats(hero)
		element.menuBar = HeroDialog.add_menu_bar(element)
		element.heroDialog = HeroDialog.make()
	    element.healthBar = Bar.make({70,70,70,255},{160,10,10,255},200, 40, 0)
	    element.manaBar = Bar.make({70,70,70,255},{10,10,160,255},200, 40, 0)
	    element.heroEvents = HeroDialog.add_hero_event(hero)
      local gm = get_game_machine()
      local text = "server"
       if type ~= null and type == "client" then
        text = "client"
       end
      element.chat = GUI.make_input_frame(text, 70,"txt",on_click_send)  
      GUI.add_event(element.chat,"on_destroy", function () end)

	    element.healthBar:change_current(0)
	    element.manaBar:change_current(0)

	    element.inventory = make_inventory(30, on_click_item_inventory)
	   	element.inventory:unbind_panel()

	   	GUI.compose_object(game_machine:get_main_frame(), element.menuBar)
	   	GUI.compose_object(game_machine:get_main_frame(), element.healthBar)
	    GUI.compose_object(game_machine:get_main_frame(), element.inventory)
	    GUI.compose_object(game_machine:get_main_frame(), element.heroDialog)   
	    GUI.compose_object(game_machine:get_main_frame(), element.manaBar)  
	    GUI.compose_object(game_machine:get_main_frame(), element.heroEvents)
      GUI.compose_object(game_machine:get_main_frame(), _FrameBox) 
      GUI.compose_object(game_machine:get_main_frame(), element.chat)

      element.chat:move(positionX+100, 700)


      _FrameBox:move(positionX+200,0)
	    element.menuBar:move(positionX, 400)
	  	element.heroDialog:move(positionX,100)
	    element.healthBar:move(positionX,0)
	    element.manaBar:move(positionX,element.healthBar.bound_box.h)
	    element.inventory:move(positionX,420)

	    function self.heroDialog:init()
	    	local hero = element.connectedHero
	    	self:connectHero(hero)	    	
		    self:remove_items()

		    for k,item in pairs(hero.equipment) do
  		    if k ~= "model" then					
  					self:set_item(make_inventory_item(item))
  				end
    		end  
	    end

      function self.heroDialog:refresh()
        local hero = element.connectedHero

        for k,item in pairs(hero.equipment) do
         
          if k ~= "model" and item ~= nil then          
            --self:set_item(make_inventory_item(item))
            local inv_item = element.inventory:get_invetory_item_id(item:getId())
            element.inventory:remove_item(inv_item)
            if inv_item then
              self:set_item(inv_item)
            end
          end
        end  
      end

	    function self.heroEvents:refresh()
	    	local hero = element.connectedHero

	    	for k,v in ipairs(hero.newEventsList) do
	    		self:add_text(v)
	    	end
	    	hero.newEventsList = {}
	    end

      function self.inventory:init()
  			self:remove_items()

  			for k,v in ipairs(element.connectedHero.items) do
          local inv_item = make_inventory_item(v)
  				self:add_item(inv_item)
  			end
	    end
--[[
      function self.inventory:add_item(item)
        self:add_item(make_inventory_item(item))
      end

      function self.inventory:add_item(item)
        self:add_item(make_inventory_item(item))
      end
]]
	    function self.healthBar:refresh()
	       self:change_maximum(element.connectedHero.stats.health, element.connectedHero.health)     
	    end
	    function self.manaBar:refresh()
	       self:change_maximum(element.connectedHero.stats.mana, element.connectedHero.mana)     
	    end
	end

	function element:connectHero(hero)
		UserUI["connectedHero"] = hero

		self.improveStats:connectHero(hero)
		self.connectedHero = hero
		self.heroDialog:init()		
		self.inventory:init()
   
    hero.graphicInventory = self.inventory
	end 

	local function on_iter(self)
    
    
		if element.connectedHero == nil then
			return
		end

		on_iterControlls(self)

		--element.inventory:refresh(element.connectedHero.items)
		element.healthBar:refresh()
		element.manaBar:refresh()
		element.heroEvents:refresh()
		element.improveStats:refresh()
--    element.heroDialog:refresh()
	end

	game_machine:add_event(element,"on_iter", on_iter)

  game_machine:add_event(element,"objects_activate", on_activate_item)
	return element
end

return UserUI 