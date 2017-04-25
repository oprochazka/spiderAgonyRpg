local function add_health(self,char,item)
   local health = self.health
   if char.add_health then
      char:add_health(health)
      return true
   end
   return false
end

local function add_mana(self,char, item)
   local mana = self.mana
   if char.add_mana then
      char:add_mana(mana)    
      return true
   end
   return false
end

_ITEMS = {
   ["heal_potion"] = {
      ["type"] = "potion",
      ["name"] = "heal_potion",
      ["path_inventory_picture"] = PATH_SPRITES .. "heal_potion.png",
      ["health"] = 100,
      ["on_activate"] = add_health,
      ["info"] = "Léčivý lektvar přídá 100 životů"
      
   },
   ["mana_potion"] = {
      ["type"] = "potion",
      ["name"] = "mana_potion",
      ["path_inventory_picture"] = PATH_SPRITES .. "mana_potion.png",
      ["mana"] = 40,
      ["on_activate"] = add_mana,
      ["info"] = "Lektvar který dodá manu 40"
      
   },
   ["tunic"] = {
      ["type"] = "equipment",
      ["name"] = "tunic",
      ["path_inventory_picture"] = PATH_SPRITES .. "tunic_inv.png",
      ["animation"] = _ANIMATION_TUNIC,
      ["need_abilities"] = {
	 ["strengh"] = 0,
	 ["dexterity"] = 0,
	 ["wisdom"] = 0},
      ["stats"] = {
	 ["armor"] = 10
      },
      ["equipment_bind"] = "tunic",
      ["info"] = "Tunika přídá 10 k obraně"
   },
   ["trousers"] = {
      ["type"] = "equipment",
      ["name"] = "trousers",
      ["path_inventory_picture"] = PATH_SPRITES .. "trousers_inv.png",
      ["animation"] = _ANIMATION_TROUSERS,
      ["need_abilities"] = {
	 ["strengh"] = 50,
	 ["dexterity"] = 0,
	 ["wisdom"] = 0},
      ["stats"] = {
	 ["armor"] = 20
      },
      ["equipment_bind"] = "trousers",
      ["info"] = "Kalhoty přídá 20 k obraně"
   },
   ["boots"] = {
      ["type"] = "equipment",
      ["name"] = "boots",
      ["path_inventory_picture"] = PATH_SPRITES .. "boots_inv.png",
      ["animation"] = _ANIMATION_BOOTS,
      ["need_abilities"] = {
	 ["strengh"] = 0,
	 ["dexterity"] = 0,
	 ["wisdom"] = 0},
      ["stats"] = {
	 ["armor"] = 10
      },
      ["equipment_bind"] = "boots",
      ["info"] = "Boty přídá 10 k obraně"
   },
   ["sword"] = {
      ["type"] = "equipment",
      ["name"] = "sword",
      ["path_inventory_picture"] = PATH_SPRITES .. "sword_inv.png",
      ["animation"] = _ANIMATION_SWORD,
      ["need_abilities"] = {
	 ["strengh"] = 0,
	 ["dexterity"] = 0,
	 ["wisdom"] = 0},
      ["stats"] = {
	 ["attack"] = 20
      },
      ["equipment_bind"] = "right_hand",
      ["info"] = "Meč přídá 20 k útoku"
   },
   ["helmet"] = {
      ["type"] = "equipment",
      ["name"] = "helmet",
      ["path_inventory_picture"] = PATH_SPRITES .. "helmet_inv.png",
      ["animation"] = _ANIMATION_HELMET,
      ["need_abilities"] = {
	 ["strengh"] = 10,
	 ["dexterity"] = 13,
	 ["wisdom"] = 0},
      ["stats"] = {
	 ["armor"] = 20
      },
      ["equipment_bind"] = "hat",
      ["info"] = "Helma přídá 20 k obraně"
   },
   ["ring_of_earth"] = {
      ["type"] = "quest_item",
      ["name"] = "ring_of_earth",
      ["path_inventory_picture"] = PATH_SPRITES .. "ring_earth.png",
      ["info"] = "Prsten který musíš odevzdat"
   }
}