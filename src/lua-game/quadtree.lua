local QuadTree = {}

QuadTree.last_count = 0

function QuadTree.intersection(rect1, rect2)
   local n,r =  ERPG_Utils.intersect_rect({ rect1.x, rect1.y, rect1.w, rect1.h}, 
				    { rect2.x, rect2.y, rect2.w, rect2.h})

   if n.w == rect1.w and  n.h == rect1.h then
      n = 1
   else
      n = nil
   end

   if r == 0 then 
      return nil,n
   end
   return true, n
end

function QuadTree.traversal(node)
   local objects = {}
   
   for k,v in ipairs(node.objects) do
      QuadTree.last_count = QuadTree.last_count + 1
      objects[#objects + 1] = v:get_object()      
   end

--   print("name", node.name,"objects", #node.objects, node.bound_box.x, node.bound_box.y,
--	 node.bound_box.w,node.bound_box.h)

   if node.name == "node" then
--      print("node -  objects", self.objects, self.bound_box.x,self.bound_box.y,
--	    self.bound_box.w,self.bound_box.h)
      for k,v in ipairs(node.children) do
	 QuadTree.last_count = QuadTree.last_count + 1
	 objects = HelpFce.append(objects, QuadTree.traversal(v))
      end
   end
   
   return objects
end

function QuadTree.new(width)
   local quadTree = {}
   quadTree["width"] = width
   quadTree["root"] = nil
   quadTree["objects_in_leaf"] = 15

   local function make_leaf_object(object, rect)
      local leaf_object = {
	 ["object"] = object,
	 ["bound_box"] = rect
      }

      function leaf_object:get_bound_box()
	 return self.bound_box
      end
      function leaf_object:get_object()
	 return self.object
      end

      return leaf_object
   end
   
   function quadTree:make_leaf(rect, node)      
      local leaf = {
	 ["parrent"] = node,
	 ["name"] = "leafe",
	 ["objects"] = {},
	 ["bound_box"] = rect
      }
      function leaf:add_object(leaf_object)
--	 print("Co se kurva děje?")
	 local count = #self.objects + 1
	 if count <= quadTree.objects_in_leaf then
	    self.objects[count] =  leaf_object
	 else
	    local node = self:subdivide()
	    if node then 
	       node:add_object(leaf_object)
	    else
	       leaf.objects[#leaf.objects + 1 ] = leaf_object	       
--	       print("return self", self)
	       return self
	    end	    
--	    print("return node")
	    return node
	 end
--	 print("return self", self)
	 return self
      end
      
      function leaf:subdivide()
	 local node = quadTree:make_node(self.bound_box)
--	 print("subdivide",self.bound_box.x,self.bound_box.y,self.bound_box.w,self.bound_box.h)
	 if node then
	    for k,v in ipairs(leaf.objects) do	    
	       node:add_object(v)
	    end
	    return node
	 end
      end

      function leaf:get_intersect_objects(rect)
	 local list = {}
	 for k,v in ipairs(self.objects) do
	    QuadTree.last_count = QuadTree.last_count + 1
	    local r =  QuadTree.intersection(v.bound_box, rect)
	    if r then
	       list[#list + 1] = v:get_object()
	    end
	 end
	 
	 return list
      end

      return leaf
   end

   
   function quadTree:make_node(rect)    
      local mid = math.floor(rect.w/2)
      
      if rect.w <= 200 then 

	 return 
      end

      local node ={
	 ["name"] = "node",
	 ["children"] = {quadTree:make_leaf({["x"] = rect.x, ["y"] = rect.y, 
					     ["w"] = mid, ["h"] = mid}, node),
			 quadTree:make_leaf({["x"] = rect.x+mid, ["y"] = rect.y, 
					     ["w"] = mid, ["h"] = mid}, node),
			 quadTree:make_leaf({["x"] = rect.x, ["y"] = rect.y + mid, 
					     ["w"] = mid, ["h"] = mid}, node), 
			 quadTree:make_leaf({["x"] = rect.x + mid, ["y"] = rect. y + mid , 
					     ["w"] = mid, ["h"] = mid}, node)},
	 ["bound_box"] = rect,
	 ["objects"] = {}
      }
      
      function node:add_object(leaf_object) 
	 local r, h
	 if #self.children == 0 then
--	    print("Něco je špatně")
	 end
	 for k, node_leaf in ipairs(self.children) do
	    local inter = QuadTree.intersection(leaf_object.bound_box, node_leaf.bound_box)
--	    print("coco?",inter)
	    if inter then	      
	  --     print("WHAT?",leaf_object.bound_box.x, node_leaf.bound_box.x)
	       if r then
		  h = true
	       end
	       r = k
	    end
	    inter = nil
	 end

	 if h  then
	    self.objects[#self.objects + 1] = leaf_object
	 else

	    if r == nil then 
	     --  print(leaf_object.bound_box.x,leaf_object.bound_box.y,"out_of_box",
	--	     self.bound_box.x,self.bound_box.y,self.bound_box.w,self.bound_box.h) 
	       return
	    end
	   -- print("Začínáme",self.name,self.children[r].name,self)
	    local ret = self.children[r]:add_object(leaf_object)
	    self.children[r] = ret
	 --   print("CO vratil? ", ret, self.name,self)
	 end
	 return self
      end
--[[
      
      function node:add_object(leaf_object)
	 local result = self
	 for k,leaf in ipairs(self.children) do
	    if leaf.name == "leafe" then
	       local decide = QuadTree.intersection(leaf_object.bound_box, leaf.bound_box)
	       if decide then
		  local result = leaf:add_object(leaf_object)
		  node.children[k] = result		  		  
	       end
	    else
	       local decide = QuadTree.intersection(leaf_object.bound_box, leaf.bound_box)
	       if decide then
		  local tmp = leaf:add_object(leaf_object)
		  self.children[k] = tmp
	       end
	    end
	 end
	 return result
   end]]
      local count = 0 
      function node:get_all()
	 for k,v in pairs(self.children) do
	    if v.name == "leafe" then
	       count = count + #v.objects
	    else
	       v:get_all()
	    end
	 end
      end
      
      function node:get_objects()
	 return self.objects
      end

      function node:get_intersect_objects(rect)
	 local r_obj = {}

	 for k,v in ipairs(self.objects) do
	    QuadTree.last_count = QuadTree.last_count + 1
	    local decide, all = QuadTree.intersection(v.bound_box, rect)
	    if decide then
	       r_obj[#r_obj + 1] = v:get_object()
	    end
	 end
	 for k,v in ipairs(self.children) do
	       QuadTree.last_count = QuadTree.last_count + 1
	    local decide, all = QuadTree.intersection(v.bound_box, rect)
	    if all then 
	       if v.name == "node" then
		  for k,v in ipairs(v.objects) do
		     QuadTree.last_count = QuadTree.last_count + 1
		     local decide, all = QuadTree.intersection(v.bound_box, rect)
		     if decide then
			r_obj[#r_obj + 1 ] = v:get_object()
		     end
		  end
		  r_obj = HelpFce.append(r_obj, QuadTree.traversal(v.children[1]))
		  r_obj = HelpFce.append(r_obj, QuadTree.traversal(v.children[2]))
		  r_obj = HelpFce.append(r_obj, QuadTree.traversal(v.children[3]))
		  r_obj = HelpFce.append(r_obj, QuadTree.traversal(v.children[4]))
	       else
		  for k,v in ipairs(v.objects) do
		     r_obj[#r_obj+1] = v:get_object()
		  end
	       end
	    elseif decide then
	       r_obj = HelpFce.append(r_obj, v:get_intersect_objects(rect))
	    end
	 end	 
	 return r_obj
      end
      
      

      return node
   end


   function quadTree:insert(object, rect)
      local leaf_object = make_leaf_object(object,rect)
      quadTree.root:add_object(leaf_object)
   end
   function quadTree:get_intersect_objects(rect)
      QuadTree.last_count = 0
      return quadTree.root:get_intersect_objects(rect)
   end
   function quadTree:get_all()
      return QuadTree.traversal(quadTree.root)      
   end
   

   quadTree["root"] = quadTree:make_node({["x"] = 0, ["y"] = 0, ["w"] = width, ["h"] = width})

   return quadTree
end

return QuadTree