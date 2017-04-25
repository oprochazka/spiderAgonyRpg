 local function set_position (self, x,y)    
    if self.parrent then
      x = self.parrent.bound_box.x + x
      y = self.parrent.bound_box.y + y
    end
    if self.sprite then
       self.sprite:set_position(x,y)
    end
    
    local last_x, last_y = self.bound_box.x, self.bound_box.y

    self.bound_box.x = x
    self.bound_box.y = y 			
    if self.objects then
       for k,v in ipairs(self.objects) do
	  if v.set_position then
	     v:move(self.bound_box.x - last_x, self.bound_box.y  - last_y)
	  end
       end
    end
 end



function make_frame_element(rect, color, empty)
   local out = {
		 ["callbacks"]={},
		 ["set_position"] = set_position,

		 ["move"] = 
		   function (self, x,y)		      
		      self.sprite:move(x,y)
		      self.bound_box.x = self.bound_box.x + x
		      self.bound_box.y = self.bound_box.y + y
		      if self.objects then
			 for key,value in ipairs(self.objects) do
			    value:move(x,y)
			  end		
		       end
		    end,
		 ["scale"] = function (self, w,h)	
		    self.sprite:scale(w, h)
		    self.bound_box.w = self.bound_box.w + w
		    self.bound_box.h = self.bound_box.h + h
		    if self.objects then
		       for key,value in ipairs(self.objects) do
		--	  value:scale(w,h)
		       end		
		       end
		    end,
		 ["print"] = function () print("frame_element") end
    }
    
   function out:set_color(color)
      out.sprite:set_color(color[1],color[2],color[3],color[4])
   end
	 local panel = {}
	 if empty == nil then
	   panel = ERPG_geometry.make_rectangle( rect, color,1)
	 else
		 panel = ERPG_geometry.make_empty_rectangle( rect, color,1)
   end
   out["sprite"] = panel
   out["bound_box"] = {["x"]=rect[1], ["y"]=rect[2], ["w"] = rect[3],["h"] = rect[4]}
  
   local function on_click(out, mouse)
   end   
   add_event(out,"on_click", on_click)
   
   return out
end

function make_element_text(x, y, size, text, color, font)
    local element ={}
    local font = font or _TEXT.font
    local w, h = ERPG_text.get_size( font,text, size)
    element["sprite"] = ERPG_text.make_text(font,
					 text,x,y, size, color)

    element["scale"] = function (self,w,h)	
       self.bound_box.w = self.bound_box.w + w
       self.bound_box.h = self.bound_box.h + h
       self["sprite"]:scale(w,h)
    end

    element["print"] = function () print("element text") end
    element["bound_box"] = {["x"]=x,["y"]=y,["w"]=w, ["h"]=h}
    element["change_string"] = function (self,str) 
       self.sprite:change_string(str)
       self["w"]= ERPG_text.get_size( font, str, size)
    end
    element["move"] = function (self, x,y)
       self.bound_box.x = self.bound_box.x + x
       self.bound_box.y = self.bound_box.y + y
       self.sprite:move(x,y) 
    end
    element["set_position"] = function (self, x,y)		      
       self:set_position(x,y)
       self.bound_box.x = x
       self.bound_box.y = y

    end

    return element
 end


 function make_empty_frame(rect)
    local out = { ["scale"] = function (self,w,h)	
		     print(self, w,h)
		     self.bound_box["w"] = self.bound_box["w"] + w
		     self.bound_box["h"] = self.bound_box["h"] + h		   
		     if self.objects then
			for k,v in ipairs(self.objects) do
			   v:scale(w,h)
			end
		     end
    end,
		  ["print"] = function() print("empty frame"); end,
		  ["move"] = 
		     function (self, x,y)
			if self.sprite then
			   self.sprite:move(x,y)
			end
			self.bound_box.x = self.bound_box.x + x
			self.bound_box.y = self.bound_box.y + y			
			if self.objects then
			   for k,v in ipairs(self.objects) do
			      v:move(x,y)
			   end
			end
		    end,
		 
		 ["bound_box"] = {["x"]=rect[1], ["y"]=rect[2],
				  ["w"] = rect[3],["h"] = rect[4]},
		 ["set_position"] = set_position
	       }
   return out
