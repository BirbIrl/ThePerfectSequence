---@alias entityTypes "player"|"box"|"glass"|"teleporter"|"exit"|"sensor"
local colors = require "lib.colors"
local vec = require "lib.vector"
local bib = require "lib.biblib"
local sprites = require "sprites"
local tween = require "lib.tween"
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
			destroyed = false,
			---@type Tween.lua[]
			anims = {}
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

		---@param targetTile Tile.lua
		function entity:moveToTile(targetTile, force)
			local anims
			if self.type ~= "glass" then
				if targetTile.type == "void" and not targetTile:findEntities("glass")[1] then
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
				local easing = "outCubic"
				if self.type == "player" then
					easing = "outBack"
				end
				anims = { tween.new(0.15,
					{ type = "shift", offset = self.tile.pos - targetTile.pos },
					{ offset = vec.new(0, 0) }, easing) }
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
						anims = {
							tween.new(0.25, { type = "shift", offset = targetTile.pos - teleportTile.pos },
								{ offset = 2 * targetTile.pos - teleportTile.pos - self.tile.pos }, easing, 0, 0.10),
							tween.new(0.25, { type = "shift", offset = -(targetTile.pos - self.tile.pos) },
								{ offset = vec.new(0, 0) }, easing, 0.10, 0.25)
						}
						self:triggerIce(targetTile)
						targetTile = teleportTile
					end
				end

				local sensor = targetTile:findEntities("sensor", { triggered = false })[1]
				if sensor then
					sensor.data.triggered = true
				end
			end
			if anims then
				local animCount = #self.anims
				for i, anim in ipairs(anims) do
					self.anims[animCount + i] = anim
				end
			end
			self:removeFromTile()
			table.insert(targetTile.entities, self)
			self.tile = targetTile
			return true
		end

		function entity:update(dt)
			for _, anim in ipairs(self.anims) do
				anim:update(dt)
			end
		end

		function entity:draw()
			local pos = self.tile.pos
			for i, anim in ipairs(self.anims) do
				if anim.finished then
					table.remove(self.anims, i)
				end
			end
			for _, anim in ipairs(self.anims) do
				if anim:get().type == "shift" then
					--pos = bib.lerp(self.anim.from, self.anim.to, self.anim.t / self.anim.duration)
					---@type Vector.lua
					pos = pos + anim:get().offset
					--tween
				end
			end
			pos = pos * 16
			pos.x = math.floor(pos.x)
			pos.y = math.floor(pos.y)
			local image = nil
			if self.type == "player" then
				love.graphics.draw(sprites.player.body, pos.x, pos.y)
				image = self.data.eyes
				debug = false
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
			if image then
				love.graphics.draw(image, pos.x, pos.y)
			else
				love.graphics.rectangle("fill", pos.x + 1, pos.y + 1, 16 - 2, 16 -
					2)
			end
			love.graphics.setColor(1, 1, 1, 1)
		end

		entity:moveToTile(tile)

		return entity
	end
}
