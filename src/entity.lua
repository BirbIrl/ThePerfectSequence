---@alias entityTypes "player"|"box"|"glass"|"teleporter"|"exit"|"sensor"
local colors = require "lib.colors"
local vec = require "lib.vector"
local bib = require "lib.biblib"
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
			---@type {t: number, duration: number, type: string}
			anim = nil
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

		function entity:triggerIce(tile)
			if self.type == "player" then
				local glass = tile:findEntities("glass")[1]
				if glass then
					local entities = glass.tile.entities
					while entities[1] do
						entities[1]:removeFromTile()
					end
				end
			end
		end

		function entity:removeFromTile()
			local index = entity:getIndex()
			if not index then return false end
			table.remove(self.tile.entities, index)
			entity:triggerIce(self.tile)
			self.tile = nil

			return true
		end

		---@param targetTile? Tile.lua
		function entity:moveToTile(targetTile, force)
			if self.type ~= "glass" then
				if not targetTile or targetTile.type == "void" and not targetTile:findEntities("glass")[1] then
					self:removeFromTile()
					return false
				elseif targetTile.type == "wall" or (self.type == "box" and targetTile:findEntities("box")[1]) then
					return true
				end
				local box = targetTile:findEntities("box")[1]
				if self.type == "player" and box then
					box:move(box.tile.pos - self.tile.pos)
					return true
				end
				self.anim = { t = 0, duration = 0.1, type = "shift", from = self.tile.pos, to = targetTile.pos }
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
						self:triggerIce(targetTile)
						targetTile = teleportTile
					end
				end
				local sensor = targetTile:findEntities("sensor", { triggered = false })[1]
				if sensor then
					sensor.data.triggered = true
				end
			end
			self:removeFromTile()
			table.insert(targetTile.entities, self)
			self.tile = targetTile
			return true
		end

		function entity:update(dt)
			if self.anim then
				self.anim.t = self.anim.t + dt
				if self.anim.t > self.anim.duration then
					self.anim = nil
				end
			end
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
			elseif self.type == "exit" then
				love.graphics.setColor(colors.list["Blue"])
			elseif self.type == "sensor" then
				if self.data.triggered then
					love.graphics.setColor(colors.list["Banana Yellow"])
				else
					love.graphics.setColor(colors.list["Yellow Brown"])
				end
			end
			local pos = self.tile.pos
			if self.anim and self.anim.type == "shift" then
				pos = bib.lerp(self.anim.from, self.anim.to, self.anim.t / self.anim.duration)
			end
			love.graphics.rectangle("fill", 16 * (pos.x - 1) + 1, 16 * (pos.y - 1) + 1, 16 - 2, 16 -
				2)
			love.graphics.setColor(1, 1, 1, 1)
		end

		entity:moveToTile(tile)

		return entity
	end
}
