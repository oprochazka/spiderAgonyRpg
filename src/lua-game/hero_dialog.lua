local HeroDialog = {}

local function remove_item(self)
   self.objects = {}
end

function HeroDialog.make()
   local size = _INVENTORY_ELEMENT.size
   local margin = _INVENTORY_ELEMENT.margin
   local frame_color = {150,150,150,255}
   local lines = 5
   local width = 5
   width = (size+margin)*width

   
	local main_frame = GUI.make_sprite(PATH_GUI_IMG .. "main_char.png")

   local helm = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local right_hand = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local left_hand = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local gloves_hand = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local gloves_left = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local tunic = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local trousers = GUI.make_frame_element({0,0,size,size}, frame_color, true)
   local boots = GUI.make_frame_element({0,0,size,size}, frame_color, true)

   main_frame["name"] = "hero_dialog"

   helm:move(size*2+margin*2, margin)
   left_hand:move(margin, size + margin)
   right_hand:move((size+margin)*4, size + margin)
   tunic:move(size*2+margin*2, (size+margin)*2)
   gloves_hand:move((size+margin)*4, (size+margin)*3)
   gloves_left:move(margin, (size+margin)*3)
   trousers:move(size*2+margin*2, (size+margin)*3)
   boots:move(size*2+margin*2, (size+margin)*4)

   local binds = {
      ["trousers"] = trousers,
      ["boots"] = boots,
      ["tunic"] = tunic,
      ["hat"] = helm,
      ["left_hand"] = left_hand,
      ["right_hand"] = right_hand,
      ["right_gloves"] = gloves_hand,
      ["left_gloves"] = gloves_left
   }

   function main_frame:getBinds()
      return binds
   end

   local function remove_item(self,inv_item)
      GUI.send_event(self.parrent,"remove_item",inv_item)
   end

   local function remove_item_main(self,inv_item)
      self.connectedHero:unset_equipmentToInventory(inv_item.item)      

      binds[inv_item.item.equipment_bind].objects = {}
   end

   local function on_release(self,args)     
      local item = args.item
      local parrent = args.parrent
      local bind = binds[item.item.equipment_bind]
      local dothat = nil
      local pred = true
     
      if bind and pred then
       dothat = self.connectedHero:set_equipment(item.item)
       if dothat then
         self.connectedHero:remove_item_from_list(item)
          if bind.objects and bind.objects[1] then
             GUI.send_event(parrent,"on_set_item", bind.objects[1])
             bind.objects = {}
          end
          item:set_position(bind.bound_box.x,bind.bound_box.y)
          GUI.compose_object(bind, item)  
       else
          GUI.send_event(parrent,"on_set_item", item)
       end
      else
        GUI.send_event(parrent,"on_set_item", item)
      end
   end   

   function main_frame:connectHero(hero)
      self["connectedHero"] = hero
   end

   function main_frame:set_item(item)
      local bind = binds[item.item.equipment_bind]
      item:set_position(bind.bound_box.x,bind.bound_box.y)
      GUI.compose_object(bind, item)	
   end

   function main_frame:remove_items()
      for k,v in pairs(binds) do
   	 binds[k].objects = {}
   	 GUI.send_event(v, "on_destroy")
      end
   end

   for k,v in pairs(binds) do
      GUI.add_event(v,"remove_item", remove_item)
      GUI.compose_object(main_frame, v)
   end

   GUI.add_event(main_frame,"change_item", on_release)
   GUI.add_event(main_frame,"remove_item", remove_item_main)
   return main_frame
end

function HeroDialog.improve_stats()
   local frame 
   local function on_accept(self,mouse)
      frame.connectedHero.level_points = self:get_end_num()
      local stats = self:get_stats_points()

      frame.connectedHero:change_stats(stats[1][2],stats[2][2],stats[3][2])
   end

   local stats = NGD.stats_dialog(0, 0, {}, on_accept)
   local layout = GUI.make_layout({stats, attack_bar,defense_bar},{0,0,0,280})
   local attack_bar
   local defense_bar

   stats:remove_minus()
   frame = GUI.make_frame({0,0,0,0}, layout, GUI.make_layout_buttons({{"Minimalizovat", on_cl_d}}))
   frame:move(0,20)

   function frame:connectHero(hero)
      self["connectedHero"] = hero
      attack_bar = GUI.make_static_counter_text("Útok", hero:sum_stats().attack)
      defense_bar = GUI.make_static_counter_text("Obrana", hero:sum_stats().armor)  
      
   end

   local function on_cl_d(self,mouse)
      GUI.send_event(frame,"on_destroy")
   end

   function frame:refresh(hero)
      stats:refresh(self.connectedHero)
      attack_bar:change_number(self.connectedHero:sum_stats().attack)
      defense_bar:change_number(self.connectedHero:sum_stats().armor)
   end
   
   frame:unbind_scroll()

   return frame
