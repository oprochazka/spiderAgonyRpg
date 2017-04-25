AI = require(PATH_GAME .. "ai")
dofile(PATH_CONFIGS .. "animation_config.lua")
dofile(PATH_CONFIGS .. "bestiar_config.lua")
dofile(PATH_CONFIGS .. "npc_config.lua")
dofile(PATH_GAME .. "game_machine.lua")
dofile(PATH_GAME .. "hero.lua")
dofile(PATH_GAME .. "gui_game_config.lua")
dofile(PATH_GAME .. "inventory.lua")
dofile(PATH_CONFIGS .. "items_config.lua")

dofile(PATH_GAME .. "matricies_mask.lua")
dofile(PATH_CONFIGS .. "dialogs_config.lua")
dofile(PATH_CONFIGS .. "spells_config.lua")

dofile(PATH_CONFIGS .. "palet_config.lua")
dofile(PATH_CONFIGS .. "objects_config.lua")

IdG = require(PATH_GAME .. "IdGenerator")
Item = require(PATH_GAME .. "items")
Attack = require(PATH_GAME .. "attack_scripts")
HeroDialog = require(PATH_GAME .. "hero_dialog")   
UserUI = require(PATH_GAME .. "UserUI")
Map = require( PATH_GAME .. "map")
Character = require(PATH_GAME .. "character")
Bar = require(PATH_GAME .. "progress_bar")
NPC = require(PATH_GAME .. "npc")
Pattern_text = require(PATH_GAME .. "pattern_text")
Spells = require(PATH_GAME .. "spells")
Client = require(PATH_GAME .. "client")
MConstants = require(PATH_GAME .. "multiplayer_constants")
Server = require(PATH_GAME .. "server")
ServerChars = require(PATH_GAME .. "serverChars")
ClientChars = require(PATH_GAME .. "clientChars")
_PORT = 5641

local GameStarter = {}

function profiler(func, arg)
      local calls, total, this = {}, {}, {}
      debug.sethook(function(event)
		       local i = debug.getinfo(2, "Sln")
		       if i.what ~= 'Lua' then return end
		       local func = i.name or (i.source..':'..i.linedefined)
		       if event == 'call' then
			  this[func] = os.clock()
		       else
			  this[func] = this[func] or 0
			  local time = os.clock() - this[func]
			  total[func] = (total[func] or 0) + time
			  calls[func] = (calls[func] or 0) + 1
		       end
		    end, "cr")

      func(arg)

      debug.sethook()
      
      -- print the results
      for f,time in pairs(total) do
	 print(("Function %s took %.3f seconds after %d calls"):format(f, time, calls[f]))
      end
end

local function loading_picture()
   local sp = GUI.make_sprite(PATH_GUI_IMG .. "loading.png")

   sp:move(GUI.SCREEN.width/2- sp.bound_box.w/2, GUI.SCREEN.height/2 - sp.bound_box.h/2)
   local load_txt = GUI.make_element_text((sp.bound_box.x+sp.bound_box.w)/2,
                 (sp.bound_box.y+sp.bound_box.h)/2,
                 30,"Načítám...",{255,0,0,255},
                 PATH_FONTS .. "Ubuntu-B.ttf")

   sp.sprite:set_alpha(100,1)
   
   GUI.compose_object(GUI.main_window, sp)
   GUI.compose_object(sp, load_txt)
   return sp
end

--function on_loading_corutine(func,frame,args)
 --[[  local tmp = {}
   for k,v in ipairs(GUI.main_window.objects) do
      tmp[k]=v
   end
   local pic = loading_picture()   
   local co = coroutine.create(func(frame,args))
   ERPG_window.prepare_renderer()
   main()
   ERPG_window.update_renderer()
   coroutine.resume(co)
   pic.sprite:set_alpha(200,1)
   ERPG_window.prepare_renderer()
   main()
   ERPG_window.update_renderer()
   coroutine.resume(co)
   table.remove(GUI.main_window.objects, 1)
   GUI.main_window.objects = tmp
   ]]
--end


