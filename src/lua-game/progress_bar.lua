local Bar = {}

function Bar.make(color_bar,color_progress,width,height, max)
   local bar = GUI.make_frame_element({0,0, width,height}, color_bar)
   local margin = 5
   local progress_width = width-margin*2
   local progress_height = height-margin*2
   local progress = GUI.make_frame_element({margin,margin,progress_width,progress_height},
					   color_progress)
   
   bar["max"] = max
   bar["current"] = max

   function bar:change_maximum(max, current)
      bar.max = max

      if current then
	 bar.current = current 
      end
      local w = (progress_width*current)/bar.max
      if w < 0 then
	 w = 0
      end

      progress.sprite:set_size(0,0,w,progress_height)
   end
   
   function bar:change_current(current)
      if current < 0 then
	 current = 0
      end
	 
      local w = (progress_width*current)/bar.max
      if w < 0 then
	 w = 0
      end
      bar.current = current
      progress.sprite:set_size(0,0,w,progress_height)
   end
   
   function bar:change_color(color)
      progress:set_color(color)
   end
   
   GUI.compose_object(bar, progress)

   return bar
end


return Bar