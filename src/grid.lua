local tile = require "tile"
local vec = require "lib.vector"
return {
	---@param preset Level.lua
	new = function()
		---@class Grid.lua
		local grid = {
			---@type Tile.lua[][]
			tiles = {},
			pos = vec.new(0, 0),
			canvas = love.graphics.newCanvas(),
		}
		grid.canvas:setFilter("nearest", "nearest")
		---@param pos Vector.lua
		---@param type tileTypes
		function grid:setTile(pos, type)
			grid.tiles[pos.x][pos.y] = tile.new(self, pos, type)
		end

		---@param pos Vector.lua
		function grid:getTile(pos)
			if not grid.tiles[pos.x] then return nil end
			return grid.tiles[pos.x][pos.y]
		end

		for x = 1, 8, 1 do
			grid.tiles[x] = {}
			for y = 1, 8, 1 do
				grid:setTile(vec.new(x, y), "void")
			end
		end
		---@param movement Vector.lua
		function grid:step(movement)
			---@type Entity.lua
			local player = grid:find("player")[1]
			if not player then return false end
			player:move(movement)
			if not player then return false end
		end

		---@param type tileTypes|entityTypes
		---@param data table
		---@return (Tile.lua|Entity.lua)[]
		function grid:find(type, data)
			local hits = {}
			for _, row in ipairs(self.tiles) do
				for _, tile in ipairs(row) do
					if tile.type == type then
						hits[#hits + 1] = tile
					else
						for i, entity in ipairs(tile:findEntities(type, data)) do
							hits[i] = entity
						end
					end
				end
			end
			return hits
		end

		function grid:draw()
			love.graphics.setCanvas(self.canvas)
			love.graphics.translate(5, 5)
			love.graphics.clear()
			love.graphics.setLineWidth(1)
			for x, row in ipairs(self.tiles) do
				for y, tile in ipairs(row) do
					tile:draw()
					--outline
					love.graphics.setColor(1, 1, 1, 0.1)
					if tile.type ~= "wall" then
						love.graphics.rectangle("line", 16 * (x - 1) + 1, 16 * (y - 1) + 1, 16 - 2, 16 - 2)
					end
					love.graphics.setColor(1, 1, 1, 1)
				end
			end
			love.graphics.setCanvas()
			love.graphics.setBlendMode("alpha", "premultiplied")
			love.graphics.draw(self.canvas, self.pos.x, self.pos.y, 0, 4, 4)
			love.graphics.setBlendMode("alpha")
		end

		return grid
	end

}
