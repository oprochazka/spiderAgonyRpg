

local function writebytes(x)
    local b2=string.char(x%256) x=(x-x%256)/256
    local b1=string.char(x%256) x=(x-x%256)/256
    
    return b2,b1
end
function bytes(x)
    local b2=x%256  x=(x-x%256)/256
    local b1=x%256  x=(x-x%256)/256

    return string.char(b1,b2)
end

function write_int(x)
   local b4=x%256  x=(x-x%256)/256
   local b3=x%256  x=(x-x%256)/256
   local b2=x%256  x=(x-x%256)/256
   local b1=x%256  x=(x-x%256)/256
   
   return string.char(b1,b2,b3,b4)
end

local function on_click_save(self, mouse)

   local function on_save( path)
      local size_map = Map.size_map
      local output = assert(io.open(PATH_MAPS .. path .. ".map", "wb"))
      local max_x = #Tiles.fields[1]
      
      output:write(bytes(size_map[1]))
      output:write(bytes(size_map[2]))  
      
      for y=1, #Tiles.fields do
	 for x=1, max_x do
	    local num = Tiles.get_element(x,y)
	
	    output:write(string.char(num))
	 end
      end
      output:close()

      MpR.save(path)
   end

   local save = GUI.make_input_frame("SAVE", 70,"txt",on_save)  
   GUI.compose_object(self.parrent.parrent, save)   
   GUI.send_event(self.parrent.parrent, "on_activate", save)
   GUI.send_event(self.parrent.parrent, "on_click_save")
   GUI.add_event(save,"on_click",function (self) 
		    GUI.send_event(self.parrent,"on_activate", save) end)
   GUI.add_event(save, "on_activate", function (self) 
		    GUI.send_event(self.parrent,"on_activate", save) end)
end

local function on_click_load(self, mouse)
   local function on_load(path)
      local result = path

--      result =  string.match(path,"%w+")
      result = path
      Map.load(result, true)
      Map.render(0,0)   
--      mini_map = Mini_map.make()

      GUI.send_event(self.parrent.parrent,"on_change_map")
   end
   local fB = GUI.make_file_browser(PATH_MAPS,on_load)

   GUI.compose_object(self.parrent.parrent, fB)
end

local Menu = {}

function Menu.make()
   local menu_bar = make_layout_buttons({{"SAVE", on_click_save}, {"LOAD", on_click_load}})

   return menu_bar
end

return Menu