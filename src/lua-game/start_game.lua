--_G.debug = require("debug")
--require("mobdebug").start()
--package.path = package.path .. ";/opt/zbstudio/lualibs/mobdebug/?.lua"

dofile(PREFIX .. "./config.lua")
dofile(PATH_LIB .. "header.lua")
GUI = require(PATH_LIB .. "lua_main")


dofile(PATH_GAME .. "game_main.lua")
dofile(PATH_GAME .. "model.lua")

HelpFce = require(PATH_GAME .. "help_function")
GameStarter = require(PATH_GAME .. "in_game")

_DELAY = 10
_LAST_TIME = 0
_FRAMES = 0
_GC_STEP = 100
--collectgarbage(*ever*)
--collectgarbage("stop")

local main_window_iter = GUI.create_window(game_main, on_load)

local function for_linux()
   local user = ERPG_Utils.get_user()
   local files = ERPG_Utils.get_files_dir(user)
   local x = nil
   for k,v in ipairs(files) do
      if v == ".rpg" or v == ".rpg/" then
	 x = true
	 break
      end
   end
   if x == nil then
      os.execute("mkdir "..user.."/.rpg")
   end

   files = ERPG_Utils.get_files_dir(user .. "/.rpg/")
   x = nil
   files = files or {}
   for k,v in ipairs(files) do
      if v == "saves" or v == "saves/" then
	 x = true
	 break
      end
   end
   if x == nil then
      os.execute("mkdir "..user.."/.rpg/saves")
   end
end

for_linux()
_FrameBox = make_text_box({0,0,100,50},"0")


_PROFILING = 0
_PROFILING_END = 0
function main()
   if ERPG_Utils.get_time() - _LAST_TIME > 1000 then
      print("FPS",_FRAMES)
      _FrameBox:change_string("FPS: " .. _FRAMES)
      _LAST_TIME = ERPG_Utils.get_time()
      _FRAMES = 0
   end
   
--   print(_LAST_DELAY)
   --profiler(GUI.START_CYCLE,main_window_iter)

     GUI.START_CYCLE(main_window_iter)
   _FRAMES = _FRAMES + 1
   
end


