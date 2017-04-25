local function on_draw(self,x,y)
  local gm = get_game_machine()
  local mouse = gm:get_mouse()
  local tab = {["x"] = self.bound_box.x - Map.x,
		["y"] = self.bound_box.y - Map.y,
		["w"] = self.bound_box.w,
		["h"] = self.bound_box.h}
   
  if HelpFce.is_click_none_transparent(self.sprite,tab, mouse.move_x,mouse.move_y) then
  --  self.sprite:set_modulation_color(200,200,200,1)
    self.sprite:set_modulation_color(255,255,255,1)
    if mouse.release == "left" then
      gm:send_event(gm:getUserUI(),"objects_activate",{["object"] = self,["x"] = x,["y"] = y})
    end
  else
    --self.sprite:set_modulation_color(255,255,255,1)
  end
end

_OBJECTS_ITEM = {
   {["name"] = "wall_cave",
    ["path"] = "wall",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["layer"] = 2
   },
   {["name"] = "wall_cave",
    ["path"] = "wall_corner",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["layer"] = 2},    
   {["name"] = "wall_wood",
    ["path"] = "wall_wood",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["layer"] = 2},    
   {["name"] = "wall_wood",
    ["path"] = "wall_wood_corner",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["layer"] = 2,
   },       
  {["name"] = "tree",
    ["path"] = "tree2",
    ["move_x"] = -32,
    ["move_y"] = 0,
    ["count"] = 1,
    ["layer"] = 2
  },    
  {["name"] = "chest",
    ["path"] = "chest",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["on_draw"] = on_draw,
    ["layer"] = 1,    
   },    
   {["name"] = "shelve",
    ["path"] = "shelve",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["layer"] = 2
   },    
   {["name"] = "drop_item",
    ["path"] = "drop_item",
    ["move_x"] = 0,
    ["move_y"] = 0,
    ["on_draw"] = on_draw,
    ["layer"] = 1,
    ["count"] = 1,
    ["through"] = true
   },    
}

_DObjects = {
   ["spider"] = _BESTIAR.spider,
   ["spidermut"] = _BESTIAR.spidermut,
   ["spider_blue"] = _BESTIAR.spider_blue,
   ["spider_green"] = _BESTIAR.spider_green,
--   ["brunhilda"] = _NPC.brunhilda
}

_NObjects = {
   ["brunhilda"] = _NPC.brunhilda
}