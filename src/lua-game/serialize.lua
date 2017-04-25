local Serialization = {}

function Serialization.serialize (o, output)
   if type(o) == "number" then
      output:write(o)
   elseif type(o) == "string" then
      output:write(string.format("%q", o))
   elseif type(o) == "table" then
      output:write("{\n")
      for k,v in pairs(o) do
--	 output:write("  ", k, " = ")
	 output:write(" [") 
	 Serialization.serialize(k,output)
	 output:write("] = ")
	 Serialization.serialize(v,output)
	 output:write(",\n")
      end
      output:write("}\n")
   else
      error("cannot serialize a " .. type(o))
   end
end

function Serialization.serializeToString (o)
   local str = ""
   if type(o) == "number" then
      return o      
   elseif type(o) == "string" then
      return string.format("%q", o)
   elseif type(o) == "table" then
      str = str .."{"
      for k,v in pairs(o) do
          str = str .." [" 
          str = str .. Serialization.serializeToString(k)
          str = str .."] = "
          str = str .. Serialization.serializeToString(v)
          str = str ..","
      end
      str = str .."}"
   end
   return str
end



return Serialization