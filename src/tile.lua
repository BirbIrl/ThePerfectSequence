---@alias tileTypes "void"|"ground"|"wall"
local colors = require "lib.colors"
local bib = require "lib.biblib"
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
		function tile:findEntities(entityType, data)
			local hits = {}
			for _, entity in ipairs(self.entities) do
				if entity.type == entityType and (data == nil or bib.equals(data, entity.data)) then
					hits[#hits + 1] = entity
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
			if self.type == "void" then
				love.graphics.setColor(0, 0, 0, 0)
			elseif self.type == "ground" then
				love.graphics.setColor(1, 1, 1, 0.5)
			elseif self.type == "wall" then
				love.graphics.setColor(colors.list["Brown Red"])
			end
			love.graphics.rectangle("fill", 16 * (self.pos.x), 16 * (self.pos.y), 16, 16)
			love.graphics.setColor(1, 1, 1, 1)

			for _, entity in ipairs(self.entities) do
				if entity.type ~= "box" and entity.type ~= "player" then
					entity:draw()
				end
			end
		end

		return tile
	end
}
