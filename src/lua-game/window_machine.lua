local WINDOW_MACHINE = {
   ["game_state"] = nil,
   ["menu_state"] = nil,
   ["menu_load_objects"] = {["options"] = nil,
			    ["start_game"] = nil,
			    ["menu_bar"] = nil
   },
   ["game_load_objects"] = nil,
   ["background_sound"] = PATH_SOUNDS .. "maleit1.ogg"
}

function get_window_machine()
   return WINDOW_MACHINE
end

function WINDOW_MACHINE:on_load_gui_system()
   local menu_bar
   local options = make_window_options(GUI.main_window)
   ERPG_Audio.set_background_music(WINDOW_MACHINE.background_sound)

   if _OPTIONS.music then   
      ERPG_Audio.play_music(-1)
   end


   WINDOW_MACHINE.menu_load_objects["options"] = options
   WINDOW_MACHINE.menu_load_objects["menu_bar"] = menu_bar
end

function WINDOW_MACHINE:get_options()
   return WINDOW_MACHINE.menu_load_objects.options
end
