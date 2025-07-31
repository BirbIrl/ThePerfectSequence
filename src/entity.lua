---@alias entityTypes "player"|"box"|"glass"|"teleporter"
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
		function entity:moveToTile(targetTile, force)
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
				local teleporter = targetTile:findEntities("teleporter")[1]
				if teleporter then
					local targetLink = teleporter.data.link
					if teleporter.data.link % 2 == 0 then
						targetLink = targetLink - 1
					else
						targetLink = targetLink + 1
					end
					local teleportTile = self.tile.grid:find("teleporter", { link = targetLink })[1].tile
					if not teleportTile:findEntities("box")[1] and not teleportTile:findEntities("player")[1] then
						targetTile = teleportTile
					end
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
				love.graphics.setColor(colors.list["Orange Brown"])
			elseif self.type == "glass" then
				love.graphics.setColor(colors.blend(colors.list["Sky Blue"], { nil, nil, nil, 0.2 }, 1))
			elseif self.type == "teleporter" then
				love.graphics.setColor(colors.list["Plum Purple"])
			end
			love.graphics.rectangle("fill", 16 * (self.tile.pos.x - 1) + 1, 16 * (self.tile.pos.y - 1) + 1, 16 - 2, 16 -
				2)
			love.graphics.setColor(1, 1, 1, 1)
		end

		entity:moveToTile(tile)

		return entity
	end
}
