dofile(PATH_GAME .. "elements.lua")

function make_animation_element(sprite,sound,frames_index,sound_index)
 local animation_element =   
   {
	 ["sound"] = sound,
	 ["sprite"] = sprite,
	 ["frames_index"] = frames_index,
	 ["sound_index"] = sound_index,
	 ["count"] = #frames_index,
   } 

 return animation_element
end

function make_animation()
   local animation = {["animations"] = {},
		      ["index_animation"] = 0,
		      ["current_animation"] = nil,
		      ["play_sound"] = 0,
		      ["frame_y"] = 0}

   local function playing_audio(self)
      self["play_sound"] = 0
      if self.current_animation.sound_index == nil then return end

      for k,v in ipairs(self.current_animation.sound_index) do
	 if self.index_animation == v then
	    self["play_sound"] = 1
	    break
	 end
      end  
   end
   
   function animation:add_animation(key,animation_element)
      self.animations[key] = animation_element
   end

   function animation:set_animation(key, start_frame_x,frame_y)
      if self.animations[key] then
	 self["current_animation"] = self.animations[key]
	 self["current_key"] = key
	 self["index_animation"] = start_frame_x or 0
	 self["frame_y"] = frame_y
	 self.current_animation.sprite:set_clip(self.current_animation.frames_index[self.index_animation],
						self.frame_y)
      
	 playing_audio(self) 
      else
	 print("animation non exist:", key, self.current_animation)
      end
   end

   function animation:move_frame(i)      
      if self["index_animation"] + i  > self.current_animation.count then 
	 self["index_animation"] = 1
      elseif self["index_animation"] + i < 1 then
	 self["index_animation"] = self.current_animation.count
      else
	 self["index_animation"] = self["index_animation"] + i      
      end
      self.current_animation.sprite:set_clip(self.current_animation.frames_index[self.index_animation],
					     self.frame_y)

      playing_audio(self)

      return self.index_animation
   end

   function animation:set_frame(i)
      self["index_animation"] = i      
      self.current_animation.sprite:set_clip(self.current_animation.frames_index[i],
					     self.frame_y)
      playing_audio(self)
      return self.index_animation
   end  

   function animation:get_current_sprite()
      return self.current_animation.sprite
   end

   function animation:get_current_sound()
      return self.current_animation.sound
   end
   function animation:get_play_sound()
      return self.play_sound
   end
   function animation:get_current_animation()
      return self.current_animation
   end
   function animation:get_frame_index()
      return self.index_animation,self.frame_y,self.current_key
   end
   function animation:get_count_frame()
      return self.current_animation.count
   end
   return animation
end

function make_model(model_config)
   local sprites = {}
   local sounds = {}
   local animation = make_animation()

   local graphic_element = make_graphic_element(0,0)
   local model = {}
   local GAME_MACHINE = get_game_machine()
   local size = nil

   if model_config == nil then 
      print("Bad configure")
      return
   end

   for k,v in pairs(model_config.sprites) do
      local sprite = ERPG_sprite.make(v.path, {255,0,255})
      sprite:set_clips(v.clipx,v.clipy)
      sprites[k] = sprite
      size = sprite:get_clip_size(sprite)  
   end
   
   if model_config.sounds then
      for k,v in pairs(model_config.sounds) do
	 sounds[k] = ERPG_Sound.make(v.path)
      end
   end

   for k,v in pairs(model_config.animations) do
      local sprite = sprites[v.sprite]
      local sound = v.sound and sounds[v.sound.sound] 

      animation:add_animation(k,make_animation_element(sprite,sound,v.frames,
						       v.sound and v.sound.sound_start))
   end   

   model["animation"] = animation
   model["graphic_element"] = graphic_element
   model["frame_index"] = 0
   model["time_animation"] = 1   

   function model:get_matricies_collision()
      if model_config.matricies_collision then
	 return model_config.matricies_collision
      end
   end
   local x,y = model_config.move_x or 0, model_config.move_y or 0
   graphic_element:move(x,y)
   
   function model:set_animation(key_animation,start_x, side)
      local side = side
      if side < 1 then
	     side = 1
      end      
      side = side - 1
      
      if self.graphic_element.sound and self.graphic_element.sound[2] then
	     self.graphic_element.sound[2]:stop()
      end

      self["animation"]:set_animation(key_animation, start_x, side)
      self.graphic_element:set_sprite(self.animation:get_current_sprite())
      self.graphic_element:set_sound(self.animation:get_current_sound(),
				     self.animation:get_play_sound())      
   end
   
   function model:next_animation(x)
      local frame
      frame = self.animation:move_frame(x)
      self.graphic_element:set_sound(self.animation:get_current_sound(),
				     self.animation:get_play_sound())
      return frame
   end

   function model:move(x,y)
      self.graphic_element:move(x,y)
   end

   function model:set_position(x,y)
      self.graphic_element:set_position(x+model_config.move_x,y+model_config.move_y)
   end

   function model:get_current_frame()
      return self.animation:get_frame_index()
   end
   function model:get_current_animation()
      return self.animation:get_current_animation()
   end
   function model:get_size()      
      return size
   end
   function model:get_count_frame()
      return self.animation:get_count_frame()
   end

   return model
end