end

local tmp_fce= ERPG_sprite.make

local function on_error(image)

      local _EXIT = true
      local txt = ERPG_text.make_text(PATH_FONTS .. "Ubuntu-B.ttf", "Can't open image" .. image,
				      10,10,
				      20, {0,0,0,255})
      local txt2 = ERPG_text.make_text(PATH_FONTS .. "Ubuntu-B.ttf", "Press any key",
				      10,40,
				      20, {0,0,0,255})
      local frame = ERPG_geometry.make_rectangle({0,0,GUI.SCREEN.width,GUI.SCREEN.height},
						 {100,100,100,255},1)
      while(_EXIT) do
        ERPG_window.prepare_renderer()	
	frame:copy_to_renderer()
	txt:copy_to_renderer()
	txt2:copy_to_renderer()
	if mouse.press ~= "none" or keyboard.press[1] then
	   os.exit()
	end
	ERPG_window.update_renderer()
      end

end

function ERPG_sprite.make(path, alpha_color)
   local sprite = tmp_fce(path,alpha_color)
   if sprite == nil then
      on_error(path)
      return {}
   end
   return sprite
end

function make_element_with_sprite(sprite)  
   local b_exit = sprite
   local w, h = b_exit:get_width_height()

   local x =  0
   local y =  0  

   local exit = {["move"] = function (self, x ,y)
		    self.sprite:move(x,y)
		    self.bound_box.x = self.bound_box.x + x
		    self.bound_box.y = self.bound_box.y + y
		  	if self.objects then
					for k,v in ipairs(self.objects) do
			  	 v:move(x,y)
					end
				end
   end,
		 ["scale"] = function (self,w,h) 
		    self.sprite:scale(w, h)
		    self.bound_box.w = self.bound_box.w + w
		    self.bound_box.h = self.bound_box.h + h
		 end,
		    
		 ["print"] = function () print("button") end,
		 ["set_position"] = function (self, x,y)		      
		    self.sprite:set_position(x,y)
		    self.bound_box.x = x
		    self.bound_box.y = y
	
		    end
		}

   exit["bound_box"] = {["x"]=x, ["y"]=y, ["w"] = w,["h"] = h}
   exit["sprite"] = b_exit
	exit["objects"] = {}
   function exit:get_sprite()
      return exit.sprite
   end

   return exit
 end

function make_sprite(path_sprite)  
   return  make_element_with_sprite(ERPG_sprite.make(path_sprite, {255,0,255,255}))
end

function make_button(path_sprite, x,y,fce)  
   local b_exit = ERPG_sprite.make(path_sprite, ALPHA_COLOR)
   local w, h = b_exit:get_width_height()
   local x = x or 0
   local y = y or 0
   
   b_exit:move(x, y)   

   local exit = {["move"] = function (self, x ,y)
		    self.sprite:move(x,y)
		    self.bound_box.x = self.bound_box.x + x
		    self.bound_box.y = self.bound_box.y + y
		  
   end,
		 ["scale"] = function (self,w,h) 
		    self.sprite:scale(w, h)
		    self.bound_box.w = self.bound_box.w + w
		    self.bound_box.h = self.bound_box.h + h
		 end,
		    
		 ["print"] = function () print("button") end,
		 ["set_position"] = function (self, x,y)		      
		      self:set_position(x,y)
		      self.bound_box.x = x
		      self.bound_box.y = y
	
		    end
		}

   local function on_click(self, mouse)
      if mouse.release == "left" then
	 if fce then fce(self, mouse) end
      end
   end

   exit["bound_box"] = {["x"]=x, ["y"]=y, ["w"] = w,["h"] = h}
   exit["sprite"] = b_exit
   
   

   add_event(exit, "on_click", on_click)

   return exit
 end

 
