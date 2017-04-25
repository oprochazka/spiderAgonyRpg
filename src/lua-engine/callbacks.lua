
local CALLBACKS_ON_LOAD = {}
local CALLBACKS = {}
local CALLBACKS_ON_DESTROY = {}
function add_event(obj, name_event, func)
   if obj.callbacks == nil then
      obj.callbacks = {}
   end
   obj.callbacks[name_event] = func
end

function remove_event(obj, name_event)
   obj.callbacks[name_event] = nil
end

function free_events(obj)
   obj.callbacks.events = {}
   obj.callbacks.events_destroy = {}
   obj.callbacks.events_load = {}
end

function send_event(obj, name_event, params)
   if obj.callbacks.events == nil then
      obj.callbacks.events = {}
   end
   if obj.callbacks.events_destroy == nil then
      obj.callbacks.events_destroy = {}
   end
   if obj.callbacks.events_load == nil then
      obj.callbacks.events_load = {}
   end
   for key,value in pairs(obj.callbacks) do
      if key == name_event then
	 if name_event == "on_destroy" then
	    obj.callbacks.events_destroy[#obj.callbacks.events_destroy+1] =  {
	       ["func"] = value, 
								      ["parametrs"] = params}
	 elseif name_event == "on_load" then
	    obj.callbacks.events_load[#obj.callbacks.events_load+1] =  {["func"] = value, 
									      ["parametrs"] = params}
	 else
	    obj.callbacks.events[#obj.callbacks.events+1] =  {["func"] = value, 
							      ["call"] = name_event,
							   ["parametrs"] = params}
	 end
	 return
      end
   end

   if name_event == "on_iter" or name_event == "on_press_key" or name_event == "on_mouse_press" or
      name_event == "on_destroy" or name_event == "on_motion" or name_event == "on_input_key"
   then
      return
   end
   print("EVENT: ".. name_event .. " non exist")
end

function send_event2(obj, name_event, params)
   if obj.callbacks.events == nil then
      obj.callbacks.events = {}
   end
   if obj.callbacks.events_destroy == nil then
      obj.callbacks.events_destroy = nil
   end
   for key,value in pairs(obj.callbacks) do
      if key == name_event then
	 if name_event == "on_destroy" then
	    CALLBACKS_ON_DESTROY[#CALLBACKS_ON_DESTROY+1] =  {["func"] = value, 								      ["parametrs"] = params, ["object"]=obj}
	 elseif name_event == "on_load" then
	    CALLBACKS_ON_LOAD[#CALLBACKS_ON_LOAD+1] =  {["func"] = value, 								      ["parametrs"] = params, ["object"]=obj}
	 else
	    CALLBACKS[#CALLBACKS+1] =  {["func"] = value, 								      ["parametrs"] = params, ["object"]=obj}
	 end
	 
	 return
      end
   end
   print("EVENT: ".. name_event .. " non exist")
end

function compose_object(obj, join_obj)
   if obj.objects == nil then
      obj.objects = {}
   end
   if join_obj.callbacks == nil then join_obj.callbacks = {}; end

   join_obj["parrent"] = obj
   obj.objects[#obj.objects+1] = join_obj
end



function apply_callbacks(main_window)
   for key,value in ipairs(CALLBACKS_ON_LOAD) do      
      value.func(value["object"],main_window, value["parametrs"])
   end
   for key,value in ipairs(CALLBACKS) do
      value.func(value["object"], value["parametrs"])
   end
   for key,value in ipairs(CALLBACKS_ON_DESTROY) do
      value.func(value["object"], value["parametrs"])
   end
   CALLBACKS = {}
   CALLBACKS_ON_DESTROY={}
   CALLBACKS_ON_LOAD = {}
end

function object_by_name_id(object_list, name,id, func, callback_name)
   for k,v in ipairs(object_list) do 
      print(v.information.name, name)
      if v.information and v.information.name and 
      name == v.information.name and (id == nil or v.information.id == id) then
	 print("set new function on_callback: " .. callback_name)
	 add_event(v, callback_name, func)
      end

      if v.objects then
	 object_by_name_id(v, name,id, func, callback_name)	       
      end
   end
end

function replace_callback_by_name(callback_name,name, id, func)
   object_by_name_id({main_window}, name,id,func, callback_name)
end

function set_information(object, name, id)
   object["information"] = {["id"] = id,
			    ["name"] = name}
end

function get_information(object)
   if object.information then return object.information.id, object.information.name end
end
   
function get_object_by_name_id(object_list, name,id)
   local tab = {}
   local function rekursion(object_list)
      for k,v in ipairs(object_list) do
	 for key,value in pairs(v) do print(key,value) end
	 if v.information and v.information.name and name == v.information.name and 
	 (id == nil or v.information.id == id) then
	    printf("adding: " .. v.information.name)
	    tab[#tab+1] = v
	 end
	 
	 if v.objects then
	    rekursion(v)	       
	 end
      end
   end
   rekursion(object_list)
   return tab
end