local Inventory = {}
Inventory["inv_items"] = {}
function make_inventory_item(item,on_click_func)
   local inv_item = GUI.make_sprite(item.inventory_sprite)
   local tmp = 0
   inv_item["item"] = item
   inv_item["apply_function"] = on_click_func
   inv_item["inMotion"] = false
   local function on_motion(self,motion) 
      if motion.press_motion == "left" then
         inv_item["inMotion"] = true
      	 self.in_motion = true
      	 if tmp == 0 then
      	    local w, h = self.sprite:get_max_size()
      	    print("--MOTION---")
      	    self.sprite:set_size(0,0,w,h)
      	    self.bound_box.w = w
      	    self.bound_box.h = h
      	    if hero and item.item_config.info then
      	       hero:add_text_event("O Předmětu: <color: 100,100,190>" .. item.item_config.info)
      	    end
      	    tmp = 1
      	 end
   	 
   	 inv_item:move(motion.x, motion.y)
   	 GUI.main_window:set_last_render_object(inv_item)
   	 local gm = get_game_machine()
   	 local fm = gm:get_main_frame()
      end
   end

   local function on_release_motion(self,args)
      GUI.main_window:remove_last_render_object()
      
      if args[2].name == "hero_dialog" or args[2].parrent.name == "hero_dialog" then
         if args[2].parrent.name == "hero_dialog" then
            args[2] = args[2].parrent
         end
         if self.parrent.parrent.name ~= "hero_dialog" then
            GUI.send_event(self.parrent,"remove_item",self)
            GUI.send_event(args[2], "change_item", {["item"]=self,["parrent"] = self.parrent})
         else
            self:set_position(self.parrent.bound_box.x,self.parrent.bound_box.y)
            GUI.send_event(self.parrent,"on_refresh")
         end
      elseif args[2].name == "inventory_element" and args[2]:get_item() == nil then
   	  GUI.send_event(self.parrent,"remove_item",self)
   	  GUI.send_event(args[2], "on_set_item", self)

   	  GUI.send_event(args[2], "change_item", self)
      else	 
   	  self:set_position(self.parrent.bound_box.x,self.parrent.bound_box.y)
   	  GUI.send_event(self.parrent,"on_refresh")
      end   
      tmp = 0
      inv_item["inMotion"] = false
   end
 
   GUI.add_event(inv_item,"on_release_motion", on_release_motion)
   GUI.add_event(inv_item,"on_motion",on_motion)

   return inv_item
end

local function on_change_item(self,item)
   GUI.send_event(self.parrent,"change_item",item)
end
local function on_remove_item(self, item)
   GUI.send_event(self.parrent,"remove_item",item)
end

function make_inventory_element()
   local frame_color = _INVENTORY_ELEMENT.frame_color
   local frame_focus_color = _INVENTORY_ELEMENT.frame_focus_color
   local fill_color = _INVENTORY_ELEMENT.frame_focus_color
   local sprite = nil
   local size = _INVENTORY_ELEMENT.size
   local margin = _INVENTORY_ELEMENT.margin
   
   local frame_in = GUI.make_frame_element({margin,margin,size-(margin*2),size-(2*margin)},fill_color)
   local element = GUI.make_frame_element({0,0,size,size}, frame_color)

   frame_in.name = "inventory_element"
   element.name = "inventory_element"

   element["item"] = nil
   
   local function on_click(self,mouse)
      if element.item then
	 GUI.send_event(element.parrent.parrent.parrent,"on_click_item", {element.item,mouse})
      end
   end  

   function element:set_item(item)
      item:set_position(frame_in.bound_box.x,frame_in.bound_box.y)
      element["item"] = item
      GUI.compose_object(frame_in, item)
      GUI.add_event(item,"on_click", on_click)   
      GUI.send_event(element.parrent.parrent,"on_scroll", {0,0})
   end
   function element:get_item()
      return element.item
   end   
   
   function frame_in:get_item()
      return element.item
   end

   function element:set_focus()
      element:set_color(frame_focus_color)
   end
   
   function element:deset_focus()
      element:set_color(frame_color)			
   end

   function element:remove_item()
      frame_in.objects = {}
      self.item = nil
   end


   local function on_remove_item_element(self, item)
      self:remove_item()
      GUI.send_event(self.parrent,"remove_item",item)
   end   

   local function on_set_item(self, item)
      GUI.send_event(self.parrent,"on_set_item", item)
   end
   local function on_set_item_elem(self, item)
      self:set_item(item)
   end

   local function on_refresh(self)
      GUI.send_event(self.parrent.parrent.parrent,"on_scroll", {0,0})
   end

   local function on_r_m(self,mouse)
      GUI.send_event(self.parrent, "on_release_motion", mouse)
   end

   GUI.compose_object(element,frame_in)

   GUI.add_event(frame_in,"change_item",on_change_item)
   GUI.add_event(element,"change_item",on_change_item)

   GUI.add_event(frame_in,"on_click",on_click)
   GUI.add_event(frame_in,"on_set_item", on_set_item) 
   GUI.add_event(frame_in, "remove_item", on_remove_item)

   GUI.add_event(element, "on_set_item", on_set_item_elem)
   GUI.add_event(element, "remove_item", on_remove_item_element)   

   GUI.add_event(frame_in, "on_refresh", on_refresh)   

   GUI.add_event(frame_in,"on_release_motion", on_r_m )
   GUI.add_event(element,"on_release_motion", on_r_m )
   return element