function GameStarter.loading_game(frame,args)
   return function (userUI)
      Map.load("result2")
    --  coroutine.yield()
      local stats = args.stats  
      local items = args.items
      local item_tab = {}
      for k,v in ipairs(items) do
	     item_tab[#item_tab + 1 ] = v.item.name
      end

      local conf = {
   	 ["experience"] = 0,
   	 ["stats"] = {
   	    ["strengh"] = stats[1][2],
   	    ["dexterity"] = stats[2][2],
   	    ["health"] = stats[1][2]*3,
   	    ["wisdom"] = stats[3][2],
   	    ["mana"] = stats[3][2]*3},
   	 ["level_points"] = stats.level_points,
   	 ["items"] = item_tab,
   	 ["level"] = 1,
   	 ["health"] = stats[1][2]*3,
   	 ["mana"] = stats[3][2]*3
      }

      hero = make_hero()  
      hero:setConfiguration(conf)      
      hero:insert(95,242)
      userUI:connectHero(hero)
   end
end




function GameStarter.startServer(frame, args)
   return function (userUI)
      local x = ERPG_Network_server.create(_PORT)
      
      local gm = get_game_machine()
      
      GameStarter.loading_game(frame, args)(userUI)      

      ServerChars.setHero(userUI.connectedHero)

      gm:setServer(true)
   end
end

--[[function print()

end]]

function GameStarter.connectServer(frame, args)
   return function (userUI)

      local x = ERPG_Network.network_connect("localhost",_PORT)
      print("Connected? ", x)
      local gm = get_game_machine()
      if x == nil then

         ERPG_Network.network_close_connection()
         return true
      end
      gm:setClient(true)
      GameStarter.loading_game(frame, args)(userUI)
      local gm = get_game_machine()              
      
      ERPG_Network.add_data("ahoj")
      Client.sendHero(hero)
      --[[local output =""
      output = Serialization.serializeToString(hero:dump())
      print("huh" .. output)
      ERPG_Network.add_data("Connect;" .. output .. ";")
      ERPG_Network.add_data("move;" .. hero:getId() .. ";move_up_right;" )]]
    --  ERPG_Network.add_data("points;95;242")
   end
end
   
function GameStarter.in_loading_game(frame,path) 
   local gm = get_game_machine()     
   return function (userUI)
      for k,v in ipairs(gm.callbacks_iter) do
         if v.type and v.type == "dynamic"  then
            v:destroy_self()
         end
      end
      Map.get_id = get_ids()    
      _HeroObject=nil
      dofile(PATH_SAVE .. path .. ".sav")

      Map["name"] = _HeroObject.map_name

      local w, h = Tiles.load_map( PATH_MAPS .. Map.name .. ".map")  
      --coroutine.yield()
      MpR.load_map( path , nil, PATH_SAVE)

      local hero = make_hero(1,1)

      Tiles.screen_box(0,0)
      Map.x = 0
      Map.y = 0
      hero:load(_HeroObject)
      userUI:connectHero(hero)

      gm:set_time(_HeroObject.time)
      Map["size_map"] = {w,h}
   end
end

function GameStarter.start(frame, args, loadingFunction, type)
   local _POSITION = GUI.SCREEN.width - 400
   local t_w, t_h = 64,32
   local w, h = math.floor((_POSITION)/t_w)*t_w, math.floor((GUI.SCREEN.height-280)/t_h)*t_h
   _POSITION = w  
   
   local game_machine = make_game_machine(frame, w, h)
   local canvas_frame = game_machine:get_canvas_frame()
   local screen_w,screen_h = game_machine.canvas:get_size()

   local userUI = UserUI.make(type)   
   userUI:initializeUI(screen_w)

   game_machine:setUserUI(userUI)
  
   local render_map = make_graphic_element(w,h)
   game_machine:create_layer()
   game_machine:create_layer()
   game_machine:create_layer()
   Map.Initialize_map(render_map)
   game_machine:set_layer({render_map}, 1)
     
   GUI.add_event(frame, "on_wheel", function ()  end)

   local function on_input_key(self, press_key)
      for k, v in ipairs(self.objects) do
	      GUI.send_event(v,"on_input_key", press_key)
      end
   end
   
   GUI.add_event(frame, "on_input_key", on_input_key)
   GUI.compose_object(frame, canvas_frame)   

   --on_loading_corutine(loading_game,frame, args)
   local what = loadingFunction(frame, args)(userUI)

   if what then
      GUI.send_event(game_machine:get_main_frame(),"on_resume")
      return
   end

   return function(self)  
      game_machine:refresh_game_mouse(frame)     
      game_machine:apply_callbacks()      
   end
end

return GameStarter


