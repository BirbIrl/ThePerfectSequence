---@alias tileTypes "void"|"ground"|"wall"
local colors = require "lib.colors"
local bib = require "lib.biblib"
local sprites = require "assetIndex".sprites
return {
	---@param grid Grid.lua
	---@return Tile.lua
	new = function(grid, pos, type)
		---@class Tile.lua
		local tile = {
			---@type Grid.lua
			grid = grid,
			---@type Vector.lua
			pos = pos,
			---@type tileTypes
			type = type,
			---@type Entity.lua[]
			entities = {},
		}
		---@param entityType entityTypes
		---@return Entity.lua[]
		function tile:findEntities(entityType, data, countDestroyed)
			local hits = {}
			for _, entity in ipairs(self.entities) do
				if entity.type == entityType and (data == nil or bib.equals(data, entity.data)) then
					if (not entity.destroyed) or countDestroyed then
						hits[#hits + 1] = entity
					end
				end
			end
			return hits
		end

		function tile:update(dt)
			for _, entity in ipairs(self.entities) do
				entity:update(dt)
			end
		end

		function tile:draw()
			love.math.setRandomSeed(pos.x * 1000, pos.y)
			local image
			local r = 0
			local pos = self.pos * 16
			if self.type == "void" then
				love.graphics.setColor(0, 0, 0, 0)
			elseif self.type == "ground" then
				image = sprites.ground
				r = math.rad(love.math.random(0, 4) * 90)
				love.graphics.draw(sprites.groundfade, pos.x, pos.y + 16)
			elseif self.type == "wall" then
				image = sprites.wall
			end
			love.graphics.push()
			love.graphics.translate(pos.x + 8, pos.y + 8)
			love.graphics.rotate(r)
			love.graphics.translate(-(pos.x + 8), -(pos.y + 8))
			if image then
				love.graphics.draw(image, pos.x, pos.y)
			else
				love.graphics.rectangle("fill", pos.x, pos.y, 16, 16)
			end
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.pop()

			for _, entity in ipairs(self.entities) do
				if entity.type ~= "box" and entity.type ~= "player" then
					entity:draw()
				end
			end
		end

		return tile
	end
}
