function make_monster(name, x,y)
   local out = DObj.make_object()
   out:setModel(object.animation)
   --out:insert(x,y)
   
   out["name"] = name
   out["stats"] = _BEASTIAR[name].stats
   out["health"] = _BEASTIAR[name].health
   out["color"] = _BEASTIAR[name].color

   local gm = get_game_machine()

   return out
end


function make_amazon(x,y)
   local out = DObj.make_object(_ANIMATION_AMAZON,x,y)
   
   out["name"] = "amazon"

   return out
end