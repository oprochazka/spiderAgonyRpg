local function init_hero( model )
   local equip_armor = {}
   local equip_weapons = {}
   local equipment = {}
   equip_armor["head"] = nil
   equip_armor["body"] = nil
   equip_armor["leg"] = nil
   equip_armor["foots"] = nil
   equip_armor["hands"] = nil

   equip_weapons["back"] = nil
   equip_weapons["right_hand"] = nil
   equip_weapons["left_hand"] = nil

   hero["equip_armor"] = equip_armor
   hero["equip_weapons"] = equip_weapons
   hero["equipment"] = equipment
   
   hero["fast_movement"] = 1

   hero["model"] = model

   hero["renderer"] = {}

   return hero
end
--index_anim = {i,i,i,i...}


local function set_armor(hero,key, armor)
   hero.equip_armor[key] = armor
end
local function set_weapon(hero,key, weapon)
   hero.equip_weapons[key] = weapon
end

local function hero_move(hero)

end
-- {x,y}, {x,y}
function make_main_hero(screen_position, land_position)
   local move_hero = make_model_sprite(PATH_HERO .. "model.png",8,8)
   local model = make_model()
   model:set_animation("move", {3,4,5,6,7,8}, move_hero)
   model:set_animation("before_move", {2}, move_hero)
   model:set_animation("after_move", {2}, move_hero)
   model:set_animation("stay", {1})

   local hero = init_hero()


   
   
end