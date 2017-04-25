local Pattern_text = {}

Pattern_text["answers"] = {}
Pattern_text["question"] = {}

GUI.add_format_function("answer",  function (txt) 
			   local answer 
			   for k,v in ipairs(txt) do				 
			      if answer then
				 answer = answer .. "," ..  v
			      else
				 answer = v
			      end
			   end 
			   Pattern_text.answers[#Pattern_text.answers + 1] = answer
				   end)

GUI.add_format_function("question", function (txt)
			   local answer 
			   for k,v in ipairs(txt) do				 
			      if answer then
				 answer = answer .. "," ..  v
			      else
				 answer = v
			      end			      
			   end 
			   Pattern_text.question[#Pattern_text.question + 1] = answer
				    end)


function Pattern_text.get_answers()
   local tmp = Pattern_text.answers
   local question = Pattern_text.question

   Pattern_text.answers = {}
   Pattern_text.question = {}

   return tmp, question
end

return Pattern_text