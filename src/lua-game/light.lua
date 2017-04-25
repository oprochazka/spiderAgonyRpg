local Lgt = {}

Lgt["layer"] = 1
Lgt["mapLight"] = {["r"] = 20, ["g"] = 20, ["b"] = 20}
local function setTileLight(RGBLight, x,y)
	local element = {["name"] = "", ["RGBLight"] = true, ["position"] = true}

	element["name"] = "tileLight"
	element["RGBLight"] = RGBLight
	element["position"] = {["x"] = x, ["y"] = y}
	MpR.setLightElement(x,y,element)

	return element
end

local function dedLight(elem, RGBLight)
	elem.RGBLight.r = elem.RGBLight.r - RGBLight.r
	elem.RGBLight.g = elem.RGBLight.g - RGBLight.g
	elem.RGBLight.b = elem.RGBLight.b - RGBLight.b

	if elem.RGBLight.r == 0 and elem.RGBLight.g == 0 and elem.RGBLight.b == 0 then
		MpR.removeLightElement(elem.position.x, elem.position.y)
	end
end

local function addLightField(elem, RGBLight)
	elem.RGBLight.r = elem.RGBLight.r + RGBLight.r
	elem.RGBLight.g = elem.RGBLight.g + RGBLight.g
	elem.RGBLight.b = elem.RGBLight.b + RGBLight.b
end


local function refreshLight(self)
	local r = self.sizeR
	local x,y = Tiles.tile_to_point(self.position.x, self.position.y) 
	local minX = x - r
	local minY = y - r
	local maxW = x + r
	local maxH = y + r

	local minXpoint, minYpoint = Tiles.point_to_tile(minX, minY)
	local maxWpoint, maxHpoint = Tiles.point_to_tile(maxW, maxH)

	local halfOfY = math.floor((maxHpoint - minYpoint) / 4)
	
	for yC = minYpoint, maxHpoint  do
	    for xC = minXpoint, maxWpoint do
	    	local xCp,yCp = Tiles.tile_to_point(xC,yC)
	    	local result, far = BasicMath.intersectCircle(xCp,yCp, x, y, r)

			if result then
	    		local divisionLightRed = ((far*(self.RGBLight.r))/r)
				local divisionLightGreen = ((far*(self.RGBLight.g ))/r)
				local divisionLightBlue = ((far*(self.RGBLight.b ))/r)

				local RGB = {["r"] = divisionLightRed,["g"] = divisionLightGreen,["b"] = divisionLightBlue}
			
				self.lightMap[#self.lightMap + 1] = {["RGB"] = RGB, ["position"] = {["x"] = xC, ["y"] = yC}}
			end
	    end
	end
end

function Lgt.make( sizeR, addLight, middleLight )
	local element = {}
	local addLight = addLight or {["r"] = 200,["g"] = 200,["b"] = 200}
	element["name"] = "light"
	element["sizeR"] = sizeR
	element["light"] = false
	element["last_position"] = {["x"] = 0, ["y"] = 0} 
	element["position"] = {["x"] = 0, ["y"] = 0}
	element["RGBLight"] = middleLight or addLight
	element["lightMap"] = {}
	element["lastLight"] = {}

	refreshLight(element)

	local function setLight(x,y)
		local x1,y1 = Tiles.tile_to_point(x,y)
		local x2,y2 = Tiles.tile_to_point(element.last_position.x,element.last_position.y )
		local x = x1 - x2
		local y = y1 - y2

		if x - element.last_position.x == 0 and y - element.last_position.y  == 0 then
			value.position.x = x
			value.position.y = y
			for k,value in ipairs(element.lightMap) do
				local lightTile = MpR.getLightElement(value.position.x, value.position.y)
				if lightTile == nil then
					lightTile = setTileLight({["r"] = 0, ["g"] = 0, ["b"] = 0}, 
						value.position.x, value.position.y)
				end

				addLightField(lightTile, value.RGB)
			end
			return
		end

		for k,value in ipairs(element.lightMap) do
			local x2,y2 = Tiles.tile_to_point(value.position.x,value.position.y)
			
			local x3,y3 = Tiles.point_to_tile(x2+x,y2+y)

			value.position.x = x3
			value.position.y = y3

			local lightTile = MpR.getLightElement(value.position.x, value.position.y)
			if lightTile == nil then
				lightTile = setTileLight({["r"] = 0, ["g"] = 0, ["b"] = 0}, 
					value.position.x, value.position.y)
			end

			addLightField(lightTile, value.RGB)
		end
	end

	function element:turnOn()
        if element.light == true then
           return
        end
        
		element["light"] = true
		setLight(element.position.x,element.position.y)
	end

	function element:turnOff()
	 	if element.light == false then
           return
        end
        element.last_position.x = element.position.x
		element.last_position.y = element.position.y
		element["light"] = false
		element:removeLight()
	end

	function element:setToField(x,y)
		local isLight = element.light
		
		if element.position.x == x and element.position.y == y then
			return
		end
		if element.light == false then
			element.position.x = x
			element.position.y = y

			return 
		end 

		element.last_position.x = element.position.x
		element.last_position.y = element.position.y

		element:removeLight()
		setLight(x,y)

		element.position.x = x
		element.position.y = y
	end

	function element:removeLight()
	--[[	for k,v in ipairs(element.lastLight) do
			dedLight(v.tile, v.RGB)	
		end
			element["lastLight"] = {}]]
	
		for k,value in ipairs(element.lightMap) do
			x = value.position.x  
			y = value.position.y 

			local lightTile = MpR.getLightElement(x,y)
			if lightTile == nil then
				return
			end

			dedLight(lightTile, value.RGB)
		end
	end
	function element:destroy()
	--	element:turnOff()
		element:removeLight()
	end

	return element
end

function Lgt.getRGBLight(RGBLight, outTable)
	local out = outTable or {["r"] = 0, ["g"] = 0, ["b"] = 0}

	out.r = RGBLight.r + Lgt.mapLight.r
	out.g = RGBLight.g + Lgt.mapLight.g
	out.b = RGBLight.b + Lgt.mapLight.b

--	out.r = out.r - 3 + math.random(6)
--	out.g = out.g - 3 + math.random(6)
--	out.b = out.b - 3 + math.random(6)

	if out.r > 200 then
		out.r = 200
	end
	if out.g > 200 then
		out.g = 200
	end
	if out.b > 200 then
		out.b = 200
	end

	if out.r < Lgt.mapLight.r then
		out.r =  Lgt.mapLight.r
	end
	if out.g < Lgt.mapLight.g then
		out.g =  Lgt.mapLight.g
	end
	if out.b < Lgt.mapLight.b then
		out.b =  Lgt.mapLight.b
	end

	return out
end

function Lgt.getCorrectRGB(RGBLight, outTable)
	local out = outTable or {["r"] = RGBLight.r, ["g"] = RGBLight.g, ["b"] = RGBLight.b}


	out.r = RGBLight.r
	out.g = RGBLight.g
	out.b = RGBLight.b

--	out.r = out.r - 3 + math.random(6)
--	out.g = out.g - 3 + math.random(6)
--	out.b = out.b - 3 + math.random(6)

	if out.r > 255 then
		out.r = 255
	end
	if out.g > 255 then
		out.g = 255
	end
	if out.b > 255 then
		out.b = 255
	end

	if out.r < 0 then
		out.r =  0
	end
	if out.g < 0 then
		out.g =  0
	end
	if out.b < 0 then
		out.b =  0
	end

	return out
end

return Lgt