---@alias tileTypes "void"|"box"|"player"|"wall"
return {
	---@param grid Grid.lua
	---@param pos Vector.lua
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
		}
		function tile:draw()
			if self.type == "void" then
				--love.graphics.rectangle("line", 16 * (self.pos.x - 1), 16 * (self.pos.y - 1), 16, 16)
			end
		end

		return tile
	end
}
