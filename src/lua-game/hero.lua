--[[

   _CONFIG = {
   {
   name = string
   expiriance = num,
   health = num
   stats = streng, dexterity,health,wisdom,mana,
   level_points = num
   items = { items }
   equipment = { equipment}
   level = num
]]--

 --  hero["position"] = {["x"] = 0, ["y"] = 0}
--[[   hero["equipment"] = {
      ["tunic"] = nil,
      ["model"] = hero.model,
      ["trousers"] = nil,
      ["hair"] = nil,
      ["hat"] = nil,
      ["boots"] = nil,
      ["right_gloves"] = nil,
      ["left_gloves"] = nil,      
      ["left_hand"] = nil,
      ["right_hand"] = nil
   }]]

local TEXTS = {
  ["notEnoughSkills"] = 
  function (notEnough, need)
    return"<color:30,30,140>Tímto předmětem se nemůžeš vybavit nedostatek: " .. notEnough..
                ": Potřebuješ alespoň: " ..  need
  end,
  ["newExperience"] = 
  function (exp)
    return "<color:30,150,30>Dostáváš zkušeností: " .. exp
  end,
  ["newLevel"] =
  function (level)
    return "<color:200,30,30>Nová úroveň: " .. level
  end,
  ["hurtFor"] =
  function (hurt)
    return "Dostáváš zranění za: " .. math.floor(hurt)
  end
}


local transform_text = {
   ["dexterity"] = "Obratnost",
   ["strengh"] = "Síla",
   ["wisdom"] = "Moudrost"
}

local function check_transparency_set(objs)
   if objs then 
      for k,v in ipairs(objs) do
   if type(v) == "table" then
      if v and type(v) ~= "number" and  v.sprite and k ~=1 then
         v["transparent"] = true
      end
   end   
      end
   end
end
local function  set_transparent_line(x,y, vector,n)
   local n = n or 1
   local obj = MpR.get_elements(x,y)   
   local tmp_wall
   if type(obj) == "table" then
      for k,v1 in ipairs(obj) do
   if obj and type(v1) ~= "number" and  v1.sprite and k ~= 1 then
      local name = v1.name
      local is = string.find(name,"wall")
      
      if is == nil then 
         v1["transparent"] = true
      else
         tmp_wall = v1
      end
   end
      end
   end
   local tmp_x,tmp_y = x,y
   local cond
   if tmp_wall then
      for k=1,4 do 
    tmp_x,tmp_y= Tiles["get_" .. vector](tmp_x,tmp_y)
   local obj = MpR.get_elements(tmp_x,tmp_y)
   local is = nil
   if type(obj) == "table" then
      for k,v1 in ipairs(obj) do
         if obj and type(v1) ~= "number" and  v1.sprite and k ~= 1 then
      v1["transparent"] = true
      cond = true
      is = true
         end
      end
   end      
   if is == nil then break end
      end
   end

   if cond then
      if tmp_wall then
   tmp_wall["transparent"] = true
      end
   end

end



local function on_iter_after(self)
  local game_machine = get_game_machine()
  local screen_w, screen_h = game_machine.canvas:get_size()
  local w, h  = screen_w, screen_h
  local hero_x = w/2 
  local hero_y = h/2 - (self.bound_box.h) + Tiles.tile_size.h
  Map.move((self.bound_box.x-hero_x-(self.bound_box.w)) - Map.x, 
     (self.bound_box.y - hero_y) - Map.y)
end

local function on_iter_death(self)
  local cursor = GUI.get_cursor()
  cursor:set_clip(1,0)
end

local function on_iter(self)  
  if light ~= nil then
    light:setToField(hero.last_point[1].x, hero.last_point[1].y )
  end

  self["tmp_x"] = self.bound_box.x
  self["tmp_y"] = self.bound_box.y

  local last_point = self.render_points[1]   

  local tmp_x, tmp_y = Tiles.get_down_right(last_point.x,last_point.y)
  set_transparent_line(tmp_x, tmp_y, "up_right")
  set_transparent_line(tmp_x, tmp_y, "down_left",-1)
  tmp_x, tmp_y = Tiles.get_down_right(tmp_x,tmp_y)
  set_transparent_line(tmp_x, tmp_y, "up_right")
  set_transparent_line(tmp_x, tmp_y, "down_left",-1)
  tmp_x, tmp_y = Tiles.get_down_right(tmp_x,tmp_y)
  set_transparent_line(tmp_x, tmp_y, "up_right")
  set_transparent_line(tmp_x, tmp_y, "down_left",-1)

  tmp_x, tmp_y = Tiles.get_down_left(last_point.x,last_point.y)
  set_transparent_line(tmp_x, tmp_y, "up_left")
  set_transparent_line(tmp_x, tmp_y, "down_right",-1)
  tmp_x, tmp_y = Tiles.get_down_left(tmp_x,tmp_y)
  set_transparent_line(tmp_x, tmp_y, "up_left",-1)
  set_transparent_line(tmp_x, tmp_y, "down_right")
  tmp_x, tmp_y = Tiles.get_down_left(tmp_x,tmp_y)      
  set_transparent_line(tmp_x, tmp_y, "up_left")
  set_transparent_line(tmp_x, tmp_y, "down_right",-1)

  local y = last_point.y + 1 

  local objs = MpR.get_elements(last_point.x, y)
  check_transparency_set(objs)
  objs = MpR.get_elements(last_point.x, y+1)
  check_transparency_set(objs)

  self.iterator = self.iterator + 1
end

function make_hero(x,y, _CONFIG, load_hero,hero_model)
  local game_machine = get_game_machine()
  local rendering_objects = {}
  local mouse = game_machine:get_mouse()
  local screen_w, screen_h = game_machine.canvas:get_size()
  local first_level = 100
  local points_for_level = 10
  local hero = DObj.make_object()

  hero["name"] = "hero"  
  hero["type"] = "hero"
  hero["friend_ship_state"] = "friend"
  hero["newEventsList"] = {}
  hero["currentEquipment"] = {}
  hero["iterator"] = 0
  hero["graphicInventory"] = nil

  function hero:moveTo(strSide)
    hero["move_" .. strSide](hero)
  end

  function hero:castSpellTo(strSide, spell)
    hero:spell(900, strSide)
  end

  function hero:fightTo(strSide)
    hero:fight(strSide)
  end

  function hero:removeItemId(item)
    local inventory = self.graphicInventory
    if inventory then
      local inv_item = inventory:get_invetory_item_id(item:getId())

      if inv_item then
        self:remove_item_from_list(inv_item)
      end
    end
  end

  function hero:useHealPotion()
    local item = self:getItemByName("heal_potion")

    if item then
      local r = item.item_config:on_activate(self)
      if r then
        self:removeItemId(item)
      end
      return true      
    end
    return false
  end
  function hero:useManaPotion()
    local item = self:getItemByName("mana_potion")

    if item then
      local r = item.item_config:on_activate(self)
      if r then
        self:removeItemId(item)
      end

      return true
    end
    return false
  end

  function hero:setConfigurationWithoutCallbacks(configuration)
    hero:setModel(_ANIMATION_HERO)

    hero["experience"] = configuration.experience
    hero["health"] = configuration.health
    hero["mana"] = configuration.mana

    hero["stats"] = {
       ["strengh"]   = configuration.stats.strengh,
       ["dexterity"] = configuration.stats.dexterity,
       ["health"]    = configuration.stats.health,
       ["wisdom"]    = configuration.stats.wisdom,
       ["mana"]      = configuration.stats.mana,
       ["attack"]    = 10,
       ["armor"]     = 10
    }
    
    hero["movementSpeed"] = configuration.movementSpeed or 20
    hero["attackSpeed"] = configuration.attackSpeed or 600

    hero["level_points"] = configuration.level_points
    hero["items"] = configuration.items   
    hero["level"] = configuration.level

    hero["quests"] = {
         ["in_progress"] = {},
         ["completed"] = {},
         ["quest_item"] = {}
    }

    hero["items"] = {}

    for k, v in ipairs(configuration.items) do
      local item = Item.make_item(_ITEMS[v])
      self.items[#self.items + 1] = item
    end

    hero:add_event("moveTo", hero.moveTo)
    hero:add_event("fightTo", hero.fightTo)
    hero:add_event("castSpellTo", hero.castSpellTo)
    hero:add_event("useManaPotion", hero.useManaPotion)
    hero:add_event("useHealPotion", hero.useHealPotion)
  end
  function hero:setConfiguration(configuration)
    hero:setConfigurationWithoutCallbacks(configuration)    

    hero:set_iter_function(on_iter)
    hero:set_iter_function_after(on_iter_after)
    on_iter_after(hero)  

    hero:set_iter_function(on_iter)
  end

  function hero:loadFirst(loadDump)
    hero:setModel(_ANIMATION_HERO)

    hero.quests = loadDump.quests
    hero.health = loadDump.health
    hero.experience = loadDump.experience
    hero.stats = loadDump.stats
    hero.level_points = loadDump.level_points
    hero.items = loadDump.items
    hero.level = loadDump.level  
    self.mana = loadDump.mana
    
    hero:set_iter_function(on_iter)
    hero:set_iter_function_after(on_iter_after)
  
    on_iter_after(hero)   

  end
  
  local w, h  = screen_w, screen_h
  local open_item 

  function hero:change_stats(strengh, dexterity,wisdom)
     self.stats.strengh = strengh
     self.stats.dexterity = dexterity
     self.stats.wisdom = wisdom

     self.stats.health = strengh * 3
     self.stats.mana = wisdom * 3
     if self.stats.health < self.health then
       self.health = self.stats.health
     end
     if self.stats.mana < self.mana then
       self.mana = self.stats.mana
     end  
  end

  function hero:sum_stats()
     local sum ={
      ["dexterity"] = self.stats.dexterity,
      ["strengh"] = self.stats.strengh,
      ["wisdom"] = self.stats.wisdom,
      ["mana"] = self.stats.mana,
      ["armor"] = self.stats.armor,
      ["attack"] = self.stats.attack
     }
     for k, v in pairs(self.equipment) do
      if v.stats then
         for k,v in pairs(v.stats) do
            if sum[k] then
              sum[k] = sum[k] + v
            else
              sum[k] = v
            end
         end
      end
     end
     return sum
  end

  function hero:add_health(health)
     self.health = self.health + health
     if self.health > self.stats.health then
      self.health = self.stats.health
     end
  end
  function hero:add_quest(quest_name)
     self.quests.in_progress[quest_name] = 1
  end
  function hero:get_quest_progress( quest_name)
     return self.quests.in_progress[quest_name]
  end
  function hero:complete_quest( quest_name)
     self.quests.in_progress[quest_name] = nil
     self.quests.completed[quest_name] = 1
  end
  function hero:get_complete_quest(quest_name)
     return self.quests.completed[quest_name]
  end
  
  function hero:addItemByName(name)
    local item = make_inventory_item(Item.make_item(_ITEMS[name]))
    self.items[#self.items + 1] = item.item

    local inventory = self.graphicInventory
    if inventory then
      inventory:add_item(item)
    end
  end
  function hero:removeItemByName(name)
    for k,v in ipairs(self.items) do
      if v.item.name == name then
          local inventory = self.graphicInventory
          if inventory then
            inventory:remove_item(item)
          end
         table.remove(self.items,k)
         tmp = true
         break
      end
    end
  end
  function hero:add_item_to_list(item)
    self.items[#self.items + 1] = item
  end
  function hero:remove_item_from_list(inv_item)
     for k,v in ipairs(self.items) do
      if v == inv_item.item then
          local inventory = self.graphicInventory
          if inventory then
            inventory:remove_item(inv_item)
          end
         table.remove(self.items, k)
         return true
      end
     end
  end
  function hero:getItemByName(name)
    for k,v in ipairs(self.items) do
      if v.name == name then
        return v
      end
    end
    return nil
  end
  
  function hero:getItemById(id)
    for k,v in ipairs(self.items) do

      if v:getId() == id then
        return v
      end
    end
    return nil
  end

  function hero:getEquipById(id)
    for k,v in pairs(self.equipment) do

      if v ~= nil and v.getId and v:getId() == id then
        return v
      end
    end
    return nil
  end

  function hero:add_text_event(txt)
    self.newEventsList[#self.newEventsList + 1] = txt
  end
  
  function hero:set_equipment(item)
    local result = self:set_equipmentActivate(item)

    return result
  end

  function hero:set_equipmentActivate(item)     
    if self.flags.death then return end

    local frame           
 --   local tmp = item
    --local item = item.item
    local equipment = item and item.model
    frame = self.equipment.model.model:get_current_frame()

    for k,v in pairs(item.need_abilities) do
      if hero.stats[k] < v then
        hero:add_text_event(TEXTS.notEnoughSkills(transform_text[k], v))          
        return false
      end
    end
    if item == hero.equipment[item.equipment_bind] then
      return false
    end
    hero.equipment[item.equipment_bind] = item

    if equipment then
      equipment:set_position(hero.bound_box.x, hero.bound_box.y)
    end
    hero:set_animation(hero.animation.key_animation, frame, self.last_side)

    return true
  end

  function hero:unset_equipmentToInventory(item)    
    local result = self:unset_equipmentActivate(item)
    self:add_item_to_list(item)
    return result    
  end

  function hero:unset_equipment(item)
    local result = self:unset_equipmentActivate(item)

    return result
  end

  function hero:unset_equipmentActivate(item)
    if self.flags.death then return end
    local frame     
    local key_equipment = item.equipment_bind
    frame = self.equipment.model.model:get_current_frame()

    self.equipment[key_equipment] = nil
    self:set_animation(hero.animation.key_animation, frame, self.last_side)    
  end

  function hero:move_on_screen(x,y)
    hero.bound_box.x = hero.bound_box.x + x
    hero.bound_box.y = hero.bound_box.y + y

    for k,v in pairs(self.equipment) do
      v:move(x,y)
    end
  end   

  function hero:set_destroy_flag()
  end

  function hero:get_map_bound_box(self)
    local result = {["x"] = hero.bound_box.x + Map.x,
        ["y"] = hero.bound_box.y + Map.y,
        ["w"] = hero.bound_box.w,
        ["h"] = hero.bound_box.h}
    return result
  end
  function hero:get_bound_box(self)
    return hero.bound_box
  end
  function hero:add_experience(exp) 
    hero:add_text_event(TEXTS.newExperience(exp))
    self.experience = self.experience + exp
    local tmp = first_level * self.level
    if self.experience > tmp then
      self.level = self.level + 1
      hero:add_text_event(TEXTS.newLevel(self.level))
      self.experience = self.experience - tmp
      self.level_points = self.level_points + points_for_level
      hero:add_health(hero.stats.health)
      hero:add_mana(hero.stats.mana)

      self:add_experience(0)
    end
  end
  function hero:on_defense(attacker)  
    local tmp = 0
    if attacker.spell_type then
      tmp = Attack.count_spell_attack(attacker, self:sum_stats())
    else   
      tmp = Attack.count_mellee_attack(attacker:sum_stats(),self:sum_stats())
    end
    self:add_health(-tmp)                        
    hero:add_text_event(TEXTS.hurtFor(tmp))
    if self.health <= 0 then
  --   self:destroy_self()
      local cursor = GUI.get_cursor()
      cursor:set_clip(1,0)
      game_machine:add_event(self, "on_iter", function () end)
      hero.flags.death = true
      hero.sprite = ERPG_sprite.make(PATH_HERO .. "hero_death.png", {255,0,255,255})
      hero.render_objects = nil
  --x  hero:set_iter_function(on_iter_death)
    end
  end

  function hero:add_light()
    light = Lgt.make(300, {["r"]=70,["g"]=70,["b"]=255})
    light:setToField(hero.render_points[1].x, hero.render_points[1].y )
    light:turnOn()
  end
  function hero:add_mana(mana)
    Client:addAction("add_mana", hero.last_point[1].x, hero.last_point[1].y, hero.layer, {mana})
    self.mana = self.mana + mana
    if self.mana > self.stats.mana then
      self.mana = self.stats.mana
    end
  end

  function hero:try_spell(name)
    local sp = _SPELLS[name]

    if hero.mana >= sp.mana then
      self:add_mana(-sp.mana)
      return true
    end
  end

  local dump2 = hero.dump
  function hero:dump()
    local tmp = dump2(self)

    local equip = {}
    for k,v in pairs(self.equipment) do
     if v.name == nil then
        equip[k] = "model"
     else
        equip[k] = v:dump()
     end
    end

    local items = {}
    for k,v in pairs(self.items) do
      items[k] = v:dump()
    end
    
    tmp["quests"] = self.quests
    tmp["health"] = hero.health
    tmp["mana"] = hero.mana
    tmp["experience"] = hero.experience
    tmp["stats"] = hero.stats
    tmp["level_points"] = self.level_points
    tmp["items"] = items
    tmp["level"] = self.level
    tmp["equipment"] = equip
    tmp["map_name"] = Map.name

    return tmp
  end

  local load2 = hero.load2

  function hero:loadWithoutCalls(load_dump)
    hero:setConfigurationWithoutCallbacks(load_dump)

    hero.quests = load_dump.quests

    load2(self,load_dump)

    self["health"] = load_dump.health
    self["mana"] = load_dump.mana
    hero["items"] = {}

    for k, v in ipairs(load_dump.items) do
      local item = Item.make_item()
      item:load(v)
      self.items[#self.items + 1] = item
    end

    for k,v in pairs(load_dump.equipment) do
     if k ~= "model" then
        local item = Item.make_item()
        item:load(v)
        self:set_equipmentActivate(item)
     end
    end     

    self["quests"] = load_dump.quests
  end
  function hero:load(load_dump)
    hero:setConfiguration(load_dump)
    
    hero.quests = load_dump.quests

    load2(self,load_dump)

    self["health"] = load_dump.health
    self["mana"] = load_dump.mana
  
    hero["items"] = {}

    for k, v in ipairs(load_dump.items) do
      local item = Item.make_item()
      item:load(v)
      self.items[#self.items + 1] = item
    end

    for k,v in pairs(load_dump.equipment) do
     if k ~= "model" then
        local item = Item.make_item()
        item:load(v)
        self:set_equipmentActivate(item)
     end
    end     

    self["quests"] = load_dump.quests
    
    on_iter_after(hero)
    hero:set_iter_function(on_iter)
  end

  local ins = hero.insert

  function hero:insert(x,y)     
    ins(hero,x,y)
    
 --   Client:addAction("insert_hero", x,y, hero.layer)
  end

   return hero
end


