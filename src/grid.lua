local tile = require "tile"
local vec = require "lib.vector"
local bib = require "lib.biblib"
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
			beenDead = 0,
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

		for x = 1, 10, 1 do
			grid.tiles[x] = {}
			for y = 1, 10, 1 do
				grid:setTile(vec.new(x, y), "void")
			end
		end
		function grid:checkWin()
			local missing = 0
			for _, exit in ipairs(self:find("exit")) do
				if not exit.tile:findEntities("box")[1] then
					missing = missing + 1
				end
			end
			for _, sensor in ipairs(self:find("sensor")) do
				if not sensor.data.triggered then
					missing = missing + 1
				end
			end
			if missing == 0 then
				self.isBeat = true
				return true
			end
			return missing
		end

		function grid:checkLoss()
			if self:find("player")[1] then
				return true
			end
			self.isLost = true
			return true
		end

		---@param directionName directions
		function grid:step(directionName)
			---@type Entity.lua
			local player = grid:find("player")[1]
			local _, moveVec = bib.dirVec(directionName)
			player:move(moveVec)
			player.data.eyes = sprites.player[directionName]
			grid:checkWin()
			grid:checkLoss()
			return "step"
		end

		---@param type tileTypes|entityTypes
		---@param data? table
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
			if self.isLost and self.beenDead < 1.3 then
				self.beenDead = self.beenDead + dt
			elseif self.beenDead > 0 then
				self.beenDead = self.beenDead - dt * 3
			end
		end

		function grid:draw(x, y, scale)
			love.graphics.setCanvas(self.canvas)
			love.graphics.push()
			love.graphics.translate(-16, -16)
			love.graphics.clear()
			love.graphics.setLineWidth(1)

			for x, row in ipairs(self.tiles) do
				for y, tile in ipairs(row) do
					tile:draw("fade")
					love.graphics.setColor(1, 1, 1, 1)
				end
			end
			for x, row in ipairs(self.tiles) do
				for y, tile in ipairs(row) do
					tile:draw()
					love.graphics.setColor(1, 1, 1, 1)
				end
			end
			for x, row in ipairs(self.tiles) do
				for y, tile in ipairs(row) do
					tile:draw("wall")
					love.graphics.setColor(1, 1, 1, 1)
				end
			end

			for _, row in ipairs(self.tiles) do
				for _, tile in ipairs(row) do
					local entity = tile:findEntities("box", nil, true)[1] or tile:findEntities("player", nil, true)[1]
					if entity then
						entity:draw()
					end
				end
			end
			love.graphics.pop()
			love.graphics.setCanvas(mainCanvas)
			love.graphics.setBlendMode("alpha", "premultiplied")

			if grid.isBeat then
				love.graphics.setColor(0.85, 1, 0.85, 1)
			elseif self.beenDead > 0 then
				local fade = 1 - self.beenDead / 4
				love.graphics.setColor(fade, fade, fade, fade)
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
