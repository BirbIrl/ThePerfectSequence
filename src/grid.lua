local tile = require "tile"
local vec = require "lib.vector"
return {
	---@param pos Vector.lua
	---@return Grid.lua
	new = function(pos)
		---@class Grid.lua
		local grid = {
			---@type Tile.lua[][]
			tiles = {},
			pos = pos,
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
			return grid.tiles[pos.x][pos.y]
		end

		for x = 1, 8, 1 do
			grid.tiles[x] = {}
			for y = 1, 8, 1 do
				grid:setTile(vec.new(x, y), "void")
			end
		end

		function grid:draw()
			love.graphics.setCanvas(self.canvas)
			love.graphics.clear()
			for x, row in ipairs(self.tiles) do
				for y, tile in ipairs(row) do
					tile:draw()
					--outline
					love.graphics.setColor(1, 1, 1, 0.25)
					love.graphics.rectangle("line", 1 + 16 * (x - 1), 1 + 16 * (y - 1), 16, 16)
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
