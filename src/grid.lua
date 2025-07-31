local tile = require "tile"
local vec = require "lib.vector"
return {
	---@param preset Level.lua
	new = function(id)
		---@class Grid.lua
		local grid = {
			---@type Tile.lua[][]
			tiles = {},
			pos = vec.new(0, 0),
			size = 144,
			canvas = love.graphics.newCanvas(),
			isBeat = false,
			isLost = false,
			id = id
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
		function grid:checkWin()
			for _, exit in ipairs(self:find("exit")) do
				if not exit.tile:findEntities("box")[1] then
					return false
				end
			end
			for _, sensor in ipairs(self:find("sensor")) do
				if not sensor.data.triggered then
					return false
				end
			end
			self.isBeat = true
			return true
		end

		function grid:checkLoss()
			if self:find("player")[1] then
				return true
			end
			self.isLost = true
			return true
		end

		---@param movement Vector.lua
		function grid:step(movement)
			---@type Entity.lua
			local player = grid:find("player")[1]
			player:move(movement)
			grid:checkWin()
			grid:checkLoss()
			return "step"
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
							hits[#hits + 1] = entity
						end
					end
				end
			end
			return hits
		end

		function grid:update(dt)
			for _, row in ipairs(self.tiles) do
				for _, tile in ipairs(row) do
					tile:update(dt)
				end
			end
		end

		function grid:draw(x, y, scale)
			love.graphics.setCanvas(self.canvas)
			love.graphics.push()
			love.graphics.translate(16, 16)
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
			love.graphics.pop()
			love.graphics.setCanvas()
			love.graphics.setBlendMode("alpha", "premultiplied")

			if grid.isBeat then
				love.graphics.setColor(0.75, 1, 0.75, 0.5)
			elseif grid.isLost then
				love.graphics.setColor(1, 0.75, 0.75, 0.5)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.draw(self.canvas, x + self.pos.x, y +
				self.pos.y, 0, scale,
				scale)
			love.graphics.setBlendMode("alpha")
		end

		return grid
	end

}
