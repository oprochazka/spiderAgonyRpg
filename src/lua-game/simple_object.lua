local SO = {}
dofile(PATH_CONFIGS .. "simpleObjectsConfiguration.lua")

SO["SimpleObjectConfiguration"] = _SIMPLE_OBJECT_CONFIGURATION

function SO.make(configuration)
	local element = make_graphic_element(0,0)
	local game_machine = get_game_machine()
	element["type"] = "SimpleObject"	
	element["data"] = {}
	element["EId"] = IdG.getId()
	
	local offsetX = 0
	local offsetY = 0

   	function element:setConfiguration(configuration)
	   	element["name"] = configuration
	   	configuration = _SIMPLE_OBJECT_CONFIGURATION[configuration]
	   
	   	element["on_iter"] = configuration.on_iter
	   	element["on_draw"] = configuration.on_draw
		element["through"] = configuration.through
		element["layer"]   = configuration.layer or 2
		element["clipX"] = configuration.clipX or 1
		element["clipY"] = configuration.clipY or 1

	   	offsetX = configuration.offsetX or 0
	   	offsetY = configuration.offsetY or 0

	   	local sprite = ERPG_sprite.make(configuration.path, {255,0,255})

	   	sprite:set_clips(self.clipX, self.clipY)
		sprite:set_clip(0, 0)

   		element:set_sprite(sprite)   

   		if configuration.on_iter then
   			game_machine:add_event(element, "on_iter", configuration.on_iter)		
   		end
	end

	function element:load(loadConfig)
		local x,y = loadConfig.fieldPosition.x, loadConfig.fieldPosition.y
		element:setConfiguration(loadConfig.name)
		element:insert(x,y)
	end

   	function element:insert(x,y)
   		self["fieldPosition"] = {["x"] = x, ["y"] = y }
   		MpR.set_element(x, y, self,self.layer)
   		local x,y = Tiles.tile_to_point(x,y)

   		self:set_position(x + offsetX,y + offsetY - self.bound_box.h + (Tiles.tile_size.h/2))
   	end
   
  	function element:dump()
      	 local dump = {}
      	 dump["id"] = Map.get_id()
      	 dump["type"] = "SimpleObject"
      	 dump["name"] = self.name
      	 dump["fieldPosition"] = self.fieldPosition	
      	 dump["data"] = self.data

      	 return dump
  	end

   	return element
end


return SO