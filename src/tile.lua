---@alias tileTypes "void"|"ground"|"wall"
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
		function tile:draw()
			if self.type == "void" then
				--love.graphics.rectangle("line", 16 * (self.pos.x - 1), 16 * (self.pos.y - 1), 16, 16)
			end
			if self.type == "ground" then
				love.graphics.setColor(1, 1, 1, 0.5)
				love.graphics.rectangle("fill", 16 * (self.pos.x - 1), 16 * (self.pos.y - 1), 16, 16)
				love.graphics.setColor(1, 1, 1, 1)
			end
			for _, entity in ipairs(self.entities) do
				entity:draw()
			end
		end

		return tile
	end
}
