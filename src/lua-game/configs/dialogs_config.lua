local function allways(hero, npc)
   return true
end
local function on_apply(hero, npc)
   
end

local function cond_kill_monster(hero,npc)
   return hero:get_quest_progress("KillMonster")
end
local function not_cond_kill_monster(hero,npc)
   return (hero:get_quest_progress("KillMonster") == nil) and 
      (hero:get_complete_quest("KillMonster") == nil)
end
local function on_apply_quest(hero, npc, quest_name)
   hero:add_text_event("Přijal jsi úkol: Odevzdej 5 předmětů")
   hero:add_quest("KillMonster")
end
local function is_kill_monster(hero)
	print(hero, #hero.items)
   if #hero.items > 4 and hero:get_quest_progress("KillMonster") and 
      hero:get_complete_quest("KillMonster") == nil
   then
      return true
   end
end
local function accept_quest(hero)
   hero:add_item("sword")
   hero:add_item("heal_potion")     
   hero:add_text_event("Dokončil jsi úkol: Odevdej 5 předmětů")
   hero:complete_quest("KillMonster")
   
   local gm = get_game_machine()
   
--   GUI.send_event(gm:get_main_frame(),"on_win_game")
end
local function on_apply_quest2(hero)
   hero:add_text_event("Přijal jsi úkol: Najdi prsten země")
   hero:add_quest("FindRing")

end
local function quest2(hero)
   return hero:get_complete_quest("KillMonster") and hero:get_quest_progress("FindRing") == nil and
      hero:get_complete_quest("FindRing") == nil
end
local function quest2_get_cond(hero)
   return hero:get_quest_progress("FindRing")
end
local function on_accept_quest2_cond(hero)
   for k,v in ipairs(hero.items) do
      if v == "ring_of_earth" and hero:get_quest_progress("FindRing") then
	 return true
      end
   end
   
end
local function on_accept_quest2(hero)
   local gm = get_game_machine()

   hero:remove_item("ring_of_earth")
   hero:add_text_event("Dokončil jsi úkol: Najdi prsten země")
   hero:complete_quest("FindRing")

   GUI.send_event(gm:get_main_frame(),"on_win_game")
end


_DIALOGS = {
   ["brunhilda"] = {
      ["text"] = PATH_TEXT .. "brunhilda",
      ["questions"] = {
	 {["id"] = 1, ["answer"] = {
	     {["order"] = 1, ["on_apply"] = on_apply, ["cond"] = not_cond_kill_monster,
	      ["next_question"] = 2},
	     {["order"] = 2, ["on_apply"] = on_apply, ["cond"] = not_cond_kill_monster, 
	      ["next_question"] = 4},
	     {["order"] = 5, ["on_apply"] = on_apply, ["cond"] = cond_kill_monster, 
	      ["next_question"] = 2},
	     {["order"] = 6, ["on_apply"] = accept_quest, ["cond"] = is_kill_monster, 
	      ["next_question"] = 3},
	     {["order"] = 7, ["on_apply"] = on_apply, ["cond"] = quest2, 
	      ["next_question"] = 5},
	     {["order"] = 5, ["on_apply"] = on_apply, ["cond"] = quest2_get_cond, 
	      ["next_question"] = 8},
	     {["order"] = 6, ["on_apply"] = on_accept_quest2, ["cond"] = on_accept_quest2_cond, 
	      ["next_question"] = 9},
	 }},
	 {["id"] = 2,["answer"] = {
	     {["order"] = 3, ["on_apply"] = on_apply_quest, ["cond"] = not_cond_kill_monster, 
	      ["quest_name"] = "KillMonster",
	      ["next_question"] = 3},
	     {["order"] = 4, ["on_apply"] = on_apply, ["cond"] = not_cond_kill_monster, 
	      ["next_question"] = 4},
	 }},	      	         
	 {["id"] = 3,["answer"] = {
	 }},	      	         
	 {["id"] = 4,["answer"] = {
	 }},
	 {["id"] = 5,["answer"] = {
	     {["order"] = 8, ["on_apply"] = on_apply_quest2, ["cond"] = allways, 
	      ["quest_name"] = "FindRing",
	      ["next_question"] = 6},
	     {["order"] = 9, ["on_apply"] = on_apply_quest2, ["cond"] = allways, 
	      ["quest_name"] = "FindRing",
	      ["next_question"] = 6},
	     {["order"] = 10, ["on_apply"] = on_apply, ["cond"] = allways, 
	      ["next_question"] = 7},
	 }},
	 {["id"] = 6,["answer"] = {
	 }},
	 {["id"] = 7,["answer"] = {
	 }},
	 {["id"] = 8,["answer"] = {
	 }},
	 {["id"] = 9,["answer"] = {
	 }}
      }   
   }
}