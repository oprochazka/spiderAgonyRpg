--GUI = require(PATH_LIB .. "lua_main")
dofile(PATH_GAME ..  "./in_game.lua")
dofile(PATH_GAME .. "./window_machine.lua")
dofile(PATH_GAME .. "./menu.lua")

dofile(PATH_GAME .. "./on_press_start.lua")


function on_load(mouse, keyboard)
   local main_frame
   local the_game
   local window_machine = get_window_machine()

   window_machine:on_load_gui_system()

   GUI.compose_object(GUI.main_window,make_menu_bar())

end

function game_main(mouse,keyboard)
  if GUI.main_window.rendering then
    
  end
end