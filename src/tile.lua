---@alias tileTypes "void"|"ground"|"wall"
local colors = require "lib.colors"
local bib = require "lib.biblib"
local vec = require "lib.vector"
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

		function tile:getNeighbourDirections(type)
			local hits = {}
			for _, direction in ipairs(bib.directions) do
				local neighbour = tile.grid:getTile(self.pos + direction)
				if neighbour and neighbour.type == type then
					hits[#hits + 1] = direction
				end
			end
			return hits
		end

		function tile:draw(filter)
			love.math.setRandomSeed(pos.x * 1000, pos.y)
			local image
			local r = 0
			local pos = self.pos * 16
			if filter == "fade" then
				if self.type == "void" then
					return false
				end
				if self.type == "ground" then
					love.graphics.setColor(0.7, 0.7, 0.7, 1)
				end
				love.graphics.draw(sprites.groundfade, pos.x, pos.y + 16)
				image = nil
			elseif filter == "wall" then
				if self.type ~= "wall" then
					return false
				end
				image = false

				love.graphics.draw(sprites.wall.base, pos.x, pos.y)

				local directions = self:getNeighbourDirections("wall")
				---@type Vector.lua[]
				local post = bib.cookieCutter(bib.directions, directions)
				for _, directionVec in ipairs(post) do
					local directionName = bib.dirVec(directionVec)
					local lSta = directionVec:clone()
					local lEnd = directionVec:clone()
					local dotheline = true
					love.graphics.setColor(0, 0, 0, 1)
					if directionName == "up" then
						lSta = lSta + vec.new(0, 1)
						lEnd = lEnd + vec.new(16, 0)
					elseif directionName == "left" then
						lSta = lSta + vec.new(1, 0)
						lEnd = lEnd + vec.new(0, 16)
					elseif directionName == "right" then
						lSta = lSta + vec.new(16, 0)
						lEnd = lEnd + vec.new(16, 16)
					else
						if self.grid:getTile(self.pos + vec.new(0, 1)).type == "ground" then
							lSta = lSta + vec.new(0, 16)
							lEnd = lEnd + vec.new(16, 16)
						else
							dotheline = false
						end
						love.graphics.setColor(1, 1, 1, 1)
						love.graphics.draw(sprites.wall.down, pos.x, pos.y)
						love.graphics.draw(sprites.wall.chisel[love.math.random(1, 2)], pos.x, pos.y)
					end
					if dotheline then
						love.graphics.setColor(0, 0, 0, 1)
						love.graphics.line(pos.x + lSta.x, pos.y + lSta.y, pos.x + lEnd.x, pos.y + lEnd.y)
					end
					love.graphics.setColor(1, 1, 1, 1)
				end
			elseif self.type == "void" then
				love.graphics.setColor(0, 0, 0, 0)
			elseif self.type == "ground" then
				love.graphics.setColor(0.7, 0.7, 0.7, 1)
				image = sprites.ground
				r = math.rad(love.math.random(0, 4) * 90)
			end
			love.graphics.push()
			love.graphics.translate(pos.x + 8, pos.y + 8)
			love.graphics.rotate(r)
			love.graphics.translate(-(pos.x + 8), -(pos.y + 8))
			if image then
				love.graphics.draw(image, pos.x, pos.y)
			elseif image == nil then
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
