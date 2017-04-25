local NPC = {}

NPC["configurationObjects"] = _NPC

local configurationObjects = _NPC

local function on_draw(self,x,y)
   local gm = get_game_machine()
   local mouse = gm:get_mouse()
   local tab = {["x"] = self.model.graphic_element.bound_box.x - Map.x,
		["y"] = self.model.graphic_element.bound_box.y- Map.y,
		["w"] = self.model.graphic_element.bound_box.w,
		["h"] = self.model.graphic_element.bound_box.h}
      
   if HelpFce.is_click_none_transparent(self.model.graphic_element.sprite,
					tab, mouse.move_x,mouse.move_y) then

     --self.model.graphic_element.sprite:set_modulation_color(200,200,200,1)
      self.model.graphic_element.sprite:set_modulation_color(255,255,255,1)
      if mouse.release == "left" then
	      gm:send_event(gm:getUserUI(),"objects_activate",
			   {["object"] = self,["x"] = x,["y"] = y, ["type"] = "npc"})
      end
   else      
     -- self.model.graphic_element.sprite:set_modulation_color(255,255,255,1)
   end
end

--[[
function NPC.make_dialog(npc)
   local path = npc.dialog

   local f = assert(io.open(PATH_TEXT .. path, "r")) 
   local t= f:read("*all")	 
   f:close()

   local frame

   Pattern_text.get_answers()

   local but = GUI.make_static_text(t,300)

   
   local function on_cl_d(self)
      GUI.send_event(frame,"on_destroy")
   end

   local answers, question = Pattern_text.get_answers()
   local tab = {}

   local function on_click_button(self, mouse)
      if question[self.order] then
	 Pattern_text.get_answers()
	 print(question[self.order])
	 but = GUI.make_static_text(question[self.order], 300)
	 answers, question = Pattern_text.get_answers()
	 tab = {}
	 tab[#tab + 1 ] = but

	 for k,v in ipairs(answers) do
	    local tmp = GUI.make_standart_text_button(v,on_click_button)
	    
	    tmp["order"] = k

	    tab[#tab + 1] = tmp
	 end
	 frame.layout:change(tab)
      else
      end
   end

   tab[#tab + 1 ] = but

   for k,v in ipairs(answers) do
      local tmp = GUI.make_standart_text_button(v, on_click_button)
      
      tmp["order"] = k

      tab[#tab + 1] = tmp
   end


   local lay = GUI.make_layout(tab,{0,0,300,350})
   frame = GUI.make_frame({0,0,0,0},lay, GUI.make_layout_buttons({{"CANCLE", on_cl_d}}),
			  {30,30,30,255})
   
   frame:move(100,20)

   return frame
end
]]

function NPC.make_dialog(npc)
   local path = npc.dialog.text
    local gm = get_game_machine() 
   local hero = gm:getUserUI().connectedHero

   local f = assert(io.open(path, "r")) 
   local t= f:read("*all")	 
   f:close()
   local frame
   
   local function on_cl_d(self)
      GUI.send_event(frame,"on_destroy")
   end

   Pattern_text.get_answers()
   local my_width = 600
   local but = GUI.make_static_text(t,my_width)

   local answer,question = Pattern_text.get_answers()
   local first = 1

   local txt = question[first]

   local but = GUI.make_static_text(txt,my_width)
   local tab = {}
   tab[1] = but   
   local get_text


   local function get_text(index, on_click)
      for k,v in ipairs(npc.dialog.questions[index]["answer"]) do	 
	 if v.cond(hero, npc) then
	    local tmp = GUI.make_standart_text_button(answer[v.order],on_click, 14)
	    tmp["on_apply"] = v.on_apply	    
	    tmp["next_question"] = v.next_question

	    tmp["quest_name"] = v.quest_name
	    
	    tab[#tab + 1] = tmp
	 end
      end
   end

   local function on_click_apply(self)
      local hero = gm:getUserUI().connectedHero
      self.on_apply(hero,npc)
      local tmp = self.next_question
      txt = question[tmp]

      if but.sprite then
	 but.sprite:unload_texture()
      end
      print(txt)
      but = GUI.make_static_text(txt,my_width)
      tab = {}
      tab[1] = but
      
      get_text(tmp, on_click_apply)

      frame.layout:change(tab, on_click_apply)
   end

   get_text(first, on_click_apply)

   local lay = GUI.make_layout(tab,{0,0,my_width,350})
   frame = GUI.make_frame({0,0,0,0},lay, GUI.make_layout_buttons({{"CANCLE", on_cl_d}}),
			  {30,30,30,255})
   
   frame:move(100,20)

   return frame
end

function NPC.make(name,x,y)
   local dobj = DObj.make_object()
   local object = _NPC[name]   

   dobj["name"] = "npc"
   dobj["friend_ship_state"] = "none"
   dobj.on_draw = on_draw

   function dobj:setConfiguration(name)
      local conf = configurationObjects[name]

       if conf == nil then
         error("non registrate object in _BESTIAR: ", name)
         return 
      end

      dobj:setModel(conf.animation)

      dobj.name = name
      
      dobj["dialog"] = _DIALOGS[name]
   end
   
   function dobj:load(loadDump)
      local name = loadDump.name
      self:setConfiguration(loadDump.name) 
      self:insert(loadDump.render_points[1].x, loadDump.render_points[1].y)
      dobj["dialog"] = _DIALOGS[name]
   end

   return dobj
end

return NPC