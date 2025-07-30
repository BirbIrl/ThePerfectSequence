---@alias entityTypes "player"|"box"
local colors = require "lib.colors"
return {
	---@param tile Tile.lua
	---@param type entityTypes
	---@return Entity.lua
	new = function(tile, type)
		---@class Entity.lua
		local entity = {
			---@type Tile.lua
			tile = tile,
			---@type entityTypes
			type = type,
		}


		---@param movement Vector.lua
		function entity:move(movement)
			entity:moveToTile(self.tile.grid:getTile(self.tile.pos + movement))
		end

		function entity:getIndex()
			for i, ent in ipairs(self.tile.entities) do
				if ent == self then return i end
			end
			return false
		end

		function entity:removeFromTile()
			local index = entity:getIndex()
			print(index)
			if not index then return false end
			table.remove(self.tile.entities, index)
			self.tile = nil
			return true
		end

		---@param targetTile? Tile.lua
		function entity:moveToTile(targetTile)
			self:removeFromTile()
			if not targetTile or targetTile.type == "void" then
				return false
			end
			table.insert(targetTile.entities, self)
			self.tile = targetTile
			return true
		end

		function entity:draw()
			if self.type == "player" then
				love.graphics.setColor(colors.list["Acid Green"])
				love.graphics.rectangle("fill", 16 * (self.tile.pos.x - 1), 16 * (self.tile.pos.y - 1), 16, 16)
				love.graphics.setColor(1, 1, 1, 1)
			end
		end

		entity:moveToTile(tile)

		return entity
	end
}
