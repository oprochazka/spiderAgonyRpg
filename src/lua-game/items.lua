local Item = {}

Item["items"] = {}

local id = 1

function Item.make_item(item_config, model)
   local item = {
         ["id"] = id,
         ["type"] = nil,
         ["name"] = nil,
         ["inventory_sprite"] = nil,
         ["model"] = nil,
         ["stats"] = nil,
         ["need_abilities"] = nil,
         ["equipment_bind"] = nil,
         ["item_config"] = nil,   
         ["EId"] = nil      
   }


   if item_config then
      local model = model or make_model(item_config.animation)
      item = {
         ["id"] = id,
         ["type"] = item_config.type,
         ["name"] = item_config.name,
         ["inventory_sprite"] = item_config.path_inventory_picture,
         ["model"] = model,
         ["stats"] = item_config.stats,
         ["need_abilities"] = item_config.need_abilities,
         ["equipment_bind"] = item_config.equipment_bind,
         ["item_config"] = item_config,   
         ["EId"] = IdG.getId()      
      }

   end

   function item:setConfiguration(config, model)
      local model = model or make_model(config.animation)

      item.type = config.type
      item.name = config.name
      item.inventory_sprite = config.path_inventory_picture
      item.model = model
      item.stats = config.stats
      item.need_abilities = config.need_abilities
      item.equipment_bind = config.equipment_bind
      item.item_config = config
      item.EId = IdG.getId()      
   end

   function item:getId()
      return self.EId
   end

   function item:dump()
      local dumped =  {
         ["name"] = item.name,
         ["EId"] = item.EId
      }

      return dumped
   end

   function item:load(dump)
      self:setConfiguration(_ITEMS[dump.name])
      self.EId = dump.EId
   end

   id = id + 1

   Item.items[#Item.items + 1] = item

   return item
end

return Item