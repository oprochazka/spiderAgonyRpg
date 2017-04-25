function make_model(time_anim, animation)
   local model = {}
   
   model["animation"] = animation or {}   
   model["time_anim"] = time_anim      

   local function set_animation(self, key, index_anim, sprite)   
      self.animation[key] = { index_anim, sprite }
   end
   
   model["set_animation"] = set_animation

   return model
end

function make_model_sprite(path ,x_clips,y_clips)
   local sprite = ERPG_Sprite.make_sprite(path, {255,0,255})
   sprite:set_clips(x_clips,y_clips)
   return sprite
end