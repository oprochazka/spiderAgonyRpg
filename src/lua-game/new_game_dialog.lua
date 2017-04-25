local NGD ={}

local function none()
   return
end
   

function NGD.stats_dialog(number,level_hero,stats,refresh)
   local width = GUI._COUNTER_BAR.name_width
   local height = GUI._COUNTER_BAR.height
   local num_w = GUI._COUNTER_BAR.height
   local margin = GUI._COUNTER_BAR.margin

   local level_txt = GUI.make_text_box({0,0,width,height}, "Úroveň",
					{0,0,0,255})

   local lvl = GUI.make_text_box({width+margin,0, num_w,num_w}, level_hero , {0,0,0,255})

 
   local text_level = GUI.make_text_box({0,height+margin,width,height}, "Úrovňové body",
					{0,0,0,255})

   local points = GUI.make_text_box({width+margin,height+margin, num_w,num_w}, number, {0,0,0,255})
   local number = number
   local layout
   local function on_click_plus(self, mouse)
      if number > 0 then
	 number = number -1
	 points:change_string(number)
--	 GUI.send_event(self.parrent, "on_change_num", 1)
	 self.parrent:change_num(1)
	 if refresh then
	    refresh(layout)
	 end
      end
   end
   local function on_click_minus(self, mouse)
      if self.parrent.number > 1 then
	 number = number + 1
	 points:change_string(number)
--	 GUI.send_event(self.parrent, "on_change_num", -1)
	 self.parrent:change_num(-1)
	 if refresh then
	    refresh(layout)
	 end
      end
   end
   
   local stats = make_counter_layout({{"Síla", stats.strengh or 0, on_click_plus, on_click_minus},
				      {"Obratnost", stats.dexterity or 0, on_click_plus, on_click_minus},
				      {"Moudrost", stats.wisdom or 0, on_click_plus, on_click_minus}})

  

   stats:move(0,points.bound_box.y + points.bound_box.h + 4*margin)
   
   layout = GUI.make_empty_frame({0,0,stats.bound_box.x + stats.bound_box.w,
					stats.bound_box.y +
					   stats.bound_box.h})
   
   function layout:remove_minus()
      for k,v in ipairs(stats.objects) do
	 if v.remove_minus then
	    v:remove_minus()
	 end
      end
   end
   function layout:get_end_num()
      return number
   end
   function layout:get_stats_points()
      return stats:get_stats_numbers()
   end
   function layout:refresh(hero)
      stats:refresh({hero.stats.strengh, hero.stats.dexterity, hero.stats.wisdom})
      points:change_string(hero.level_points)
      lvl:change_string(hero.level)
      number = hero.level_points
   end

   GUI.compose_object(layout,level_txt)
   GUI.compose_object(layout,lvl)
   GUI.compose_object(layout,text_level)
   GUI.compose_object(layout,points)
   GUI.compose_object(layout,stats)         

   return layout
end

function NGD.make(on_start_game)
   local frame 
   local background_color = { 80, 80,80, 255}
   local stats = NGD.stats_dialog(20,1,{["strengh"] = 10, ["dexterity"] = 10, ["wisdom"] = 10})
   local inventory = make_inventory(5, nil, 60)
   local inventory2 = make_inventory(1,nil,60)
   inventory:unbind_scroll()
   inventory2:unbind_scroll()
   inventory:unbind_panel()
   inventory2:unbind_panel()
   inventory2:move(inventory.bound_box.w+20,0)

   local helper2 = GUI.make_text_box({0,0,400,40}, "Rozdej si dovednostní body můžeš i ve hře",
					{0,0,0,255})
   local helper = GUI.make_text_box({0,0,400,70}, "Vyber si předmět a přesuň ho do prázdného políčka",
					{0,0,0,255})

   local inventory_layout = GUI.make_empty_frame({0,0,inventory2.bound_box.w+inventory2.bound_box.x,
						  inventory.bound_box.h})


   inventory:add_item(make_inventory_item(Item.make_item(_ITEMS.heal_potion)))
   inventory:add_item(make_inventory_item(Item.make_item(_ITEMS.sword)))
   inventory:add_item(make_inventory_item(Item.make_item(_ITEMS.tunic)))
   inventory:add_item(make_inventory_item(Item.make_item(_ITEMS.mana_potion)))
   inventory:add_item(make_inventory_item(Item.make_item(_ITEMS.helmet)))
   
   GUI.compose_object(inventory_layout,inventory)
   GUI.compose_object(inventory_layout, inventory2)

   local layout = GUI.make_layout({helper2,stats,helper,inventory_layout},{0,0,400,450})

   local function on_start(self, mouse)
      local stats_result = stats:get_stats_points()
      stats_result["level_points"] = stats:get_end_num()
      local inventory_result = inventory2:get_invetory_items()     
      
      if #inventory_result == 0 then 
	 local msg = GUI.make_message_box("Musíš si zvolit jeden předmět do svého inventáře!")
	 GUI.compose_object(GUI.main_window, msg)
	 return
      end
      if on_start_game then
	      on_start_game(stats_result, inventory_result)
      end      
   end


   frame = GUI.make_frame({0,0,0,0}, layout, GUI.make_layout_buttons({{"Pokračuj", on_start}}),
   background_color)     

   frame:unbind_scroll()
   frame:move(0,20)
   return frame
end

return NGD