end

function make_inventory_line(count, elements_list)
   local size = _INVENTORY_ELEMENT.size 
   local line = make_empty_frame({0,0, size * count, size})  
   local first_empty = 1

   for k=1,count do
      local element = (elements_list and elements_list[k]) or make_inventory_element()
      element:move((k - 1) * size, 0)
      GUI.compose_object(line, element)
   end
   
   function line:add_element()
      local element = make_inventory_element()
      element:set_position(#line.objects*size + line.bound_box.x,line.bound_box["y"])
      self:scale(size,0)
      print(element.name, element.bound_box.x,element.bound_box.y)
      GUI.compose_object(line,element)
   end

   function line:add_item(item)
      for k,v in ipairs(line.objects) do
   	 if v:get_item() == nil then
   	    v:set_item(item)
   	    return true
   	 end
      end
   end
   
   GUI.add_event(line,"change_item", on_change_item)
   GUI.add_event(line,"remove_item", on_remove_item)
   return line, line.objects
end

function make_inventory(count, on_click_item, height )
   local element_size = _INVENTORY_ELEMENT.size
   local background_color = _INVENTORY.background_color
   local margin = _INVENTORY.margin
   local elements_on_line = _INVENTORY.elements_line
   local lines = {}
   local items = {}



   for k=1,(math.floor(count/elements_on_line)) do
      local line = make_inventory_line(elements_on_line)
      lines[#lines+1] = line
   end
   if count%elements_on_line ~= 0 then
      local line = make_inventory_line(count%elements_on_line)
      lines[#lines+1] = line
   end

   local layout = GUI.make_layout(lines,
				  {0,0,0,height or _INVENTORY.height},0)

   GUI.add_event(layout,"change_item", on_change_item)
   GUI.add_event(layout,"remove_item", on_remove_item)

   local inventory = GUI.make_frame({0,0,0,0},layout, nil, background_color)

   inventory["items"] = items
   inventory:move(0,20)
   
   function inventory:add_element()
      local last_line = lines[#lines]
      if #last_line.objects < elements_on_line then
	      last_line:add_element()
      else
   	 local line = make_inventory_line(1)
   	 lines[#lines+1]=line
   	 layout:add_object(line)
      end      
   end
   function inventory:remove_item(item)
      local tmp
      for k,line in ipairs(layout.objects) do
   	 for k, field in ipairs(line.objects) do
   	    tmp = field:get_item()
   	    
   	    if tmp == item then
   	       field:remove_item()
   	       break
   	    end
   	 end
      end
      return tmp
   end
   function inventory:remove_items()
      for k,line in ipairs(layout.objects) do
   	 for k, field in ipairs(line.objects) do
   	    local tmp = field:get_item()	    
   	    if tmp then
   	       field:remove_item()
   	    end
   	 end
      end      
   end

   function inventory:refresh(storage)
     for k,line in ipairs(layout.objects) do
       for k, field in ipairs(line.objects) do
          local tmp = field:get_item()     
          if tmp and tmp.inMotion == false then
             field:remove_item()
          end
       end
      end  
      for k,v in ipairs(storage) do
         if v.inMotion == false then
            self:add_item(v)
         end
      end
   end

   function inventory:get_invetory_items()
      local out = {}
      for k,line in ipairs(layout.objects) do
   	 for k, field in ipairs(line.objects) do
   	    local tmp = field:get_item()
   	    if tmp then
   	       out[#out + 1] = tmp
   	    end
   	 end
      end
      return out
   end
   function inventory:get_invetory_item(name)
      for k,line in ipairs(layout.objects) do
   	 for k, field in ipairs(line.objects) do
   	    local tmp = field:get_item()
   	    if tmp and tmp.item.name == name then
   	       return tmp
   	    end
   	 end
      end
   end
   function inventory:get_invetory_item_id(id)
      for k,line in pairs(layout.objects) do
       for k, field in pairs(line.objects) do
          local tmp = field:get_item()

          if tmp and tmp.item:getId() == id then
             return tmp
          end
       end
      end
   end
   function inventory:add_line()
      local line = make_inventory_line(elements_on_line)
      lines[#lines+ 1] = line
      layout:add_object(line)
   end

   function inventory:remove_line()
      layout:remove_last_object()
   end

   function inventory:add_item(item)
      for k,v in ipairs(lines) do
   	 if v:add_item(item) == true then

         return true
   	 end
      end
      return nil 
   end

   function inventory:change_count_element_on_line(count)
      
   end

   local function on_click_item_inv(self,args)
      if on_click_item then
	      on_click_item(args[1],args[2])
      end
   end

   function inventory:on_destroy()        
      local g_machine = get_game_machine()
      local frame = g_machine:get_main_frame()
      GUI.main_window:remove_last_render_object()
      for k,v in ipairs(frame.objects) do
   	 if v == self then
   	    table.remove(frame.objects,k)
   	    break
	      end
      end
   end
 
   GUI.add_event(inventory,"on_click_item", on_click_item_inv)
   GUI.add_event(inventory,"on_destroy", inventory.on_destroy)
   return inventory
end

return Inventory