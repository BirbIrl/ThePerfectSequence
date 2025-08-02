---@alias entityTypes "player"|"box"|"glass"|"teleporter"|"exit"|"sensor"
local colors = require "lib.colors"
local vec = require "lib.vector"
local bib = require "lib.biblib"
local assets = require "assetIndex"
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
			anims = {},
			---@type love.Source?
			sound = nil
		}


		---@param movement Vector.lua
		function entity:move(movement)
			entity:moveToTile(self.tile.grid:getTile(self.tile.pos + movement))
		end

		function entity:destroy(duration)
			self.destroyed = true
			self.anims[#self.anims + 1] = tween.new(duration,
				{ type = "opacity", amount = 1 }, { amount = 0 }, "outCubic")
			local scaleAmount = 0.5
			if self.type == "glass" then
				scaleAmount = 0.9
			elseif self.type == "player" or self.type == "box" then
				self.sound = sounds.die
			end
			self.anims[#self.anims + 1] = tween.new(duration,
				{ type = "scale", amount = 1 }, { amount = scaleAmount }, "outCubic")
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
					for _, ent in ipairs(glass.tile.entities) do
						ent:destroy(0.5)
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

		function entity:bump(targetVec)
			local distance = targetVec / 4
			local animDuration = 0.08
			self.anims[#self.anims + 1] = tween.new(animDuration,
				{ type = "shift", offset = vec.new(0, 0) },
				{ offset = -distance:clone() }, "inQuint")
			self.anims[#self.anims + 1] =
				tween.new(animDuration * 1.5,
					{ type = "shift", offset = -distance:clone() },
					{ offset = vec.new(0, 0) }, "outQuad", nil, nil, -animDuration)
		end

		---@param targetTile Tile.lua
		function entity:moveToTile(targetTile, force)
			local anims
			if self.type ~= "glass" then
				local animDuration = 0.15
				local easing = "outCubic"
				if self.type == "player" then
					easing = "outBack"
				end
				if targetTile.type == "void" and not targetTile:findEntities("glass")[1] then
					animDuration = 0.2
					easing = "inOutCirc"
					self:destroy(2)
				elseif targetTile.type == "wall" or (self.type == "box" and targetTile:findEntities("box")[1]) then
					self:bump(self.tile.pos - targetTile.pos)
					return true
				end
				local box = targetTile:findEntities("box")[1]
				if self.type == "player" and box then
					box:move(box.tile.pos - self.tile.pos)
					self:bump(self.tile.pos - targetTile.pos)
					return true
				end
				anims = { tween.new(animDuration,
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
					if teleportTile == self.tile or (not teleportTile:findEntities("box")[1] and not teleportTile:findEntities("player")[1]) then
						anims = {
							tween.new(0.3, { type = "shift", offset = targetTile.pos - teleportTile.pos },
								{ offset = 2 * targetTile.pos - teleportTile.pos - self.tile.pos }, easing, 0, 0.15),
							tween.new(0.3, { type = "shift", offset = -(targetTile.pos - self.tile.pos) },
								{ offset = vec.new(0, 0) }, easing, 0.15)
						}
						self:triggerIce(targetTile)
						targetTile = teleportTile
						teleporter.sound = sounds.portal
					end
				end

				local sensor = targetTile:findEntities("sensor", { triggered = false })[1]
				local exit = targetTile:findEntities("exit")[1]
				if sensor or (self.type == "box" and exit) then
					local targetSound
					if self.tile.grid:checkWin() == 1 then
						targetSound = sounds.clear
					elseif exit then
						targetSound = sounds.ding[1]
					else
						targetSound = sounds.ding[2]
					end
					if exit then
						exit.sound = targetSound
					elseif sensor then
						sensor.sound = targetSound
						sensor.data.triggered = true
					end
				end
				if not self.sound then
					if self.type == "box" then
						self.sound = sounds.push
					elseif self.type == "player" then
						self.sound = sounds.walk
					end
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
			local opacity = 1
			local scale = 1
			if self.destroyed then
				opacity = 0
			end
			for i, anim in ipairs(self.anims) do
				if anim.finished then
					table.remove(self.anims, i)
				end
			end
			for _, anim in ipairs(self.anims) do
				if anim.clock > 0 then
					if anim:get().type == "shift" then
						--pos = bib.lerp(self.anim.from, self.anim.to, self.anim.t / self.anim.duration)
						---@type Vector.lua
						pos = pos + anim:get().offset
						--tween
					elseif anim:get().type == "opacity" then
						opacity = opacity + anim:get().amount
					elseif anim:get().type == "scale" then
						scale = scale * anim:get().amount
					end
				end
			end
			local image = nil
			if self.type == "glass" then
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
			local color = { love.graphics.getColor() }
			color[4] = color[4] * opacity
			love.graphics.setColor(color)
			love.graphics.push()
			love.graphics.translate(8, 8)
			love.graphics.scale(scale, scale)
			love.graphics.translate(-8, -8)
			pos = pos * 16 / scale
			pos.x = math.floor(pos.x)
			pos.y = math.floor(pos.y)
			if self.type == "player" then
				love.graphics.draw(sprites.player.body, pos.x, pos.y)
				image = self.data.eyes
			elseif self.type == "box" then
				image = sprites.box
			elseif self.type == "glass" then
				image = sprites.glass
			end
			if image then
				love.graphics.draw(image, pos.x, pos.y)
			else
				love.graphics.rectangle("fill", pos.x + 1, pos.y + 1, 16 - 2, 16 -
					2)
			end
			love.graphics.scale(1 / scale, 1 / scale)
			love.graphics.pop()
			love.graphics.setColor(1, 1, 1, 1)
		end

		entity:moveToTile(tile)

		return entity
	end
}