end

local function on_click_to_menu()
   local gm = get_game_machine()

   GUI.send_event(gm:get_main_frame(),"on_resume")
end

function HeroDialog.add_menu_bar(userUI)
   local gm = get_game_machine()
   local function on_click_stats(self,mouse)
      --GUI.compose_object(gm:get_main_frame(), HeroDialog.improve_stats(hero))
      GUI.compose_object(gm:get_main_frame(), userUI.improveStats)
   end
   
   local function on_click_save_hero(path)
      local time = gm:get_time()
      MpR.save(path, PATH_SAVE)
      
      local dump_obj = userUI.connectedHero:dump()
      local output = assert(io.open(PATH_SAVE .. path .. ".sav", "w"))

      output:write("_HeroObject = ")    
      dump_obj["time"] = time
      Serialization.serialize(dump_obj,output)   
      output:close()      
   end

   local function on_click_save()
      if userUI.connectedHero.flags.death == nil then
   	 local save = GUI.make_input_frame("SAVE", 70,"txt",on_click_save_hero)  
   	 GUI.compose_object(gm:get_main_frame(), save)  
      else
   	 local msg = make_message_box("Když jsi mrtvý nemůžeš uložit hru!!")
   	 GUI.compose_object(gm:get_main_frame(), msg)
      end
   end

   local function on_click_load_hero(path)
      if path == nil then return end
      --on_loading_corutine(in_loading_game,path)
      GameStarter.in_loading_game(nil,path)(userUI)

   end
   
   local function on_click_loading()
      local loader = GUI.make_file_browser(PATH_SAVE, on_click_load_hero)      
      GUI.compose_object(gm:get_main_frame(), loader)
   end

   local margin = 5
   local stats = GUI.make_standart_text_button("O postavě",on_click_stats)
   local save = GUI.make_standart_text_button("Ulož", on_click_save)
   local load_m = GUI.make_standart_text_button("Načti", on_click_loading)
   local menu = GUI.make_standart_text_button("Menu", on_click_to_menu)
   
   stats:move(margin, margin)
   save:move(stats.bound_box.w + margin + stats.bound_box.x, margin)
   load_m:move(save.bound_box.w + margin + save.bound_box.x, margin)
   menu:move(load_m.bound_box.w + margin + load_m.bound_box.x, margin)

   local out = GUI.make_frame_element({0,0, menu.bound_box.w+ menu.bound_box.x+margin, 
				       menu.bound_box.h+2*margin},
				      {40,40,40,255})
   
   GUI.compose_object(out, stats)
   GUI.compose_object(out, save)
   GUI.compose_object(out, load_m)
   GUI.compose_object(out, menu)
   
   return out
end

function HeroDialog.add_hero_event(hero)
   local game_machine = get_game_machine()
   local screen_w, screen_h = game_machine.canvas:get_size()
   local width = screen_w 
   local height = 200
   local x = 0
   local y = game_machine.canvas.canvas_frame.bound_box.h
   local geom = ERPG_geometry.make_rectangle({0,0,screen_w - 30,height*3}, {40,40,40,255}, 1)
   local texture = ERPG_sprite.compose_textures({geom}, width - 30, height*3)
   local elem = GUI.make_element_with_sprite(texture)
   local frame
   local layout = GUI.make_layout({elem}, {0,0,width - 30 ,height}, 5)
   
   frame = GUI.make_frame({0,0,0,0},layout,nil,{45,30,30,255})

   function frame:add_text(text)
      local txt = GUI.make_static_text(text, screen_w - 30)
      local w,h = txt.bound_box.w,txt.bound_box.h

      
      local w1,h1 = elem.sprite:get_max_size()
      local rect = elem.sprite:get_current_size()

      local x,y = elem.sprite:get_position()
      elem.sprite:set_position(0,h)
      elem.sprite:set_size(0,0,w1,h1)

      local tmp = ERPG_sprite.compose_textures({elem.sprite,txt.sprite},width, height * 3)
      
      elem.sprite:unload_texture()
      tmp:move(x,y)
      tmp:set_size(rect.x,rect.y,rect.w,rect.h)

      elem.sprite = tmp
   end
   frame:unbind_panel()
   
   frame:move(0,screen_h+5)

   return frame
end


return HeroDialog
