---@alias entityTypes "player"|"box"|"glass"
local colors = require "lib.colors"
local vec = require "lib.vector"
return {
	---@param tile Tile.lua
	---@param type entityTypes
	---@return Entity.lua
	new = function(tile, type, data)
		---@class Entity.lua
		local entity = {
			---@type Tile.lua
			tile = tile,
			---@type entityTypes
			type = type,
			data = data,
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
			if not index then return false end
			table.remove(self.tile.entities, index)
			if self.type == "player" then
				local glass = self.tile:findEntities("glass")[1]
				if glass then
					glass:removeFromTile()
				end
			end
			self.tile = nil
			return true
		end

		---@param targetTile? Tile.lua
		function entity:moveToTile(targetTile)
			if self.type ~= "glass" then
				if not targetTile or targetTile.type == "void" and not targetTile:findEntities("glass")[1] then
					self:removeFromTile()
					return false
				elseif targetTile.type == "wall" then
					return true
				end
				local box = targetTile:findEntities("box")[1]
				if self.type == "player" and box then
					box:move(box.tile.pos - self.tile.pos)
					return true
				end
			end
			self:removeFromTile()
			table.insert(targetTile.entities, self)
			self.tile = targetTile
			return true
		end

		function entity:draw()
			if self.type == "player" then
				love.graphics.setColor(colors.list["Acid Green"])
			elseif self.type == "box" then
				love.graphics.setColor(colors.list["Bright Magenta"])
			end
			love.graphics.rectangle("fill", 16 * (self.tile.pos.x - 1) + 1, 16 * (self.tile.pos.y - 1) + 1, 16 - 2, 16 -
				2)
			love.graphics.setColor(1, 1, 1, 1)
		end

		entity:moveToTile(tile)

		return entity
	end
}
