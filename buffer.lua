Ltg = require(PATH_GAME .. "light")
 
 

function buffer()
	local light = Lgt.make( 200,  {["r"] = 255,["g"] = 255,["b"] = 100 }) 
	light:setToField(90, 227 )
	light:turnOn()

	local simple = SO.make()
	simple:setConfiguration("shelve")
	simple:insert(95,24)
	UserUI.connectedHero:add_light()

	print(DObj.get_element(352).name)
--[[
	local light = Lgt.make( 400 ) 
	light:setToField(80, 227 )

	local light = Lgt.make( 400 ) 
	light:setToField(80, 240 )

	local light = Lgt.make( 400 ) 
	light:setToField(100, 240 )
]]
--local light = Lgt.make( 240 ) 
--light:setToField(80, 227 )
--   Brush = require(PATH_EDITOR .. "brush")
   --   Map.load(PATH_MAPS .. "test4")


-- the code to debug ends here; reset the hook

--[[
--dofile(PATH_GAME .. "objects_render.lua")
local count = 0
for k,v in ipairs(Map.objects_renderer) do
	count = count + #v.line

end
SObj.fields4 = nil

print(count)]]
--[[
for k,v in pairs(Map.objects_renderer) do
   print("---------------------------------------")
   for x,value in pairs(v.line) do 
      if value.dock then
	 print("vse",value.bound_box.x,value.bound_box.y,v.y)
      end
      if v.y > 300 and v.y < 600 then
--	 print("--> ", value.bound_box.x,value.bound_box.y)
	-- if value.bound_box.x < 354 then
	 if value.bound_box.y == 232 then
--	    value.bound_box.x = value.bound_box.x  - 500
--	    value.bound_box.y = value.bound_box.y - 100
	 end

	    if  value.bound_box.y == 248-100 or value.bound_box.y == 264-100 or value.bound_box.y == 280-100 or value.bound_box.y == 232 - 100 then
	       --	       value.bound_box.x = value.bound_box.x  - 500
	       print("WHAT?",value.bound_box.x,value.bound_box.y,value.elem_x,value.elem_y,value.progress_x,value.progress_y,value.pos_x,value.pos_y,v.y)
--	       print("WTF", v.y, #v.line,"CO???")

	    elseif value.bound_box.y == 280 then
	       
--	       print("WHAT?",value.bound_box.x,value.bound_box.y,value.elem_x,value.elem_y,value.progress_x,value.progress_y)
--	       print("WTF", v.y, #v.line,"CO???")

--	       print("-->",value.bound_box.x,value.bound_box.y)
	    end
	    if value.bound_box.x == 188 and value.bound_box.y == 264 then
--	       value.bound_box.y = value.bound_box.y - 100
	    end     
      end            
   end
   end]]


 --   profiler:stop()

 --   local outfile = io.open( "profile.txt", "w+" )
 --   profiler:report( outfile )
--    outfile:close()
end
