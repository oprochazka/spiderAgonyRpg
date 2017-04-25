_BESTIAR = {
   ["spider"] = {
      ["preview"] = PATH_SPRITES .. "spider_prew.png",
      ["animation"] = _ANIMATION_SPIDER,
      ["stats"] = {
   	 ["health"] = 30,
   	 ["strengh"] = 6,
   	 ["dexterity"] = 10,
   	 ["wisdom"] = 0,
   	 ["mana"] = 0,
   	 ["attack"] = 10,
   	 ["armor"] = 20
      },      
      ["challange"] = "mellee",
      ["range"] = 1,
      ["experience"] = 50,
      ["movementSpeed"] = 40,
      ["attackSpeed"] = 500,
      ["on_attack"] = nil,
      ["on_iter"] = AI.smart_inteligence
--      ["on_draw"] = AI.smart_inteligence
   },
   ["spidermut"] = {
      ["preview"] = PATH_SPRITES .. "spider_prew.png",
      ["animation"] = _ANIMATION_SPIDERMUT,
      ["stats"] = {
   	 ["health"] = 700,
   	 ["strengh"] = 20,
   	 ["dexterity"] = 20,
   	 ["wisdom"] = 25,
   	 ["mana"] = 0,
   	 ["attack"] = 40,
   	 ["armor"] = 60
      },
      ["challange"] = "mellee",
      ["range"] = 1,
      ["movementSpeed"] = 26,
      ["attackSpeed"] = 600,
      ["experience"] = 250,
      ["on_attack"] = nil,
      ["on_iter"] = AI.smart_inteligence
--      ["on_draw"] = AI.smart_inteligence
   },
   ["spider_blue"] = {
      ["preview"] = PATH_SPRITES .. "spider_prew_blue.png",
      ["animation"] = _ANIMATION_SPIDER,
      ["stats"] = {
   	 ["health"] = 50,
   	 ["strengh"] = 6,
   	 ["dexterity"] = 10,
   	 ["wisdom"] = 20,
   	 ["mana"] = 0,
   	 ["attack"] = 20,
   	 ["armor"] = 20
      },  
      ["color"] = {["r"] = -60, ["g"] = -60, ["b"] = 160},
      ["challange"] = "mellee",
      ["range"] = 1,
      ["experience"] = 100,
      ["movementSpeed"] = 15,
      ["attackSpeed"] = 200,
      ["on_attack"] = nil,
      ["on_iter"] = AI.smart_inteligence
--      ["on_draw"] = AI.smart_inteligence
   },
   ["spider_green"] = {
      ["preview"] = PATH_SPRITES .. "spider_prew_green.png",
      ["animation"] = _ANIMATION_SPIDER,
      ["stats"] = {
   	 ["health"] = 90,
   	 ["strengh"] = 20,
   	 ["dexterity"] = 10,
   	 ["wisdom"] = 70,
   	 ["mana"] = 0,
   	 ["attack"] = 30,
   	 ["armor"] = 50
      },  
      ["color"] = {["r"] = -60, ["g"] = 160, ["b"] = -60},
      ["challange"] = "mellee",
      ["range"] = 1,
      ["experience"] = 300,
      ["movementSpeed"] = 30,
      ["attackSpeed"] = 300,
      ["on_attack"] = nil,
      ["on_iter"] = AI.smart_inteligence
--      ["on_draw"] = AI.smart_inteligence
   },

}
 