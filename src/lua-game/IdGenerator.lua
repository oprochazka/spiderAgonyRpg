local IdGenerator = {}

local id = 0

function IdGenerator:getId()
	id = id + 1
	return id
end
	

return IdGenerator